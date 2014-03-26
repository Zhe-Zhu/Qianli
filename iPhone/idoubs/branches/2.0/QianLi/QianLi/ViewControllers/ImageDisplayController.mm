//
//  ImageDisplayController.m
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//  CODEREVIEW DONE

#import "ImageDisplayController.h"
#import "SipStackUtils.h"
#import "MobClick.h"
#import "Utils.h"
#import "SVProgressHUD.h"
#import "Global.h"


//CODE_REVIEW: 可以用NSDictory变量来代替indexs和images变量。
@interface ImageDisplayController (){
    UILongPressGestureRecognizer *_longPress;
    UITapGestureRecognizer *_tapGesture;
    CGPoint firstPoint;
}

@property(nonatomic) NSInteger currentPage;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UILabel *indicator;
@property (weak, nonatomic) DoodleBackView *doodlebackView;
@property(nonatomic) double starTime;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doodleButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) UINavigationController *addMoreImagesController;
@property (weak, nonatomic) UIView *doodleToolBar;
@property (weak, nonatomic) UIActionSheet *chooesPhoto;
- (IBAction)addMoreImage:(id)sender;
- (IBAction)doodle:(id)sender;

@end

@implementation ImageDisplayController

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
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", Nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, PageWidth, 377)];
    CGRect scrollViewFrame;
    scrollViewFrame = CGRectMake(0, 0, PageWidth, [UIScreen mainScreen].bounds.size.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    _imageScrollView = scrollView;
    _imageScrollView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    _imageScrollView.pagingEnabled = YES;
    _imageScrollView.alwaysBounceVertical = NO;
    _imageScrollView.directionalLockEnabled = YES;
    _imageScrollView.contentOffset = CGPointMake(0, 0);
    _imageScrollView.delegate = self;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:_imageScrollView];
    [self.view bringSubviewToFront:_toolBar];
    UIImageView *selectingImageView = (UIImageView *)[self.view viewWithTag:kSelectingImageTag];
    [self.view bringSubviewToFront:selectingImageView];
    _currentPage = 1;
    
    // Add long press gesture recognizer
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPress.minimumPressDuration = 1.0;
    _longPress.delegate = self;
    [_imageScrollView addGestureRecognizer:_longPress];
    
    // 加入轻点(Tap gesture)
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGesture.delegate = self;
    [_imageScrollView addGestureRecognizer:_tapGesture];
    
    _starTime = [[NSDate date] timeIntervalSince1970];
    // Pan guesture
    [_addButton setTitle:NSLocalizedString(@"addMore", nil)];

    [_doodleButton setTitle:NSLocalizedString(@"doodle", nil)];
    
    _indicator = [[UILabel alloc] initWithFrame:CGRectMake(160-50, 1, 100, _toolBar.frame.size.height)];
    _indicator.textAlignment = NSTextAlignmentCenter;
    _indicator.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _indicator.textColor = [UIColor colorWithWhite:0.32 alpha:1.0];
    _indicator.backgroundColor = [UIColor clearColor];
    [_toolBar addSubview:_indicator];
    
    if (!IS_OS_7_OR_LATER) {
        UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonPressed = [[UIImage imageNamed:@"barButtonBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonPressed = [[UIImage imageNamed:@"barButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonDisabled = [[UIImage imageNamed:@"barButtonBackDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonDisabled = [[UIImage imageNamed:@"barButtonDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, 320, 44)];
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self displayImages];
    //[self setIndicator];
    
    [MobClick beginEvent:@"sharePhotos"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 将status bar设置为正常状态
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [MobClick endEvent:@"sharePhotos" label:[NSString stringWithFormat:@"%d", [_images count]]];
}

- (void)displayImages
{
    if ([_images count] > 0) {
        UIImageView *selectingView = (UIImageView *)[self.view viewWithTag:kSelectingImageTag];
        [selectingView removeFromSuperview];
    }
    
    CGRect frame = _imageScrollView.frame;
    _imageScrollView.contentSize = CGSizeMake(PageWidth * _totalNumber, frame.size.height);
    CGPoint offset = _imageScrollView.contentOffset;
    _imageScrollView.contentOffset = CGPointMake(offset.x, 0);
    for (int i = 0; i < _totalNumber; ++i) {
        int ind = [_indexs indexOfObject:[NSString stringWithFormat:@"%d",i]];
        UIImage *image = nil;
        if (ind == NSNotFound) {
            if (![_imageScrollView viewWithTag:1000 + i]) {
                image = [UIImage imageNamed:@"blankImage.png"];
                CGSize newImageSize = [self adjustImageFrame:image.size];
                //Do not add any more uiimageview on contentView
                UIView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(i * PageWidth, 0, 320, frame.size.height)];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height)];
                if (!IS_OS_7_OR_LATER) {
                    if (self.navigationController.navigationBarHidden) {
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                    }
                    else{
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height - newImageSize.height - 108)/2, newImageSize.width, newImageSize.height);
                    }
                }
                
                imageView.image = image;
                imageView.tag = kImageViewTagInContentView; // 该数字无意义, 单纯只为获取imageView而已
                contentView.tag = 1000 + i;
                [contentView addSubview:imageView];
                [_imageScrollView addSubview:contentView];
            }
            else{
                //CODE_REVIEW:下面这段代码可以不要？
                image = [UIImage imageNamed:@"blankImage.png"];
                UIView * contentView = (UIView *)[_imageScrollView viewWithTag:1000+i];
                UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kImageViewTagInContentView];
                CGSize newImageSize = [self adjustImageFrame:image.size];
                imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                if (!IS_OS_7_OR_LATER) {
                    if (self.navigationController.navigationBarHidden) {
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                    }
                    else{
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height - newImageSize.height - 108)/2, newImageSize.width, newImageSize.height);
                    }
                }
                imageView.image = image;
            }
        }
        else{
            if (![_imageScrollView viewWithTag:1000 + i]) {
                if (ind < [_images count]) {
                    image = [_images objectAtIndex:ind];
                }
                CGSize newImageSize = [self adjustImageFrame:image.size];
                UIView *contentView = [[UIImageView alloc] initWithFrame:CGRectMake(i * PageWidth, 0, 320, frame.size.height)];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height)];
                if (!IS_OS_7_OR_LATER) {
                    if (self.navigationController.navigationBarHidden) {
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                    }
                    else{
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height - newImageSize.height - 108)/2, newImageSize.width, newImageSize.height);
                    }
                }
                
                imageView.image = image;
                imageView.tag = kImageViewTagInContentView; // 该数字无意义, 单纯只为获取imageView而已
                contentView.tag = 1000 + i;
                [contentView addSubview:imageView];
                [_imageScrollView addSubview:contentView];
            }
            else{
                //CODE_REVIEW:下面这段代码可以不要？
                if (ind < [_images count]) {
                    image = [_images objectAtIndex:ind];
                    //NSLog(@"%d", image.imageOrientation);
                }
//                UIImageView *imageView = (UIImageView *)[_imageScrollView viewWithTag:1000 + i];
                UIView * contentView = (UIView *)[_imageScrollView viewWithTag:1000+i];
                UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kImageViewTagInContentView];
                CGSize newImageSize = [self adjustImageFrame:image.size];
                imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                if (!IS_OS_7_OR_LATER) {
                    if (self.navigationController.navigationBarHidden) {
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height);
                    }
                    else{
                        imageView.frame = CGRectMake((320-newImageSize.width)/2, (frame.size.height - newImageSize.height - 108)/2, newImageSize.width, newImageSize.height);
                    }
                }
                imageView.image = image;
            }
        }
    }
    [self setIndicator];
}

