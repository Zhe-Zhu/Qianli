//
//  QianLiAudioCallViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "QianLiAudioCallViewController.h"
#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"
#import "QBAnimationSequence.h"
#import "QianLiUIMenuBar.h"
#import "Global.h"
#import "DRNRealTimeBlurView.h"
#import "UIImage+BoxBlur.h"
#import "DrawingViewController.h"
#import "WebViewController.h"
#import "UserDataTransUtils.h"
#import "WebBrowser.h"
#import "MobClick.h"
#import "Utils.h"
#import "SVStatusHUD.h"

@interface QianLiAudioCallViewController ()
{
    UIImageView *callingIndicator; // calling等待指示器
    UIImageView *networkIndicator;
    UIImageView *bulletinBoard;
    UIImageView *lineView;
    
    UIButton *pickupTheCall;
    UIButton *rejectTheCall;
    
    UILabel *timeLabel; // 通话时长
    NSDateFormatter *dateFormatter;
    NSDate *callBeginTime; // 通话开始时间
    NSTimer *timer;
    
    QianLiUIMenuBar *menuBar;
    
    dispatch_queue_t getImageQueue;
    ImageDisplayController __weak *_imageDispVC;
    VideoViewController __weak *_vedioVC;
    DrawingViewController __weak *_drawingVC;
    WebViewController __weak *_shoppingVC;
    WebBrowser * __weak _browser;
    
    BOOL imageSessionExists;
    BOOL getMaxNumber;
    BOOL getIndexArray;
    BOOL beginDownload;
    BOOL didEndCall;
    BOOL shouldPlayRingTone;
    
    double videoBeginTime;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonMicroPhone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSpeaker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonAdd;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonEndCall;

@property (weak, nonatomic) IBOutlet UIImageView *bigProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *blurImage;

@property bool isNoMicroPhoneOn;
@property bool isSpeakerOn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UILabel *calling;

@property(nonatomic, weak) ImageDisplayController *imageDispVC;
@property(nonatomic, weak) VideoViewController *vedioVC;
@property(nonatomic, weak) DrawingViewController *drawingVC;
@property(nonatomic, weak) WebViewController *shoppingVC;
@property(nonatomic, weak) WebBrowser *browser;
@property(nonatomic, strong) UINavigationControllerPortraitViewController *selectPhotoViewController;

@property(nonatomic) BOOL didEndCallBySelf;

@end

@implementation QianLiAudioCallViewController

#define inactiveButtonTintColor [UIColor colorWithRed:110/255.0 green:110/255.0 blue:110/255.0 alpha:1.0f]
#define activeButtonTintColor [UIColor colorWithRed:94/255.0 green:201/255.0 blue:217/255.0 alpha:1.0f]

@synthesize imageDispVC = _imageDispVC;
@synthesize vedioVC = _vedioVC;
@synthesize drawingVC = _drawingVC;
@synthesize shoppingVC = _shoppingVC;
@synthesize browser = _browser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Check the UI state
    switch (_viewState) {
        case Calling: {
            // calling someone
            // Load someone's Profile Photo
            
            [_bigProfileImage setImage:[UIImage imageNamed:@"defaultBigPhoto.png"]];
            [UserDataTransUtils getUserBigAvatar:_remotePartyNumber Completion:^(NSString *bigAvatarURL) {
                UIImage *image = [UserDataTransUtils getImageAtPath:bigAvatarURL];
                if (image) {
                    [_bigProfileImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
                }
            }];
            // Make the Photo dark
            _bigProfileImage.alpha = 0.4f;
            // Present all the icons
            [self presentAllCallingIcons];
            // Raise the Bulletin Board
            [self raiseBulletinBoard];
            // Show the indicator
            [self spinActivityIndicator];
            // Add network indicator
            // 因为目前无法检测网络状态,所以不加入此功能
//            [self addNetworkIndicator];
            [[SipStackUtils sharedInstance].soundService enableBackgroundSound];
            shouldPlayRingTone = YES;
            break;
        }
        case ReceivingCall: {
            // called
            // Load Caller's Profile Photo
            [_bigProfileImage setImage:[UIImage imageNamed:@"defaultBigPhoto.png"]];
            [UserDataTransUtils getUserBigAvatar:_remotePartyNumber Completion:^(NSString *bigAvatarURL) {
                UIImage *image = [UserDataTransUtils getImageAtPath:bigAvatarURL];
                if (image) {
                    [_bigProfileImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
                }
            }];
            // Hide the navigation bar
            [self.navigationController.navigationBar setHidden:YES];
            // Hide the toolbar
            [_toolbar setHidden:YES];
            // Add Accept and Reject Button at the bottom
            [self addPickupAndRejectButton];
            // Raise the Caller bulletin board
            [self raiseCallerBulletinBoard];
            shouldPlayRingTone = NO;
            break;
        }
        default: {
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIncomingGettingImageMessage:) name:@"receivedImageNotification" object:nil];
    getImageQueue = dispatch_queue_create("com.ashstudio.getImageQueue", NULL);
    imageSessionExists = NO;
    getIndexArray = NO;
    getMaxNumber = NO;
    videoBeginTime = 0;
    _didEndCallBySelf = NO;
    didEndCall = NO;
    
    if (!IS_OS_7_OR_LATER) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, 320, 44)];
        [_toolbar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        _buttonAdd.tintColor = [UIColor blackColor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (shouldPlayRingTone) {
        [[SipStackUtils sharedInstance].soundService playRingBackTone];
        shouldPlayRingTone = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 当拨打别人或被拨打接通电话后调用, 将界面的外观转换到In Call界面
- (void)changeViewAppearanceToInCall
{
    // 进入In Call 模式
    [self retrieveBulletinBoard];
    // 加入缓慢消失的动画效果
    [callingIndicator setAlpha:0.3f];
    [UIView animateWithDuration:0.5f animations:^{
        [callingIndicator setAlpha:0.0f];
    }completion:^(BOOL finished){
        [callingIndicator.layer removeAllAnimations];
        [callingIndicator removeFromSuperview];
    }];
    // 头像缓慢变亮
    [UIView animateWithDuration:1.2f animations:^{
        [_bigProfileImage setAlpha:1.0f];
    }];

    // Enable the Add button
    [_buttonAdd setEnabled:YES];
    [_buttonAdd setTintColor:activeButtonTintColor];
    // Add Time Label
    [self addTimeLabel];
    
    _viewState = InCall;
}

# pragma mark Calling View Methods
// 加入通话时间Timer
- (void)addTimeLabel
{
    [timeLabel removeFromSuperview];
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-49, 12, 100, 30)];
    if (IS_OS_7_OR_LATER) {
        timeLabel.font = [[UIFont preferredFontForTextStyle:@"UIFontTextStyleBody"] fontWithSize:18.0f];
    }
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [timeLabel setAlpha:0.0f];
    [self.navigationController.navigationBar addSubview:timeLabel];

    timeLabel.textColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.8f];
    timeLabel.backgroundColor = [UIColor clearColor];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    callBeginTime = [[NSDate alloc] init];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
//    [runloop addTimer:timer forMode:UITrackingRunLoopMode];
    
    // 加入缓慢出现的动画效果
    [UIView animateWithDuration:1.2f animations:^{
        [timeLabel setAlpha:1.0f];
    }];
}

// 更新通话时间Label
- (void)updateTimeLabel
{
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:callBeginTime];
    NSInteger minutes = floor(time / 60);
    NSInteger seconds = floor(time - minutes * 60);
    timeLabel.text = [NSString stringWithFormat: @"%02d:%02d",minutes, seconds];
}

