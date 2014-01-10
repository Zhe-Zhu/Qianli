//
//  HelpView.m
//  QianLi
//
//  Created by LG on 1/4/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "HelpView.h"
#import "SipCallManager.h"

#define PageWidth 340
#define NumberOfPages 5

@interface HelpView ()
{
    BOOL didShowGoonText;
    BOOL didShowReleaseText;
    BOOL didSecondPageShowGoonText;
    BOOL didSecondPageShowReleaseText;
    
    CGPoint prePoint;
}

@property(weak, nonatomic) UIScrollView *scrollView;
@property(weak, nonatomic) UIImageView *firstImageView;
@property(weak, nonatomic) UIImageView *secondImageView;
@property(weak, nonatomic) UIImageView *thirdImageView;
@property(weak, nonatomic) UIImageView *fourthImageView;
@property(weak, nonatomic) UIImageView *fifthImageView;

@property(weak, nonatomic) UIImageView *subImageView1;
@property(weak, nonatomic) UIImageView *subImageView2;

@property(weak, nonatomic) UIImageView *fingerView;
@property(weak, nonatomic) UIImageView *leftFingerView;
@property(weak, nonatomic) UIImageView *shareFinerView;

@property(weak, nonatomic) UITableViewCell *partnerCell;
@property(weak, nonatomic) UILabel *label;

@property(weak, nonatomic) HistoryMainCell* fisrtPageCell;
@property(weak, nonatomic) HistoryMainCell* secondPageCell;
@property(weak, nonatomic) HistoryMainCell* thirdPageCell;
@end

@implementation HelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect scrollViewFrame;
        scrollViewFrame = CGRectMake(0, 0, PageWidth, [UIScreen mainScreen].bounds.size.height);
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.contentSize = CGSizeMake(PageWidth * NumberOfPages, [UIScreen mainScreen].bounds.size.height);
        _scrollView = scrollView;
        _scrollView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        //add button
        UIImage *cancelImage = [UIImage imageNamed:@"help_quit.png"];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:cancelImage forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(286, 15, cancelImage.size.width, cancelImage.size.height);
        [self addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        didShowGoonText = NO;
        didShowReleaseText = NO;
        didSecondPageShowGoonText = NO;
        didSecondPageShowReleaseText = NO;
        //
        [self setFirstView];
        [self setSecondPage];
        [self setThirdPage];
        [self setFourthPage];
        [self setFifthPage];
    }
    return self;
}

- (void)quit
{
    [self removeFromSuperview];
}

#pragma mark --RMSwipeTableViewDelegate--
- (void)swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell*)swipeTableViewCell
{
    if (swipeTableViewCell == _fisrtPageCell) {
        [_fingerView removeFromSuperview];
    }
    else if (swipeTableViewCell == _secondPageCell){
        [_leftFingerView removeFromSuperview];
    }
}

- (void)swipeTableViewCell:(RMSwipeTableViewCell*)swipeTableViewCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    if (swipeTableViewCell == _fisrtPageCell) {
        if (!didShowGoonText && point.x > 70) {
            didShowGoonText = YES;
            _firstImageView.image = [UIImage imageNamed:@"help_1_dragging_background_words.png"];
        }
        else if (!didShowReleaseText &&  point.x > 130){
            didShowReleaseText = YES;
            _firstImageView.image = [UIImage imageNamed:@"help_1_draged_background_words.png"];
        }
    }
    else if (swipeTableViewCell == _secondPageCell){
        if (!didSecondPageShowGoonText && point.x < -65) {
            didSecondPageShowGoonText = YES;
            _secondImageView.image = [UIImage imageNamed:@"help_2_dragging_background_words.png"];
        }
        else if (!didSecondPageShowReleaseText &&  point.x < -105){
            didSecondPageShowReleaseText = YES;
            _secondImageView.image = [UIImage imageNamed:@"help_2_draged_background_words.png"];
        }
    }
}