- (CGSize)adjustImageFrame:(CGSize)imageSize
{
    // 调节图片的大小, 使其适应屏幕
    // 目标: 在不拉伸图片的时候使其充满屏幕
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGSize newImageSize = imageSize;
    //CODE_REVIEW:需要防止除数为0的情况。
    if ((imageSize.width / imageSize.height) <= (width / height)) {
        newImageSize.height = height;
        newImageSize.width = roundf(imageSize.width * height / imageSize.height);
    }
    else {
        newImageSize.width = width;
        newImageSize.height = roundf(imageSize.height * width / imageSize.width);
    }
    
    return newImageSize;
}

- (void)displaySelectingState
{
//    _totalNumber ++;
//    // 增加一个空白的占位符
//    [self displayImages];
//    _totalNumber --;
//    // 将占位符移除
//    UIView *contentView = (UIView *)[_imageScrollView viewWithTag:1000 + _totalNumber];
//    [contentView removeFromSuperview];
    
    UIImageView *selectingImageView = [[UIImageView alloc] init];
    if (abs([UIScreen mainScreen].bounds.size.height - 568) < 2) {
        selectingImageView.frame = CGRectMake(0, 0, 320, 568);
        selectingImageView.image = [UIImage imageNamed:@"choosingImages.png"];
    }
    else {
        selectingImageView.frame = CGRectMake(0, 0, 320, 480);
        selectingImageView.image = [UIImage imageNamed:@"choosingImagesShort.png"];
    }
    selectingImageView.tag = kSelectingImageTag;
    [self.view addSubview:selectingImageView];
}