// 载入图标的外观
- (void)presentAllCallingIcons
{
    [_buttonMicroPhone setImage:[UIImage imageNamed:@"microPhone.png"]];
    [_buttonMicroPhone setTintColor:inactiveButtonTintColor];
    if (!IS_OS_7_OR_LATER) {
        [_buttonMicroPhone setBackButtonBackgroundImage:[UIImage imageNamed:@"microPhone.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        _buttonMicroPhone.title = Nil;
    }

    [_buttonMicroPhone setTarget:self];
    [_buttonMicroPhone setAction:@selector(pressButtonMicroPhone)];
    _isNoMicroPhoneOn = NO;
    [[SipStackUtils sharedInstance].audioService configureMute:_isNoMicroPhoneOn];
    
    [_buttonSpeaker setImage:[UIImage imageNamed:@"speaker.png"]];
    [_buttonSpeaker setTintColor:inactiveButtonTintColor];
    if (!IS_OS_7_OR_LATER) {
        [_buttonSpeaker setBackButtonBackgroundImage:[UIImage imageNamed:@"speaker.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        _buttonSpeaker.title = Nil;
    }
    [_buttonSpeaker setTarget:self];
    [_buttonSpeaker setAction:@selector(pressButtonSpeaker)];
    _isSpeakerOn = NO;
    [[SipStackUtils sharedInstance].soundService configureSpeakerEnabled:_isSpeakerOn];
    
    [_buttonAdd setImage:[UIImage imageNamed:@"add.png"]];
    [_buttonAdd setTintColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0f]];
    [_buttonAdd setAction:@selector(pressButtonAdd)];
    [_buttonAdd setEnabled:NO];
    if (!IS_OS_7_OR_LATER) {
        _buttonAdd.title = nil;
    }
    
    [_buttonEndCall setImage:[UIImage imageNamed:@"end.png"]];
    if (IS_OS_7_OR_LATER) {
        [_buttonEndCall setTintColor:[UIColor colorWithWhite:0.96 alpha:1.0f]];
    }
    else
    {
        [_buttonEndCall setTintColor:[UIColor colorWithRed:213/255.0 green:11/255.0 blue:11/255.0 alpha:1.0f]];
    }
    [_buttonEndCall setTarget:self];
    [_buttonEndCall setAction:@selector(pressButtonEndCall)];
//    UIImageView *buttonEndCallBackground = [[UIImageView alloc] initWithFrame:CGRectMake(320-63, 0, 126, 88)];
//    buttonEndCallBackground.backgroundColor = [UIColor colorWithRed:213/255.0 green:11/255.0 blue:11/255.0 alpha:1.0f];
    UIButton *buttonEndCallBackground = [[UIButton alloc] initWithFrame:CGRectMake(320-63, 0, 126, 44)];
    if (IS_OS_7_OR_LATER) {
        buttonEndCallBackground.backgroundColor = [UIColor colorWithRed:213/255.0 green:11/255.0 blue:11/255.0 alpha:1.0f];
    }
    _buttonEndCall.title = nil;
    [buttonEndCallBackground addTarget:self action:@selector(pressButtonEndCall) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar insertSubview:buttonEndCallBackground atIndex:0];
}

// 升起被呼叫方的名字和指示牌
- (void)raiseBulletinBoard
{
    // 被叫者名字和"拨号中"指示文字
    UILabel *herName = [[UILabel alloc] initWithFrame:CGRectMake(160 - 200/2, 0, 200, 40)];
    herName.text = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:_remotePartyNumber];
    if (herName.text == nil) {
        herName.text = [[MainHistoryDataAccessor sharedInstance] getNameForRemoteParty:_remotePartyNumber];
    }
//    herName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
    if (IS_OS_7_OR_LATER) {
        herName.font = [[UIFont preferredFontForTextStyle:@"UIFontTextStyleHeadline"]fontWithSize:18.0f];
    }
    herName.textAlignment = NSTextAlignmentCenter;
    herName.textColor = [UIColor blackColor];
    herName.backgroundColor = [UIColor clearColor];
    UILabel *callingLabel = [[UILabel alloc] initWithFrame:CGRectMake(160 - 200/2, 25, 200, 40)];
    _calling = callingLabel;
    _calling.text = NSLocalizedString(@"connecting", nil);
    if (IS_OS_7_OR_LATER) {
        _calling.font = [[UIFont preferredFontForTextStyle:@"UIFontTextStyleFootnote"] fontWithSize:16.0f];
    }
    _calling.textAlignment = NSTextAlignmentCenter;
    _calling.textColor = [UIColor colorWithRed:165/255.0 green:165/255.0 blue:162/255.0 alpha:1.0f];
    _calling.backgroundColor = [UIColor clearColor];
    
    // bulletin board和toolbar之间的分割线
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [lineView removeFromSuperview];
    lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight - 45, 320, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6f];
    [self.view addSubview:lineView];
    
    [bulletinBoard removeFromSuperview];
    if (IS_OS_7_OR_LATER) {
        bulletinBoard = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight - 45, 320, 0)];
    }
    else
    {
        bulletinBoard = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenHeight - 45 - 60, 320, 0)];
    }
    bulletinBoard.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8f];
    [self.view addSubview:bulletinBoard];
    
    CGRect frame = bulletinBoard.frame;
    frame.size.height = 60.0f;
    frame.origin.y = frame.origin.y - frame.size.height;
    
    [UIView animateWithDuration:0.5f animations:^{
        bulletinBoard.frame = frame;
    } completion:^(BOOL finished){
        [bulletinBoard addSubview:herName];
        [bulletinBoard addSubview:callingLabel];
    }];
}