-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell*)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity
{
    if (swipeTableViewCell == _fisrtPageCell) {
        didShowGoonText = NO;
        if (didShowReleaseText) {
            didShowReleaseText = NO;
            _firstImageView.image = [UIImage imageNamed:@"help_1_done_background_words.png"];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showPartnerView) userInfo:nil repeats:NO];
        }
        else{
            _firstImageView.image = [UIImage imageNamed:@"help_1_background_words.png"];
        }
    }
    else if (swipeTableViewCell == _secondPageCell){
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showCallView) userInfo:nil repeats:NO];
    }
    else if (swipeTableViewCell == _thirdPageCell){
        
    }
}

- (void)makeACall:(HistoryMainCell *)historyMainCell
{
    if (historyMainCell == _thirdPageCell){
        [[SipCallManager SharedInstance] makeQianliCallToRemote:@"008618680309879"];
        [self removeFromSuperview];
    }
}

// the first page
- (void)setFirstView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_1_background_words.png"]];
    _firstImageView = imageView;
    imageView.frame = CGRectMake(0, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    //add finger
    UIImage *fingerImage = [UIImage imageNamed:@"help_1_drag_right.png"];
    UIImageView *fingerView = [[UIImageView alloc] initWithImage:fingerImage];
    fingerView.frame = CGRectMake(27, 319, fingerImage.size.width, fingerImage.size.height);
    [_firstImageView addSubview:fingerView];
    _fingerView = fingerView;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveFinger:) userInfo:nil repeats:NO];

    
    static NSString *CellIdentifier = @"HelpHistoryMainCell";
    HistoryMainCell* historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    historyCell.historyMainCelldelegate = self;
    historyCell.delegate = self;
    _fisrtPageCell = historyCell;
    UIImage *avatar = [UIImage imageNamed:@"arwen_avatar.png"];
    NSString *name = @"Arwen Undomiel";
    
    NSDate *date = [NSDate date];
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:[date timeIntervalSince1970]] Content:@"发起电话预约"];
    historyCell.frame = CGRectMake(0, 223, historyCell.frame.size.width, historyCell.frame.size.height);
    historyCell.shouldAnimateCellReset = YES;
    [imageView addSubview:historyCell];
}

- (void)changeBackground
{
    //_imageView.image = [UIImage imageNamed:@"help_1_background_words.png"];
    [_partnerCell removeFromSuperview];
    [_label removeFromSuperview];
}

- (void)showPartnerView
{
    static NSString *CellIdentifier = @"MainCell";
    HistoryMainCell* historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UIImage *avatar = [UIImage imageNamed:@"aragon_avatar.png"];
    NSString *name = @"Aragorn";
    _partnerCell = historyCell;
    NSDate *date = [NSDate date];
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:[date timeIntervalSince1970]] Content:@"收到预约电话"];
    CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, historyCell.frame.size.width, historyCell.frame.size.height);
    historyCell.frame = frame;
    historyCell.shouldAnimateCellReset = YES;
    [_firstImageView addSubview:historyCell];
    [NSTimer scheduledTimerWithTimeInterval:9.0 target:self selector:@selector(changeBackground) userInfo:nil repeats:NO];
    
    CGFloat width = 80;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((320 - width) / 2.0, 326.5, width, 20)];
    [_firstImageView addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.text = @"对方屏幕";
    _label = label;
    label.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        historyCell.frame = CGRectMake(0, 370, historyCell.frame.size.width, historyCell.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            label.alpha = 1.0;
        } completion:^(BOOL finished) {
            [historyCell activateRequestStatus];
        }];
    }];
}

- (void)moveFinger:(NSTimer *)timer
{
    CGPoint center = _fingerView.center;
    [UIView animateWithDuration:1.0 animations:^{
        _fingerView.center = CGPointMake(center.x + 160, center.y);
        _fingerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _fingerView.center = center;
        _fingerView.alpha = 1.0;
        if (_fingerView) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveFinger:) userInfo:nil repeats:NO];
        }
    }];
}