# pragma -- UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_imageScrollView viewWithTag:99999]) {
        [_imageScrollView viewWithTag:99999].hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setIndicator];
    if (kIsCallingQianLiRobot) {
        NSString *str;
        switch (_currentPage) {
            case 1:
                str = @"st";
                break;
            case 2:
                str = @"nd";
                break;
            case 3:
                str = @"rd";
                break;
            default:
                str = @"th";
                break;
        }
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QianLiRobotSlidePhoto", nil), _currentPage, str]];
        return;
    }
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    NSString *str = [NSString stringWithFormat:@"%@%@%f",kScrollOffset,kSeparator,_imageScrollView.contentOffset.x];
    [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
}

- (void)setIndicator
{
    CGFloat offsetX = _imageScrollView.contentOffset.x;
    _currentPage = roundf(offsetX / PageWidth) + 1;
    _indicator.text = [NSString stringWithFormat:@"%d / %d",_currentPage,_totalNumber];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint location = [longPress locationInView:_imageScrollView];
    // 获取当前图片的高度信息, 用于调整indicator位置
    int i = location.x / 320;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat minY = 0;
    if ([_imageScrollView viewWithTag:1000 + i]) {
        UIView *contentView = [_imageScrollView viewWithTag:1000 + i];
        UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kImageViewTagInContentView];
        height = imageView.frame.size.height;
        minY = imageView.frame.origin.y;
    }
    CGPoint locationRatio = CGPointMake(location.x/[UIScreen mainScreen].bounds.size.width, (location.y-minY)/height);
    [self showLongPressIndicator: locationRatio];
    
    // 发送位置信息
    // 发送的为占据屏幕的比例
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    NSString *message = [NSString stringWithFormat:@"%@%@%f%@%f", kLongPressIndicator, kSeparator, locationRatio.x, kSeparator, locationRatio.y];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:remotePartyNumber];
}

- (void)showLongPressIndicator:(CGPoint) locationRatio
{
    // 获取图片高度信息
    int i = locationRatio.x * [UIScreen mainScreen].bounds.size.width / 320;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat minY = 0;
    if ([_imageScrollView viewWithTag:1000 + i]) {
        UIView *contentView = [_imageScrollView viewWithTag:1000 + i];
        UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kImageViewTagInContentView];
        height = imageView.frame.size.height;
        minY = imageView.frame.origin.y;
    }
    CGPoint location = CGPointMake(locationRatio.x * [UIScreen mainScreen].bounds.size.width, locationRatio.y * height + minY);
    if ([_imageScrollView viewWithTag:99999]) {
        [_imageScrollView viewWithTag:99999].frame = CGRectMake(location.x - 15, location.y - 15 , 30, 30);
        [_imageScrollView bringSubviewToFront:[_imageScrollView viewWithTag:99999]];
        [_imageScrollView viewWithTag:99999].hidden = NO;
    }
    else{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(location.x - 15, location.y - 15 , 30, 30)];
        imageView.image = [UIImage imageNamed:@"punctuate.png"];
        [_imageScrollView addSubview:imageView];
        imageView.tag = 99999;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    [[UIApplication sharedApplication] setStatusBarHidden:!self.navigationController.navigationBarHidden];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    CGRect frame = _imageScrollView.frame;
    [UIView animateWithDuration:0.6 animations:^{
        _toolBar.hidden = !_toolBar.hidden;
        if (self.navigationController.navigationBarHidden) {
            _imageScrollView.backgroundColor = [UIColor blackColor];
            for (int i = 0; i < _totalNumber; ++i) {
                UIView *view = [_imageScrollView viewWithTag:1000 + i];
                if (view) {
                    if (!IS_OS_7_OR_LATER) {
                        for (UIView *subView in view.subviews) {
                            if ([subView isKindOfClass:[UIImageView class]]) {
                                subView.frame = CGRectMake((320-subView.frame.size.width)/2, (frame.size.height-subView.frame.size.height)/2, subView.frame.size.width, subView.frame.size.height);
                            }
                        }
                    }
                }
            }
        }
        else {
            _imageScrollView.backgroundColor = [UIColor whiteColor];
            for (int i = 0; i < _totalNumber; ++i) {
                UIView *view = [_imageScrollView viewWithTag:1000 + i];
                if (view) {
                    if (!IS_OS_7_OR_LATER) {
                        for (UIView *subView in view.subviews) {
                            if ([subView isKindOfClass:[UIImageView class]]) {
                                subView.frame = CGRectMake((320-subView.frame.size.width)/2, (frame.size.height-subView.frame.size.height - 108)/2, subView.frame.size.width, subView.frame.size.height);
                            }
                        }
                    }
                }
            }
        }
    }];
}