- (void)retrieveBulletinBoard
{
    [lineView removeFromSuperview];
    for (UIView *viewsInBulletinBoard in [bulletinBoard subviews]) {
        [viewsInBulletinBoard removeFromSuperview];
    }
    CGRect frame = bulletinBoard.frame;
    CGFloat height = frame.size.height;
    frame.size.height = 0.0f;
    frame.origin.y = frame.origin.y + height;
    [UIView animateWithDuration:0.3f animations:^{
        bulletinBoard.frame = frame;
    } completion:^(BOOL finished){
        [bulletinBoard removeFromSuperview];
    }];
}

// 载入事件读取指示器并开始转动
- (void)spinActivityIndicator
{
    // 加入指示器
    [callingIndicator removeFromSuperview];
    callingIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(160 - 10, 13, 25, 25)];
    callingIndicator.image = [UIImage imageNamed:@"callingIndicatorSpin.png"];
    [self.navigationController.navigationBar addSubview:callingIndicator];
 
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * 1 * 1 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [callingIndicator.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

// 开始响铃
- (void)ringTheBell
{
    
}

// 加入网络状况指示器
- (void)addNetworkIndicator
{
    [networkIndicator removeFromSuperview];
    networkIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(290, 23, 15, 8)];
    networkIndicator.image = [UIImage imageNamed:@"networkIndicatorGood.png"];
    [self.navigationController.navigationBar addSubview:networkIndicator];
}

// 根据当前网络状况改变指示器外观
- (void)changeNetworkIndicatorAppearance: (CGFloat)networkCondition
{
    // networkCondition取值范围为0.0到1.0之间
    if (networkCondition < 0.0f) {
        networkCondition = 0.0f;
    }
    else if (networkCondition > 1.0f) {
        networkCondition = 1.0f;
    }
    
    if (networkCondition < 0.33f) {
        networkIndicator.image = [UIImage imageNamed:@"networkIndicatorBad.png"];
    }
    else if (networkCondition < 0.66f) {
        networkIndicator.image = [UIImage imageNamed:@"networkIndicatorMedium.png"];
    }
    else {
        networkIndicator.image = [UIImage imageNamed:@"networkIndicatorGood.png"];
    }
}

- (void)pressButtonMicroPhone
{
    if (_isNoMicroPhoneOn) {
        // deactivate this button
        [_buttonMicroPhone setTintColor:inactiveButtonTintColor];
        // show the UIActivityView
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"micOn.png"] status:NSLocalizedString(@"micOn", nil)];
    }
    else {
        [_buttonMicroPhone setTintColor:activeButtonTintColor];
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"micOff.png"] status:NSLocalizedString(@"micOff", nil)];
    }
    _isNoMicroPhoneOn = !_isNoMicroPhoneOn;
    [[SipStackUtils sharedInstance].audioService configureMute:_isNoMicroPhoneOn];
}

- (void)pressButtonSpeaker
{
    if (_isSpeakerOn) {
        // deactivate this button
        [_buttonSpeaker setTintColor:inactiveButtonTintColor];
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"speakerOff.png"] status:NSLocalizedString(@"speakerOff", nil)];
    }
    else {
        // activate this button
        [_buttonSpeaker setTintColor:activeButtonTintColor];
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"speakerOn.png"] status:NSLocalizedString(@"speakerOn", nil)];
    }
    // record current button state
    _isSpeakerOn = !_isSpeakerOn;
    [[SipStackUtils sharedInstance].soundService configureSpeakerEnabled:_isSpeakerOn];
}