// the second page
- (void)setSecondPage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_2_background_words.png"]];
    _secondImageView = imageView;
    imageView.frame = CGRectMake(PageWidth, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    static NSString *CellIdentifier = @"SecondHelpHistoryMainCell";
    HistoryMainCell* historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    historyCell.historyMainCelldelegate = self;
    historyCell.delegate = self;
    _secondPageCell = historyCell;
    UIImage *avatar = [UIImage imageNamed:@"aragon_avatar.png"];
    NSString *name = @"Aragorn";
    
    NSDate *date = [NSDate date];
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:[date timeIntervalSince1970]] Content:@"拨打千里电话"];
    historyCell.frame = CGRectMake(0, 223, historyCell.frame.size.width, historyCell.frame.size.height);
    historyCell.shouldAnimateCellReset = YES;
    [imageView addSubview:historyCell];
    
    //add finger
    UIImage *fingerImage = [UIImage imageNamed:@"help_drag_left.png"];
    UIImageView *fingerView = [[UIImageView alloc] initWithImage:fingerImage];
    fingerView.frame = CGRectMake(240, 319, fingerImage.size.width, fingerImage.size.height);
    [_secondImageView addSubview:fingerView];
    _leftFingerView = fingerView;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveLeftFinger) userInfo:nil repeats:NO];
}

- (void)moveLeftFinger
{
    CGPoint center = _leftFingerView.center;
    [UIView animateWithDuration:1.0 animations:^{
        _leftFingerView.center = CGPointMake(center.x - 160, center.y);
        _leftFingerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _leftFingerView.center = center;
        _leftFingerView.alpha = 1.0;
        if (_leftFingerView) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveLeftFinger) userInfo:nil repeats:NO];
        }
    }];
}

- (void)showCallView
{
    UIImage *callingImage;
    if (!IS_IPHONE5) {
        callingImage = [UIImage imageNamed:@"help_2_calling_1136.png"];
    }
    else{
        callingImage = [UIImage imageNamed:@"help_2_calling.png"];
    }
    
    UIImageView *callImageview = [[UIImageView alloc] initWithImage:callingImage];
    CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    callImageview.frame = frame;
    [self addSubview:callImageview];
    [UIView animateWithDuration:0.4 animations:^{
        callImageview.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(doneMakeingCall:) userInfo:callImageview repeats:NO];
    }];
}

- (void)doneMakeingCall:(NSTimer *)timer
{
    UIImage *doneCallImage = [UIImage imageNamed:@"help_2_done_background_words.png"];
    UIImageView *doneCallImageView = [[UIImageView alloc] initWithImage:doneCallImage];
    doneCallImageView.userInteractionEnabled = YES;
    doneCallImageView.frame = _secondImageView.frame;
    [_scrollView addSubview:doneCallImageView];
    [_secondImageView removeFromSuperview];
    
    UIImage *doneButtonImage = [UIImage imageNamed:@"help_2_button.png"];
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:doneButtonImage forState:UIControlStateNormal];
    [doneCallImageView addSubview:nextButton];
    [nextButton addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    nextButton.frame = CGRectMake((320 - doneButtonImage.size.width) / 2.0, 200, doneButtonImage.size.width, doneButtonImage.size.height);

    UIView *view = (UIView *)timer.userInfo;
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)goToNext
{
    [_scrollView setContentOffset:CGPointMake(PageWidth * 2, 0) animated:YES];
}

#pragma method of third page

