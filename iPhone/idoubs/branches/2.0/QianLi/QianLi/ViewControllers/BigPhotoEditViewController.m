//
//  BigPhotoEditViewController.m
//  QianLi
//
//  Created by Tomoya on 13-10-10.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "BigPhotoEditViewController.h"

@interface BigPhotoEditViewController ()
{
    UIPinchGestureRecognizer __weak *_pinGesture;
    UIPanGestureRecognizer __weak *_panGesture;
    CGPoint firstPanPoint;
    CGFloat beginScale;
    CGFloat effectiveScale;
}

@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, weak) UIImageView *rectImageViw;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation BigPhotoEditViewController

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
    
    CGSize winSize = [UIScreen mainScreen].bounds.size;
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePin:)];
    _pinGesture = pin;
    [self.view addGestureRecognizer:_pinGesture];
    _pinGesture.delegate = self;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGesture = pan;
    [self.view addGestureRecognizer:_panGesture];
    _panGesture.delegate = self;
    // panGesture.maximumNumberOfTouches = 1;
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView = image;
    [self.view addSubview:_imageView];
    [self.view sendSubviewToBack:_imageView];
    effectiveScale = 1.0;
    
    UIImageView *rectImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    _rectImageViw = rectImage;
    [self.view insertSubview:rectImage aboveSubview:_imageView];
    //    [self.view addSubview:rectImage];
    if (abs(winSize.height - 568) < 2) {
        rectImage.image = [UIImage imageNamed:@"bigPhotoCoverIphone5@2x.png"];
    }
    else{
//        rectImage.image = [UIImage imageNamed:@"photoCover.png"];
        rectImage.image = nil;
    }
    
    [_doneButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Do any additional setup
    CGRect frame = [self calculateFrame];
    _imageView.frame = frame;
    _imageView.image = _profile;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (CGRect)calculateFrame
{
    if (_profile == nil) {
        return CGRectZero;
    }
    CGRect imageRect;
    CGRect winSize = [UIScreen mainScreen].bounds;
    CGSize imageSize = _profile.size;
    
    CGFloat height =  kProfileSize / imageSize.width * imageSize.height;
    imageRect  = CGRectMake((winSize.size.width - kProfileSize) / 2.0, winSize.size.height / 2.0 - height / 2.0, kProfileSize, height);
    return imageRect;
}

// UIGesture Delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _pinGesture) {
        beginScale = effectiveScale;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panGesture && otherGestureRecognizer == _pinGesture) {
        return YES;
    }
    else{
        return NO;
    }
}

// Handle pinGesture
- (void)handlePin:(UIPinchGestureRecognizer *)pin
{
    if (pin.state == UIGestureRecognizerStateBegan) {
        beginScale = effectiveScale;
    }
    else if (pin.state == UIGestureRecognizerStateChanged) {
        effectiveScale = beginScale * pin.scale;
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.transform = CGAffineTransformMakeScale(effectiveScale, effectiveScale);
        }];
    }
    else if (pin.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.2 animations:^{
            if (effectiveScale < 1) {
                effectiveScale = 1;
                _imageView.transform = CGAffineTransformMakeScale(effectiveScale, effectiveScale);
            }
            else if (effectiveScale > 5){
                effectiveScale = 5;
                _imageView.transform = CGAffineTransformMakeScale(effectiveScale, effectiveScale);
            }
        } completion:^(BOOL finished) {
            [self addjustPosion];
        }];
    }
}

// Handle Pan gesture
- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        firstPanPoint = [pan translationInView:self.view];
    }
    else if (pan.state == UIGestureRecognizerStateChanged){
        CGPoint location = [pan translationInView:self.view];
        CGFloat xdiff = location.x - firstPanPoint.x;
        CGFloat ydiff = location.y - firstPanPoint.y;
        firstPanPoint = location;
        CGPoint center = _imageView.center;
        center.x += xdiff;
        center.y += ydiff;
        [UIView animateWithDuration:0.2 animations:^{
            _imageView.center = center;
        }];
    }
    else if (pan.state == UIGestureRecognizerStateEnded){
        [self addjustPosion];
    }
}

- (void)addjustPosion
{
    CGFloat originX = _imageView.frame.origin.x;
    CGFloat originY = _imageView.frame.origin.y;
    CGFloat pX = originX + _imageView.frame.size.width;
    CGFloat pY = originY + _imageView.frame.size.height;
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat xOffset = 0, yOffset = 0;
    
    if (originX <= (winSize.width - kProfileSize) / 2.0) {
        if (pX <= (winSize.width + kProfileSize) / 2.0) {
            xOffset = (winSize.width + kProfileSize) / 2.0 - pX;
        }
    }
    else{
        xOffset = (winSize.width - kProfileSize) / 2.0 - originX;
    }
    
    if (_imageView.frame.size.height < kProfileSize) {
        yOffset = (winSize.height - _imageView.frame.size.height) / 2.0 - originY;
    }
    else{
        if (originY <= (winSize.height - kProfileSize) / 2.0) {
            if (pY <= (winSize.height + kProfileSize) / 2.0) {
                yOffset = (winSize.height + kProfileSize) / 2.0 - pY;
            }
        }
        else{
            yOffset = (winSize.height - kProfileSize) / 2.0 - originY;
        }
    }
    
    CGPoint center = _imageView.center;
    center.x += xOffset;
    center.y += yOffset;
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.center = center;
    }];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    UIImage *image = [self screenshot];
    CGRect winSize = [UIScreen mainScreen].bounds;
    CGRect fromRect;
    if (abs(winSize.size.height - 568) < 2){
        fromRect = CGRectMake((winSize.size.width - kProfileSize) / 2.0, 50, winSize.size.width*2, 480*2);
    }
    else {
        fromRect = CGRectMake((winSize.size.width - kProfileSize) / 2.0, 0, winSize.size.width*2, winSize.size.height*2);
    }
    
//    CGRect fromRect = CGRectMake((winSize.size.width - kProfileSize) / 2.0, (winSize.size.height - kProfileSize) / 2.0, kProfileSize, kProfileSize);
    CGImageRef drawImage = CGImageCreateWithImageInRect(image.CGImage, fromRect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    [_delegate didFinishEditing:newImage];
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    CGSize imageSize = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_rectImageViw removeFromSuperview];
    [_cancelButton removeFromSuperview];
    [_doneButton removeFromSuperview];
    [[self.view layer] renderInContext:context];
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