- (void)pressButtonAdd
{
    if (menuBar) {
        if (menuBar.isShow==YES) {
            [menuBar dismiss];
            return;
        }
    }
    
    UIImage *blurUIImage = [_bigProfileImage.image drn_boxblurImageWithBlur:0.3f];
    _blurImage.image = blurUIImage;
    _blurImage.alpha = 0.0f;

    CGSize size = CGSizeMake(self.view.bounds.size.width / 3.0, 229 / 2.0);
    QianLiUIMenuBarItem *item = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"callingPhoto", nil) target:self image:[UIImage imageNamed:@"MenuBarItemPhoto.png"] action:@selector(selectPhoto) size:size];
    QianLiUIMenuBarItem *cameraItem = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"Camera", nil) target:self image:[UIImage imageNamed:@"MenuBarItemCamera.png"] action:@selector(selectCamera) size:size];
    QianLiUIMenuBarItem *videoItem = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"callingVideo", nil) target:self image:[UIImage imageNamed:@"MenuBarItemVideo.png"] action:@selector(selectVideo) size:size];
    QianLiUIMenuBarItem *drawItem = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"doodle", nil) target:self image:[UIImage imageNamed:@"MenuBarItemDoodle.png"] action:@selector(selectHandWriting) size:size];
    QianLiUIMenuBarItem *shoppingItem = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"callingShopping", nil) target:self image:[UIImage imageNamed:@"MenuBarItemShopping.png"] action:@selector(selectShopping) size:size];
    QianLiUIMenuBarItem *browserItem = [[QianLiUIMenuBarItem alloc] initWithTitle:NSLocalizedString(@"callingBrowser", nil) target:self image:[UIImage imageNamed:@"MenuBarItemBrowser.png"] action:@selector(selectBrowser) size:size];
    
    menuBar = [[QianLiUIMenuBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 229.0f) items:@[item, cameraItem, drawItem, videoItem, shoppingItem,browserItem]];
    menuBar.delegate = self;
    [menuBar show];

    CGRect moveToolBarFrame = _toolbar.frame;
    moveToolBarFrame.origin.y = moveToolBarFrame.origin.y - 230.0f;
    
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        _toolbar.frame = moveToolBarFrame;
        _blurImage.alpha = 1.0f;
    }];
}

- (void)pressButtonEndCall
{
    [[SipStackUtils sharedInstance].audioService hangUpCall];
    [[SipStackUtils sharedInstance].soundService disableBackgroundSound];
    [timer invalidate]; // 停止计时并从Runloop中释放
    
    _didEndCallBySelf = YES;
    if (_viewState == InCall) {
        _activeEvent.end = [[NSDate date] timeIntervalSince1970];
        [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
    }
    else if (_viewState == Calling){
        _activeEvent.end = [[NSDate date] timeIntervalSince1970];
        _activeEvent.status = HistoryEventStatus_OutgoingCancelled;
        [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
    }
    
    // TODO: 寻求更健壮的方案
    // 本地强制结束
    
    // 如果Menu Bar升起则将其dismiss
    if (menuBar) {
        [menuBar dismiss];
        menuBar=nil;
    }
    
    // starts timer suicide
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector: @selector(timerSuicideTick)
                                   userInfo: nil
                                    repeats: NO];
}

# pragma mark Receieve a Call View Methods

// 加入接听和拒绝按钮
- (void)addPickupAndRejectButton
{
    CGRect frame = self.view.frame;
    [pickupTheCall removeFromSuperview];
    [rejectTheCall removeFromSuperview];
    pickupTheCall = [[UIButton alloc] initWithFrame:CGRectMake(160, frame.size.height - 67, 160, 67)];
    rejectTheCall = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height - 67, 160, 67)];
    [pickupTheCall setImage:[UIImage imageNamed:@"pickupTheCall.png"] forState:UIControlStateNormal];
    [rejectTheCall setImage:[UIImage imageNamed:@"rejectTheCall.png"] forState:UIControlStateNormal];
    [rejectTheCall addTarget:self action:@selector(pressRejectButton) forControlEvents:UIControlEventTouchUpInside];
    [pickupTheCall addTarget:self action:@selector(pressAcceptButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickupTheCall];
    [self.view addSubview:rejectTheCall];
}

// 升起呼叫人名字面板
- (void)raiseCallerBulletinBoard
{
    CGRect viewFrame = self.view.frame;
    CGFloat viewHeight = viewFrame.size.height;
    // 被叫者名字和"拨号中"指示文字
    UILabel *herName = [[UILabel alloc] initWithFrame:CGRectMake(160 - 200/2, 0, 200, 40)];
    NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:_remotePartyNumber];
    if (name) {
        herName.text = name;
    }
    else {
        herName.text = _remotePartyNumber;
        [UserDataTransUtils getUserData:[[SipStackUtils sharedInstance] getRemotePartyNumber] Completion:^(NSString *name, NSString *avatarURL) {
            herName.text = name;
            [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:_remotePartyNumber Content:NSLocalizedString(@"historyReceivedCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"InComingCall"];
             [Utils updateMainHistNameForRemoteParty: _remotePartyNumber];
        }];
    }
    //    herName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
    if (IS_OS_7_OR_LATER) {
        herName.font = [[UIFont preferredFontForTextStyle:@"UIFontTextStyleHeadline"]fontWithSize:18.0f];
    }
    herName.textAlignment = NSTextAlignmentCenter;
    UILabel *calling = [[UILabel alloc] initWithFrame:CGRectMake(160 - 200/2, 25, 200, 40)];
    calling.text = NSLocalizedString(@"callingComingCallText", nil);
    if (IS_OS_7_OR_LATER) {
        calling.font = [[UIFont preferredFontForTextStyle:@"UIFontTextStyleFootnote"]fontWithSize:16.0f];
    }
    calling.textAlignment = NSTextAlignmentCenter;
    calling.textColor = [UIColor colorWithRed:165/255.0 green:165/255.0 blue:162/255.0 alpha:1.0f];
    
    // bulletin board和toolbar之间的分割线
    [lineView removeFromSuperview];
    lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, viewHeight - 68, 320, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6f];
    [self.view addSubview:lineView];
    
    [bulletinBoard removeFromSuperview];
    bulletinBoard = [[UIImageView alloc] initWithFrame:CGRectMake(0, viewHeight - 68, 320, 0)];
    bulletinBoard.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9f];
//    bulletinBoard.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2f];
    [self.view addSubview:bulletinBoard];
    
    CGRect frame = bulletinBoard.frame;
    frame.size.height = 60.0f;
    frame.origin.y = frame.origin.y - frame.size.height;
    
    [UIView animateWithDuration:0.5f animations:^{
        bulletinBoard.frame = frame;
    } completion:^(BOOL finished){
        [bulletinBoard addSubview:herName];
        [bulletinBoard addSubview:calling];
    }];
}