- (void)setThirdPage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_3_background_words.png"]];
    _thirdImageView = imageView;
    imageView.frame = CGRectMake(PageWidth * 2, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    //408, 918, 100, 80
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(179, 443, 50, 40);
   // [button setImage:[UIImage imageNamed:@"help_3_background_words.png"] forState:UIControlStateNormal];
    [_thirdImageView addSubview:button];
    [button addTarget:self action:@selector(showShareBar) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showShareBar
{
    UIImage *callingImage;
    if (!IS_IPHONE5) {
        callingImage = [UIImage imageNamed:@"help_2_calling_1136.png"];
    }
    else{
        callingImage = [UIImage imageNamed:@"help_2_calling.png"];
    }
    
    UIImageView *callImageview = [[UIImageView alloc] initWithImage:callingImage];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    callImageview.frame = frame;
    [_thirdImageView addSubview:callImageview];
    
    UIImage *shareBar = [UIImage imageNamed:@"help_3_menu_view.png"];
    UIImageView *barView = [[UIImageView alloc] initWithImage:shareBar];
    barView.frame = CGRectMake(0, self.frame.size.height, 320, shareBar.size.height);
    [callImageview addSubview:barView];
    [UIView animateWithDuration:1.0 animations:^{
        barView.frame = CGRectMake(0, self.frame.size.height - shareBar.size.height, 320, shareBar.size.height);
    } completion:^(BOOL finished) {
        UIImage *shadeImage = [UIImage imageNamed:@"help_3_done.png"];
        UIImageView *doneShareView = [[UIImageView alloc] initWithImage:shadeImage];
        doneShareView.frame = CGRectMake(0, 0, 320, shadeImage.size.height);
        doneShareView.alpha = 0.0;
        [_thirdImageView addSubview:doneShareView];
        doneShareView.userInteractionEnabled = YES;
        
        //add button
        UIImage *iknowImage = [UIImage imageNamed:@"help_3_button.png"];
        UIButton *iknow = [UIButton buttonWithType:UIButtonTypeCustom];
        [iknow setImage:iknowImage forState:UIControlStateNormal];
        iknow.frame = CGRectMake((320 - iknowImage.size.width) / 2.0, 200, iknowImage.size.width, iknowImage.size.height);
        [doneShareView addSubview:iknow];
        [iknow addTarget:self action:@selector(goToPageFour) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView  animateWithDuration:1.5 animations:^{
            doneShareView.alpha = 1.0;
        }];
    }];
}

- (void)goToPageFour
{
    [_scrollView setContentOffset:CGPointMake(PageWidth * 3, 0) animated:YES];
}

- (void)setFourthPage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_4_background_words.png"]];
    _fourthImageView = imageView;
    imageView.frame = CGRectMake(PageWidth * 3, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    UIImage *leftFiner = [UIImage imageNamed:@"help_drag_left.png"];
    UIImageView *fingerImageView = [[UIImageView alloc] initWithImage:leftFiner];
    _shareFinerView = fingerImageView;
    [_fourthImageView addSubview:fingerImageView];
    fingerImageView.frame = CGRectMake(320 - 30 - leftFiner.size.width, 195, leftFiner.size.width, leftFiner.size.height);
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveShareImageFinger) userInfo:nil repeats:NO];
    
    UIImageView *subImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_4_picture_1.png"]];
    subImageView1.frame = CGRectMake(0, 247, 320, self.frame.size.height - 247);
    [_fourthImageView addSubview:subImageView1];
    subImageView1.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [subImageView1 addGestureRecognizer:pan];
    _subImageView1 = subImageView1;
}