- (void)cancel
{
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    if (_doodleView) {
        [self cancelDoodleFromRemoteyParty];
        [[SipStackUtils sharedInstance].messageService sendMessage:kDoodleCancel toRemoteParty:remotePartyNumber];
        [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    }
    else{
        [self cancelFromRemoteyParty];
        [[SipStackUtils sharedInstance].messageService sendMessage:kImageDispCancel toRemoteParty:remotePartyNumber];
    }
}

- (void)cancelFromRemoteyParty
{
    if (_doodleView) {
        [self cancelDoodleFromRemoteyParty];
    }
    if (_chooesPhoto) {
        [_chooesPhoto dismissWithClickedButtonIndex:[_chooesPhoto cancelButtonIndex] animated:YES];
    }
    if (_addMoreImagesController) {
        [_addMoreImagesController dismissViewControllerAnimated:YES completion:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [PictureManager endImageSession:[[PictureManager sharedInstance] getImageSession] Success:^(BOOL success) {
        //NSLog(@"end session");
    }];
    
    // Add to history
    NSMutableArray *array = [NSMutableArray array];
    //CODE_REVIEW:建议将下面imageByResizing函数放到第二线程去跑，以防止阻塞主线程。
    for (UIImage *image in _images) {
        [array addObject:[image imageByScalingAndCroppingForSize:CGSizeMake(HistoryImageSize, HistoryImageSize)]];
    }
    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:array];
    DetailHistEvent *imageEvent = [[DetailHistEvent alloc] init];
    imageEvent.remoteParty = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    imageEvent.type = kMediaType_Image;
    imageEvent.content = imageData;
    imageEvent.start = _starTime;
    imageEvent.end = [[NSDate date] timeIntervalSince1970];
    if (_isIncoming) {
        imageEvent.status = kHistoryEventStatus_Incoming;
    }
    else{
        imageEvent.status = kHistoryEventStatus_Outgoing;
    }
    [[DetailHistoryAccessor sharedInstance] addHistEntry:imageEvent];
}

- (void)cancelDoodleFromRemoteyParty
{
    _toolBar.hidden = NO;
    [_doodlebackView removeFromSuperview];
    [_doodleView removeFromSuperview];
    [_doodleToolBar removeFromSuperview];
    [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)addMoreImage:(id)sender
{
    UIActionSheet *chooesPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Camera", nil), nil];
    _chooesPhoto = chooesPhoto;
    [chooesPhoto showInView:self.view];
}

#pragma mark  --ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self photoFromCamera];
    }
    else if (buttonIndex == 0){
        [self photoFromLibray];
    }
}

- (void)photoFromLibray
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AssetGroupPickerController *assetVC = [storyboard instantiateViewControllerWithIdentifier:@"AssetGroupPickerVC"];
    assetVC.delegate = self;
    
    UINavigationController *navigationVC = [[UINavigationController alloc] init];
    navigationVC.viewControllers = @[assetVC];
    _addMoreImagesController = navigationVC;
    [self presentViewController:navigationVC animated:YES completion:nil];
}