- (void)retrieveCallerBulletionBoard
{
    [lineView removeFromSuperview];
    [bulletinBoard removeFromSuperview];
}

// 按下拒绝接听按钮
- (void)pressRejectButton
{
    [[SipStackUtils sharedInstance].audioService hangUpCall];
    [PictureManager endImageSession:[[PictureManager sharedInstance] getImageSession] Success:^(BOOL success) {
        
    }];
    
    _didEndCallBySelf = YES;
    _activeEvent.end = [[NSDate date] timeIntervalSince1970];
    if (_activeEvent.status == HistoryEventStatus_Incoming) {
        _activeEvent.status = HistoryEventStatus_IncomingRejected;
    }
    [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
}

// 按下接听按钮
- (void)pressAcceptButton
{
    if([[SipStackUtils sharedInstance].audioService doesExistOnGoingAudioSession]){
        if (_viewState == ReceivingCall) {
            [[SipStackUtils sharedInstance].audioService acceptCall];
        }
    }
    
    [pickupTheCall removeFromSuperview];
    [rejectTheCall removeFromSuperview];
    [self retrieveCallerBulletionBoard];
    [_toolbar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    [self presentAllCallingIcons];
    // 因为目前无法检测网络状态,所以不加入此功能
//    [self addNetworkIndicator];
    [self changeViewAppearanceToInCall];
    
    [[SipStackUtils sharedInstance].soundService enableBackgroundSound];
}

#pragma mark QianLiUIMenuBar delegate Method
- (void)menuBarWillDismiss
{
    CGRect moveToolBarFrame = _toolbar.frame;
    moveToolBarFrame.origin.y = moveToolBarFrame.origin.y + 230.0f;
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        _toolbar.frame = moveToolBarFrame;
        _blurImage.alpha = 0.0f;
    }];
}

- (void)openSpeaker
{
    if (_isSpeakerOn) {
        return;
    }
    _isSpeakerOn = YES;
    [_buttonSpeaker setTintColor:activeButtonTintColor];
    [[SipStackUtils sharedInstance].soundService configureSpeakerEnabled:_isSpeakerOn];
}

#pragma mark touch Menu Bar Item
- (void)selectPhoto
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AssetGroupPickerController *assetVC = [storyboard instantiateViewControllerWithIdentifier:@"AssetGroupPickerVC"];
    assetVC.delegate = self;
    
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[assetVC];
    _selectPhotoViewController = navigationVC;
    [self presentViewController:navigationVC animated:YES completion:nil];
    
    NSString * seID = [[PictureManager sharedInstance] getImageSession];
    
    [PictureManager registerImageTransSession: seID Success:^(BOOL success) {
        imageSessionExists = YES;
        [[SipStackUtils sharedInstance].messageService sendMessage:kBeginImage toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    }];
    [menuBar dismiss];
    [self openSpeaker];
    
    [MobClick event:@"selectPhoto"];
}