- (void)moveShareImageFinger
{
    CGPoint center = _shareFinerView.center;
    [UIView animateWithDuration:1.0 animations:^{
        _shareFinerView.center = CGPointMake(center.x - 160, center.y);
        _shareFinerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _shareFinerView.center = center;
        _shareFinerView.alpha = 1.0;
        if (_shareFinerView) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveShareImageFinger) userInfo:nil repeats:NO];
        }
    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIImageView *subImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_4_picture_2.png"]];
        subImageView2.frame = CGRectMake(320, 247, 320, self.frame.size.height - 247);
        [_fourthImageView addSubview:subImageView2];
        _subImageView2 = subImageView2;
        subImageView2.userInteractionEnabled = YES;
        
        prePoint = [panGestureRecognizer locationInView:self];
        [_shareFinerView removeFromSuperview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGPoint point = [panGestureRecognizer locationInView:self];
        CGFloat deltaX = point.x - prePoint.x;
        CGPoint center1 = _subImageView1.center;
        CGPoint center2 = _subImageView2.center;
        [UIView animateWithDuration:0.2 animations:^{
            _subImageView1.center = CGPointMake(center1.x + deltaX, center1.y);
            _subImageView2.center = CGPointMake(center2.x + deltaX, center2.y);
        } completion:^(BOOL finished) {
            
        }];
        prePoint = point;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.4 animations:^{
            CGPoint center1 = _subImageView1.center;
            CGPoint center2 = _subImageView2.center;
            _subImageView1.center = CGPointMake(-160.0, center1.y);
            _subImageView2.center = CGPointMake(160.0, center2.y);
        } completion:^(BOOL finished) {
            [self showSharingImageEffect];
        }];
    }
}

- (void)showSharingImageEffect
{
    [UIView animateWithDuration:1.0 animations:^{
        _subImageView2.frame = CGRectMake(29, 284, 100, 150);
    } completion:^(BOOL finished) {
        _subImageView1.frame = CGRectMake(320 - 29 - 100, 284, 100, 150);
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_4_picture_2.png"]];
        view.frame = CGRectMake(320 - 29, 284, 100, 150);
        [_fourthImageView addSubview:view];
        [UIView animateWithDuration:1.0 animations:^{
            view.frame = CGRectMake(320 - 29 - 100, 284, 100, 150);
        } completion:^(BOOL finished) {
            [_subImageView1 removeFromSuperview];
            [self performSelector:@selector(showButton) withObject:nil afterDelay:1.0];
        }];
    }];
}

- (void)showButton
{
    UIImage *doneShareImage = [UIImage imageNamed:@"help_4_done.png"];
    _fourthImageView.image = doneShareImage;
    
    UIImage *buttonImage = [UIImage imageNamed:@"help_4_button.png"];
    UIButton *iknow = [UIButton buttonWithType:UIButtonTypeCustom];
    [iknow setImage:buttonImage forState:UIControlStateNormal];
    iknow.frame = CGRectMake((320 - buttonImage.size.width) / 2.0, 200, buttonImage.size.width, buttonImage.size.height);
    [_fourthImageView addSubview:iknow];
    [iknow addTarget:self action:@selector(goToPageFive) forControlEvents:UIControlEventTouchUpInside];
}

- (void)goToPageFive
{
    [_scrollView setContentOffset:CGPointMake(PageWidth * 4, 0) animated:YES];
}

#pragma page 5

- (void)setFifthPage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_5_background_words.png"]];
    _fifthImageView = imageView;
    imageView.frame = CGRectMake(PageWidth * 4, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    UIImage *buttonImage = [UIImage imageNamed:@"help_5_button.png"];
    UIButton *iknow = [UIButton buttonWithType:UIButtonTypeCustom];
    [iknow setImage:buttonImage forState:UIControlStateNormal];
    iknow.frame = CGRectMake((320 - buttonImage.size.width) / 2.0, 225, buttonImage.size.width, buttonImage.size.height);
    [_fifthImageView addSubview:iknow];
    [iknow addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
    
    
    static NSString *CellIdentifier = @"ThirdHelpHistoryMainCell";
    HistoryMainCell* historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    historyCell.historyMainCelldelegate = self;
    _thirdPageCell = historyCell;
    UIImage *avatar = [UIImage imageNamed:@"aragon_avatar.png"];
    NSString *name = @"Aragorn";
    
    NSDate *date = [NSDate date];
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:[date timeIntervalSince1970]] Content:@"给我打个电话吧"];
    historyCell.frame = CGRectMake(0, 300, historyCell.frame.size.width, historyCell.frame.size.height);
    historyCell.shouldAnimateCellReset = YES;
    [imageView addSubview:historyCell];
}

@end