- (void)photoFromCamera
{
    CameraViewController *cameraCV = [[CameraViewController alloc] init];
    cameraCV.delegate = self;
    UINavigationControllerPortraitViewController *navigationVC = [[UINavigationControllerPortraitViewController alloc] init];
    navigationVC.viewControllers = @[cameraCV];
    _addMoreImagesController = navigationVC;
    [self presentViewController:navigationVC animated:YES completion:nil];
 }

- (void)doodleWithImageAtIndex:(NSInteger)index
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _imageScrollView.backgroundColor = [UIColor whiteColor];
    
    int ind = [_indexs indexOfObject:[NSString stringWithFormat:@"%d",index]];
    if (ind == NSNotFound) {
        return;
    }
    if (ind >= [_images count]) {
        return;
    }
    [self beginDoodle:ind];
}

- (IBAction)doodle:(id)sender
{
   int index = [_indexs indexOfObject:[NSString stringWithFormat:@"%d",_currentPage - 1]];
    if (index < [_images count]) {
        NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
        NSString *str = [NSString stringWithFormat:@"%@%@%d",kDoodleImageIndex,kSeparator,_currentPage - 1];
        [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
        [self beginDoodle:index];
    }
}

- (void)beginDoodle:(NSInteger)index
{
    _toolBar.hidden = YES;
    UIImage *image = (UIImage *)[_images objectAtIndex:index];
    CGSize imageSize = [self adjustImageFrame:image.size];
    CGRect scrollFrame = _imageScrollView.frame;
    CGRect frame;
    if (IS_OS_7_OR_LATER) {
        frame = CGRectMake((320 - imageSize.width) / 2.0, (scrollFrame.size.height-imageSize.height) / 2.0, imageSize.width, imageSize.height);
    }
    else{
        frame = CGRectMake((320 - imageSize.width) / 2.0, (scrollFrame.size.height-imageSize.height - 108) / 2.0, imageSize.width, imageSize.height);
    }
    DoodleView *view = [[DoodleView alloc] initWithFrame:frame];
    _doodleView = view;
    _doodleView.image = image;
    _doodleView.delegate = self;
    
    DoodleBackView *backView = [[DoodleBackView alloc] initWithFrame:CGRectMake(0, 0, scrollFrame.size.width, scrollFrame.size.height)];
    backView.image = image;
    [backView setImageView:frame];
    _doodlebackView = backView;
    _doodlebackView.backgroundColor = [UIColor whiteColor];
    _doodlebackView.delegate = self;
    [self.view addSubview:_doodlebackView];
    [self.view addSubview:_doodleView];
    
    // add doodle toolbar
    CGSize winSize = self.view.frame.size;
    UIView *tool = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height - 44, 320, 44)];
    _doodleToolBar = tool;
    _doodleToolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_doodleToolBar];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    [_doodleToolBar addSubview:saveButton];
    saveButton.frame = CGRectMake(20, 1, 44, 42);
    [saveButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [_doodleToolBar addSubview:clearButton];
    clearButton.frame = CGRectMake(138, 1, 44, 42);
    [clearButton setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];

    UIButton *erase = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [erase addTarget:self action:@selector(erase:) forControlEvents:UIControlEventTouchUpInside];
    [_doodleToolBar addSubview:erase];
    erase.frame = CGRectMake(234, 1, 66, 42);
    [erase setTitle:NSLocalizedString(@"eraser", nil) forState:UIControlStateNormal];
    
    [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"cancelDoodle", nil)];
}

- (void)erase:(id)sender
{
    [_doodleView changePaintingMode];
    if (_doodleView.isDrawing) {
        [sender setTitle:NSLocalizedString(@"eraser", nil) forState:UIControlStateNormal];
    }
    else{
        [sender setTitle:NSLocalizedString(@"pen", nil) forState:UIControlStateNormal];
    }
}

- (void)clear
{
    [_doodleView clearAll];
}