- (void)selectCamera
{
    CameraViewController *cameraCV = [[CameraViewController alloc] init];
    cameraCV.delegate = self;
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[cameraCV];
    [self presentViewController:navigationVC animated:YES completion:nil];
    
    NSString * seID = [[PictureManager sharedInstance] getImageSession];
    [PictureManager registerImageTransSession: seID Success:^(BOOL success) {
        imageSessionExists = YES;
        [[SipStackUtils sharedInstance].messageService sendMessage:kBeginImage toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    }];
    [menuBar dismiss];
    [self openSpeaker];
    
    [MobClick event:@"selectCamera"];
}

- (void)selectVideo
{
    videoBeginTime = [[NSDate date] timeIntervalSince1970];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _vedioVC = [storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    _vedioVC.isIncoming = NO;
    _vedioVC.url = @"http://www.youku.com/";
    NSString *message = [NSString stringWithFormat:@"%@%@%@%@%f", kBeginVideo, kSeparator, _vedioVC.url, kSeparator, videoBeginTime];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[_vedioVC];
    [self presentViewController:navigationVC animated:YES completion:nil];
    [menuBar dismiss];
    [self openSpeaker];
    
    // add to main story
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"watchVideo", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoingVideoWatching"];
    [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [MobClick event:@"selectVideo"];
}

- (void)selectHandWriting
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _drawingVC = [storyboard instantiateViewControllerWithIdentifier:@"DrawingViewController"];
    [[SipStackUtils sharedInstance].messageService sendMessage:kHandDrawing toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[_drawingVC];
    if (!IS_OS_7_OR_LATER) {
        [navigationVC.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self presentViewController:navigationVC animated:YES completion:nil];
    [menuBar dismiss];
    [self openSpeaker];
    // add to main story
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"handWriting", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoingHandDrawing"];
    [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    [MobClick event:@"selectHandWriting"];
}

- (void)selectShopping
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _shoppingVC = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    _shoppingVC.inComing = NO;
    _shoppingVC.initialURL = @"http://www.taobao.com/";
    [[SipStackUtils sharedInstance].messageService sendMessage:kBeginShopping toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[_shoppingVC];
    [self presentViewController:navigationVC animated:YES completion:nil];
    [menuBar dismiss];
    [self openSpeaker];
    // add to main story
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"webBrowsing", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoingWebBrowsing"];
     [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [MobClick event:@"selectShopping"];
}

- (void)selectBrowser
{
    // 发送同步信息
    [[SipStackUtils sharedInstance].messageService sendMessage:kBeginBrowser toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    [self showBrowserVC];
    [MobClick event:@"selectBrowser"];
}

#pragma mark --SelectedImageDelegate

- (void)didFinishSelectingImage:(NSArray *)imageArray
{
    if ([imageArray count] == 0 || !imageSessionExists) {
        return;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:imageArray repeats:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _imageDispVC = [storyboard instantiateViewControllerWithIdentifier:@"ImageDisplayVC"];
    _imageDispVC.isIncoming = NO;
    [self.navigationController pushViewController:_imageDispVC animated:YES];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:imageArray];
    _imageDispVC.images = array;
    
    [PictureManager startImageTransSession:[imageArray count] SessionID:[[PictureManager sharedInstance] getImageSession] Success:^(NSInteger baseIndex) {
        NSMutableArray *indexArray = [NSMutableArray array];
        for (int i = 0; i < [imageArray count]; ++i) {
            [indexArray addObject:[NSString stringWithFormat:@"%d", i + baseIndex]];
        }
        _imageDispVC.indexs = indexArray;
        getIndexArray = YES;
    }];
    
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"shareImage", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoingImage"];
     [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

- (void)handleTimer:(NSTimer *)imageTimer
{
    if (getMaxNumber) {
        getMaxNumber = NO;
        [_imageDispVC displayImages];
        [imageTimer invalidate];
    }
    
    if (getIndexArray) {
        getIndexArray = NO;
        [PictureManager getMaximumIndex:[[PictureManager sharedInstance] getImageSession] Success:^(NSInteger number) {
            _imageDispVC.totalNumber = number;
            getMaxNumber = YES;
        }];
        
        [PictureManager putImages:imageTimer.userInfo SessionID:[[PictureManager sharedInstance] getImageSession] StartIndex:[[_imageDispVC.indexs objectAtIndex:0] integerValue] Receiver:nil Sender:nil Success:^(NSArray *info) {
            NSString *str = [NSString stringWithFormat:@"%@%@%@",kImagePath,kSeparator,[info objectAtIndex:0]];
            [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:_remotePartyNumber];
        } Completion:^(BOOL finished) {
            [[SipStackUtils sharedInstance].messageService sendMessage:kImageTransCompletion toRemoteParty:_remotePartyNumber];
        }];
    }
}

- (void)onInviteEvent:(NSNotification*)notification
{
	NgnInviteEventArgs* eargs = [notification object];
	if(![[SipStackUtils sharedInstance].audioService doesExistOnGoingAudioSession] || _audioSessionID != eargs.sessionId){
		return;
	}
	
    [self updateViewAndState];
	switch (eargs.eventType) {
		case INVITE_EVENT_INPROGRESS:
		case INVITE_EVENT_INCOMING:
		case INVITE_EVENT_RINGING:
            break;
		case INVITE_EVENT_LOCAL_HOLD_OK:
		case INVITE_EVENT_REMOTE_HOLD:
		default:
		{
			// updates view and state
			break;
		}
            // transilient events
		case INVITE_EVENT_MEDIA_UPDATING:
		{
			break;
		}
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			break;
		}
		case INVITE_EVENT_TERMWAIT:
        case INVITE_EVENT_TERMINATED:
		{
			// updates view and state
			// releases session
			// starts timer suicide
            //[[SipStackUtils sharedInstance].audioService releaseAudioSession];
			[NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target: self
                                           selector: @selector(timerSuicideTick)
                                           userInfo: nil
                                            repeats: NO];
			break;
		}
	}
}

- (void)timerSuicideTick
{
    if (didEndCall) {
        return;
    }
    didEndCall = YES;
    [[SipStackUtils sharedInstance].soundService configureSpeakerEnabled:YES];
    [[SipStackUtils sharedInstance].soundService disableBackgroundSound];
  
    //LLGG
   [self dismissViewControllerAnimated:YES completion:nil];
   //[self changeViewAppearanceToInCall];
    
    if (!_didEndCallBySelf) {
        if (_viewState == InCall) {
            _activeEvent.end = [[NSDate date] timeIntervalSince1970];
            [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
        }
        else if (_viewState == Calling){
            _activeEvent.status = HistoryEventStatus_OutgoingRejected;
            _activeEvent.end = [[NSDate date] timeIntervalSince1970];
            [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
        }
        else if (_viewState == ReceivingCall){
            _activeEvent.status = HistoryEventStatus_IncomingCancelled;
            _activeEvent.end = [[NSDate date] timeIntervalSince1970];
            [[SipStackUtils sharedInstance].historyService addEvent:_activeEvent];
        }
    }
}

- (void)hasCall
{
    //add some code
}

-(void) updateViewAndState{
	if([[SipStackUtils sharedInstance].audioService doesExistOnGoingAudioSession]){
		switch ([[SipStackUtils sharedInstance].audioService getAudioSessionState]) {
			case INVITE_STATE_INPROGRESS:
			{
                break;
			}
			case INVITE_STATE_INCOMING:
			{
				break;
			}
			case INVITE_STATE_REMOTE_RINGING:
			{
				//self.labelStatus.text = @"Remote is ringing";
                _calling.text = NSLocalizedString(@"callingRingingText", nil);
				break;
			}
			case INVITE_STATE_INCALL:
			{
                [[SipStackUtils sharedInstance].soundService stopRingBackTone];
                [[SipStackUtils sharedInstance].soundService stopRingTone];
                [self hasCall];
                [self changeViewAppearanceToInCall];
				break;
			}
			case INVITE_STATE_TERMINATED:
			case INVITE_STATE_TERMINATING:
			{
                [[SipStackUtils sharedInstance].soundService stopRingBackTone];
                [[SipStackUtils sharedInstance].soundService stopRingTone];
				break;
			}
			default:
				break;
		}
    }
}

- (void)showImageVC
{
    [menuBar dismiss];
    if (!_imageDispVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _imageDispVC = [storyboard instantiateViewControllerWithIdentifier:@"ImageDisplayVC"];
        _imageDispVC.images = [[NSMutableArray alloc] init];
        _imageDispVC.indexs = [[NSMutableArray alloc] init];
        _imageDispVC.totalNumber = 0;
        _imageDispVC.isIncoming = YES;
        [self.navigationController pushViewController:_imageDispVC animated:YES];
    }
}

- (void)showDrawingVC
{
    [menuBar dismiss];
    if (!_drawingVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _drawingVC = [storyboard instantiateViewControllerWithIdentifier:@"DrawingViewController"];
        UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
        navigationVC.viewControllers = @[_drawingVC];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

- (void)showShoppingVC
{
    [menuBar dismiss];
    if (!_shoppingVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        _shoppingVC = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        _shoppingVC.initialURL = @"http://www.taobao.com/";
        UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
        navigationVC.viewControllers = @[_shoppingVC];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

- (void)showBrowserVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _browser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowser"];
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[_browser];
    [self presentViewController:navigationVC animated:YES completion:nil];
    [menuBar dismiss];
    [self openSpeaker];
}

- (void)receiveIncomingGettingImageMessage:(NSNotification *)notification
{
    NSString *info = notification.object;
    NSArray* words = [info componentsSeparatedByString:kSeparator];
    NSString *message;
    if ([words count] > 0) {
       message = [words objectAtIndex:0];
    }
    
    if ([message isEqualToString:kBeginImage]) {
        [self openSpeaker];
        [self showImageVC];
        [_imageDispVC displaySelectingState];
    }
    else if ([message isEqualToString:kImagePath]) {
        //[self showImageVC];
        if ([_imageDispVC.indexs indexOfObject:[words objectAtIndex:1]] == NSNotFound) {
            NSString *sID = [[PictureManager sharedInstance] getImageSession];
            [PictureManager getMaximumIndex:sID Success:^(NSInteger number) {
                _imageDispVC.totalNumber = number;
                dispatch_async(getImageQueue, ^{
                    NSString *path = [NSString stringWithFormat:@"%@",[words objectAtIndex:1]];
                    NSData * imageData = [PictureManager getImageAtPath:path];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if ([_imageDispVC.indexs indexOfObject:[words objectAtIndex:1]] == NSNotFound) {
                        UIImage *image = [UIImage imageWithData:imageData];
                            if (image) {
                                [_imageDispVC.images addObject:image];
                                [_imageDispVC.indexs addObject:[words objectAtIndex:1]];
                                [_imageDispVC displayImages];
                            }
                    }
                    });
                });
            }];
        }
    }
    else if ([message isEqualToString:kAddNewImage]){
        //_imageDispVC.totalNumber = _imageDispVC.totalNumber + 1;
//        [_imageDispVC displaySelectingState];
//        [_imageDispVC scrollTO:_imageDispVC .totalNumber * PageWidth];
    }
    else if ([message isEqualToString:kNewImageComing]) {
        [_imageDispVC scrollTO:_imageDispVC.totalNumber * PageWidth];
    }
    else if ([message isEqualToString:kImageDispCancel]){
        if (_selectPhotoViewController) {
            [_selectPhotoViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [_imageDispVC cancelFromRemoteyParty];
    }
    else if ([message isEqualToString:kCancelAddImage]){
        if ([_imageDispVC.images count] == 0) {
            [_imageDispVC cancelFromRemoteyParty];
        }
        else{
           // _imageDispVC.totalNumber = _imageDispVC.totalNumber - 1;
            [_imageDispVC displayImages];
        }
    }
    else if ([message isEqualToString:kScrollOffset]){
        if ([[words objectAtIndex:1] floatValue] < _imageDispVC.totalNumber * PageWidth) {
            //[self showImageVC];
            [_imageDispVC scrollTO:[[words objectAtIndex:1] floatValue]];
        }
    }
    else if ([message isEqualToString:kDoodleImageIndex]){
       // [self showImageVC];
        [_imageDispVC doodleWithImageIndex:[[words objectAtIndex:1] integerValue]];
    }
    else if ([message isEqualToString:kDoodleImagePoints]){
       // [self showImageVC];
        NSArray *coord = [[words objectAtIndex:2] componentsSeparatedByString:@":"];
        NSMutableArray *points = [NSMutableArray array];
        for (int i = 0; i < [coord count] / 2; ++i) {
            CGPoint p;
            p.x = [[coord objectAtIndex:i * 2] floatValue];
            p.y = [[coord objectAtIndex:i * 2 + 1] floatValue];
            NSValue *pValue = [NSValue valueWithCGPoint:p];
            [points addObject:pValue];
        }
        [_imageDispVC.doodleView drawingOnImageWithPoints:points Drawing:[[words objectAtIndex:1] isEqualToString:@"DRAW"]];
    }
    else if ([message isEqualToString:kDoodleCancel]){
//        [self showImageVC];
        if (_imageDispVC) {
            [_imageDispVC cancelDoodleFromRemoteyParty];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if ([message isEqualToString:kImageTransCompletion]){
        //[self showImageVC];
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"shareImage", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"InComingImage"];
         [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
        NSString *sID = [[PictureManager sharedInstance] getImageSession];
        [PictureManager getMaximumIndex:sID Success:^(NSInteger number) {
            _imageDispVC.totalNumber = number;
            if ([_imageDispVC.indexs count] != number) {
                for (int i = 0; i < number; ++i) {
                    NSInteger ind = [_imageDispVC.indexs indexOfObject:[NSString stringWithFormat:@"%d",i]];
                    if (ind == NSNotFound) {
                        dispatch_async(getImageQueue, ^{
                            NSData * imageData = [PictureManager getImageAtPath:[NSString stringWithFormat:@"%d",i]];
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                if ([_imageDispVC.indexs indexOfObject:[NSString stringWithFormat:@"%d",i]] == NSNotFound) {
                                UIImage *image = [UIImage imageWithData:imageData];
                                    if (image) {
                                        [_imageDispVC.indexs addObject:[NSString stringWithFormat:@"%d",i]];
                                        [_imageDispVC.images addObject:image];
                                        [_imageDispVC displayImages];
                                    }
                                }
                            });
                        });
                        
                    }
                }
            }
        }];
    }
    
    // Play video
    else if ([message isEqualToString:kBeginVideo]){
        [menuBar dismiss];
        if ([words count] == 3) {
            [self openSpeaker];
            if (!_vedioVC) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                _vedioVC = [storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
                _vedioVC.url = [words objectAtIndex:1];
                
                UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
                navigationVC.viewControllers = @[_vedioVC];
                [self presentViewController:navigationVC animated:YES completion:nil];
            }
            else{
                double beginTime = [[words objectAtIndex:2] doubleValue];
                if (videoBeginTime > beginTime) {
                    _vedioVC.url = [words objectAtIndex:1];
                    [_vedioVC loadWebSite];
                }
            }
            _vedioVC.isIncoming = YES;
            // add to main story
            [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"watchVideo", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"IncomingVideoWatching"];
             [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
        }
    }
    
    else if ([message isEqualToString:kPlayVideo]){
        if ([words count] == 2) {
            _vedioVC.url = [words objectAtIndex:1];
            [_vedioVC playMovieStream:[NSURL URLWithString:[words objectAtIndex:1]]];
        }
    }
    else if ([message isEqualToString:kVideoPlayerCancel]){
        [_vedioVC cancelPlayerFromRemote];
    }
    
    else if ([message isEqualToString:kVideoCancel]){
        [_vedioVC cancelFromRemote];
    }
    
    else if([message isEqualToString:kVideoForward]){
        NSString *currentTime = [words objectAtIndex:1];
        [_vedioVC forwardFromRemote:[currentTime floatValue]];
    }
    
    else if([message isEqualToString:kVideoBackward]){
        NSString *currentTime = [words objectAtIndex:1];
        [_vedioVC backwardFromRemote:[currentTime floatValue]];
    }
    
    else if([message isEqualToString:kVideoPaused]){
        NSString *paused = [words objectAtIndex:1];
        [_vedioVC pauseFromRemote:[paused boolValue]];
    }
    
    else if ([message isEqualToString:kHandDrawing]){
        [self openSpeaker];
        [self showDrawingVC];
        // add to main story
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:[NSString stringWithFormat:NSLocalizedString(@"handWriting", nil), [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]]] Time:[[NSDate date] timeIntervalSince1970] Type:@"IncomingHandDrawing"];
         [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
    }
    
    else if ([message isEqualToString:kDrawingPoints]){
        //[self showDrawingVC];
        NSArray *coord = [[words objectAtIndex:2] componentsSeparatedByString:@":"];
        NSMutableArray *points = [NSMutableArray array];
        for (int i = 0; i < [coord count] / 2; ++i) {
            CGPoint p;
            p.x = [[coord objectAtIndex:i * 2] floatValue];
            p.y = [[coord objectAtIndex:i * 2 + 1] floatValue];
            NSValue *pValue = [NSValue valueWithCGPoint:p];
            [points addObject:pValue];
        }
        [_drawingVC.drawingView drawingOnImageWithPoints:points Drawing:[[words objectAtIndex:1] isEqualToString:@"DRAW"]];
    }
    else if ([message isEqualToString:kCancelDrawing]){
        [_drawingVC cancelFromRemoteParty];
    }
    
    else if ([message isEqualToString:kBeginShopping]){
        [self openSpeaker];
        [self showShoppingVC];
        _shoppingVC.inComing = YES;
        // add to main story
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"webBrowsing", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"IncomgingWebBrowsing"];
         [Utils updateMainHistNameForRemoteParty: [[SipStackUtils sharedInstance] getRemotePartyNumber]];
    }
    
    else if ([message isEqualToString:kCancelShopping]){
        [_shoppingVC cancelFromRemoteParty];
    }
    
    else if ([message isEqualToString:kShoppingSyn]){
        if ([words count] == 4) {
            // ACK
            NSString *message = [NSString stringWithFormat:@"%@", kSynReceived];
            [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
        
            CGPoint offset;
            offset.x = [[words objectAtIndex:2] floatValue];
            offset.y = [[words objectAtIndex:3] floatValue];
            _shoppingVC.remoteOffset = offset;
            
            _shoppingVC.remoteURL = [words objectAtIndex:1];
            _shoppingVC.fromRemote = YES;
            // 调整一些讨厌的URL
            if ([_shoppingVC.remoteURL isEqualToString:@"http://cdn.tanx.com/t/acookie/acbeacon2.html"]) {
                _shoppingVC.remoteURL = @"http://m.taobao.com/";
            }
            [_shoppingVC loadWebWithURL:_shoppingVC.remoteURL];
        }
    }
    
    else if ([message isEqualToString:kBrowserSyn]) {
        if ([words count] == 4) {
            // ACK
            NSString *message = [NSString stringWithFormat:@"%@", kSynReceived];
            [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
            
            CGPoint offset;
            offset.x = [[words objectAtIndex:2] floatValue];
            offset.y = [[words objectAtIndex:3] floatValue];
            _browser.remoteOffset = offset;
            _browser.remoteURL = [words objectAtIndex:1];
            _browser.fromRemote = YES;
            // 调整一些讨厌的URL
            if ([_browser.remoteURL isEqualToString:@"http://cdn.tanx.com/t/acookie/acbeacon2.html"]) {
                _browser.remoteURL = @"http://m.taobao.com/";
            }
            [_browser loadWebWithURL:_browser.remoteURL];
        }
    }
    
    else if ([message isEqualToString:kBeginBrowser]){
        [self showBrowserVC];
    }
    else if ([message isEqualToString:kCancelBrowser]) {
        if (_browser) {
            [_browser cancelFromRemoteParty];
        }
    }
    
    else if ([message isEqualToString:kSynReceived]){
        if (_shoppingVC) {
            [_shoppingVC synSuccessed];
        }
        if (_browser) {
            [_browser synSuccessed];
        }
    }
    
    else if ([message isEqualToString:kLongPressIndicator]){
        CGPoint location = CGPointMake([[words objectAtIndex:1] floatValue],[[words objectAtIndex:2] floatValue]);
        [_imageDispVC showLongPressIndicator:location];
    }
}

@end