- (void)savePhoto
{
    UIImage *image = [_doodleView screenshot];
    UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
    
    UIView *flashView = [[UIView alloc] initWithFrame:_doodleView.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:flashView];
    [UIView animateWithDuration:0.2 animations:^{
        flashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = _doodleView.frame;
        [self.view addSubview:imageView];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.01, 0.01);
            CGAffineTransform translation;
            if (IS_IPHONE5) {
                translation = CGAffineTransformMakeTranslation(- 126.0, 260.0);
            }
            else{
                translation = CGAffineTransformMakeTranslation(- 126.0, 220.0);
            }
            imageView.transform = CGAffineTransformConcat(scaleTransform, translation);
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
    }];

}

- (void)didTapOnView
{
    [self hideDoodleTools];
}

- (void)hideDoodleTools
{
    [[UIApplication sharedApplication] setStatusBarHidden:!self.navigationController.navigationBarHidden];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    CGRect scrollFrame = _imageScrollView.frame;
    CGSize imageSize = _doodleView.frame.size;
    [UIView animateWithDuration:0.6 animations:^{
        _doodleToolBar.hidden = !_doodleToolBar.hidden;
        if (_doodleToolBar.hidden) {
            if (!IS_OS_7_OR_LATER) {
                CGRect frame = CGRectMake((320 - imageSize.width) / 2.0, (scrollFrame.size.height-imageSize.height) / 2.0, imageSize.width, imageSize.height);
                _doodleView.frame = frame;
                [_doodlebackView setImageView:frame];
            }
        }
        else{
            if (!IS_OS_7_OR_LATER) {
                CGRect frame = CGRectMake((320 - imageSize.width) / 2.0, (scrollFrame.size.height-imageSize.height - 108) / 2.0, imageSize.width, imageSize.height);
                _doodleView.frame = frame;
                [_doodlebackView setImageView:frame];
            }
        }
    }];
}

#pragma mark    --SelectImagesDelegate--
- (void)didFinishSelectingImage:(NSArray *)images
{
    if ([images count] == 0) {
        return;
    }
    if (kIsCallingQianLiRobot) {
        kQianLiRobotSharedPhotoNum += [images count];
        if ([images count] > 0) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QianLiRobotReceiveImages", nil), kQianLiRobotSharedPhotoNum]];
        }
    }
     __typeof(&*self) __weak weakSelf = self;
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    [PictureManager startImageTransSession:[images count] SessionID:[[PictureManager sharedInstance] getImageSession] Success:^(NSInteger baseIndex) {
        NSMutableArray *indexArray = [NSMutableArray array];
        for (int i = 0; i < [images count]; ++i) {
            [indexArray addObject:[NSString stringWithFormat:@"%d", i + baseIndex]];
        }
        [_indexs addObjectsFromArray:indexArray];

        [PictureManager getMaximumIndex:[[PictureManager sharedInstance] getImageSession] Success:^(NSInteger number) {
            _totalNumber = number;
            [weakSelf displayImages];
        }];
        
        [PictureManager putImages:images SessionID:[[PictureManager sharedInstance] getImageSession] StartIndex:baseIndex Receiver:nil Sender:nil  Success:^(NSArray *info) {
            NSString *str = [NSString stringWithFormat:@"%@%@%@",kImagePath,kSeparator,[info objectAtIndex:0]];
            
            if (weakSelf) {
                [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
            }
            
        } Completion:^(BOOL finished) {
            if (weakSelf) {
                [[SipStackUtils sharedInstance].messageService sendMessage:kImageTransCompletion toRemoteParty:remotePartyNumber];
            }
        }];
    }];
    
    [self scrollTO:([_images count]) * PageWidth];
    [_images addObjectsFromArray:images];
    
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"shareImage", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoingImage"];
    [Utils updateMainHistNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    // 发送信息让对方跳转
    [[SipStackUtils sharedInstance].messageService sendMessage:kNewImageComing toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

- (void)scrollTO:(CGFloat)xoffset
{
    CGPoint point = CGPointMake(xoffset, 0);
    [_imageScrollView setContentOffset:point animated:YES];
    _currentPage = roundf(xoffset / PageWidth) + 1;
    _indicator.text = [NSString stringWithFormat:@"%d / %d",_currentPage,_totalNumber];
}

@end
