//
//  CameraViewController.m
//  CameraApp
//
//  Created by lutan on 10/29/12.
//  Copyright (c) 2012 lutan. All rights reserved.
//

#import "CameraViewController.h"
#import "SipStackUtils.h"
#import "Global.h"
#import "MobClick.h"

@interface CameraViewController (){
    CGFloat beginGestureScale;
	CGFloat effectiveScale;
    NSMutableArray *_imageArray;
    BOOL isFlashOn;
}
@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,weak) OverlayView *overlayView;
@property (nonatomic,retain) AVCaptureDeviceInput *currentInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput  *videoDataOutput;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) UIImage *takenImage;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;

@end

@implementation CameraViewController

@synthesize session = _session;
@synthesize overlayView = _overlayView;
@synthesize currentInput = _currentInput;
@synthesize videoDataOutput = _videoDataOutput;
@synthesize previewLayer = _previewLayer;
@synthesize imageArray = _imageArray;
@synthesize takenImage = _takenImage;
@synthesize imageOutPut = _imageOutPut;
@synthesize orientation = _orientation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
    [singleTap setDelegate:self];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];
    
    // Add a double tap gesture to reset the focus mode to continuous auto focus
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
    [doubleTap setDelegate:self];
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:doubleTap];
    isFlashOn = NO;
//    UIGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//    [pinch setDelegate:self];
//    [self.view addGestureRecognizer:pinch];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    [self.navigationController setNavigationBarHidden: YES];
    [self setupCamera];
    
    OverlayView *view = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _overlayView = view;
    [self.view addSubview:_overlayView];
    _overlayView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [self stopSession];
    [_overlayView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //TODO
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"内存不足，建议少拍一些照片！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
//    [alertView show];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)setupCamera
{
    NSError *error = nil;
    _session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [_session setSessionPreset:AVCaptureSessionPresetHigh];
	else
	    [_session setSessionPreset:AVCaptureSessionPresetPhoto];

	AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    if (device == nil) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
	_currentInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error != nil){
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
//															message:[error localizedDescription]
//														   delegate:nil
//												  cancelButtonTitle:@"Dismiss"
//												  otherButtonTitles:nil];
//		[alertView show];
    }
    effectiveScale = 1.0;
    
	if ([_session canAddInput:_currentInput]){
		[_session addInput:_currentInput];
    }
	_imageOutPut = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
    [_imageOutPut setOutputSettings:outputSettings];
    if ( [_session canAddOutput:_imageOutPut] )
		[_session addOutput:_imageOutPut];
	[[_imageOutPut connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    if (isFlashOn) {
        [self turnOnFlash];
    }
    else{
        [self tureOffFlash];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    _orientation = AVCaptureVideoOrientationPortrait;
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
	[_previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:[UIScreen mainScreen].bounds];
	[self.view.layer addSublayer:_previewLayer];       
  	[_session startRunning];
}

-(void)stopSession
{
    [_session stopRunning];
    AVCaptureInput* input = [_session.inputs objectAtIndex:0];
    [_session removeInput:input];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[_session.outputs objectAtIndex:0];
    [_session removeOutput:output];
    [_previewLayer removeFromSuperlayer];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

-(AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		beginGestureScale = effectiveScale;
	}
	return YES;
}

// scale image depending on users pinch gesture
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)sender {
    BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [sender numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [sender locationOfTouch:i inView:self.view];
		CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
		if ( ! [_previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		effectiveScale = beginGestureScale * sender.scale;
		if (effectiveScale < 1.0)
			effectiveScale = 1.0;
		CGFloat maxScaleAndCropFactor = 5;
		if (effectiveScale > maxScaleAndCropFactor)
			effectiveScale = maxScaleAndCropFactor;
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[_previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
		[CATransaction commit];
	}
}

- (void)tureOffFlash
{
    if ([[self cameraWithPosition:AVCaptureDevicePositionBack] hasFlash]) {
		if ([[self cameraWithPosition:AVCaptureDevicePositionBack] lockForConfiguration:nil]) {
			if ([[self cameraWithPosition:AVCaptureDevicePositionBack] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self cameraWithPosition:AVCaptureDevicePositionBack] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self cameraWithPosition:AVCaptureDevicePositionBack] unlockForConfiguration];
		}
	}
    
    if ([[self cameraWithPosition:AVCaptureDevicePositionFront] hasFlash]) {
		if ([[self cameraWithPosition:AVCaptureDevicePositionFront] lockForConfiguration:nil]) {
			if ([[self cameraWithPosition:AVCaptureDevicePositionFront] isFlashModeSupported:AVCaptureFlashModeOff]) {
				[[self cameraWithPosition:AVCaptureDevicePositionFront] setFlashMode:AVCaptureFlashModeOff];
			}
			[[self cameraWithPosition:AVCaptureDevicePositionFront] unlockForConfiguration];
		}
	}
    [_overlayView changeFlashButtonToOff];
}

- (void)turnOnFlash
{
    if ([[self cameraWithPosition:AVCaptureDevicePositionBack] hasFlash]) {
		if ([[self cameraWithPosition:AVCaptureDevicePositionBack] lockForConfiguration:nil]) {
			if ([[self cameraWithPosition:AVCaptureDevicePositionBack] isFlashModeSupported:AVCaptureFlashModeOn]) {
				[[self cameraWithPosition:AVCaptureDevicePositionBack] setFlashMode:AVCaptureFlashModeOn];
			}
			[[self cameraWithPosition:AVCaptureDevicePositionBack] unlockForConfiguration];
		}
	}
    if ([[self cameraWithPosition:AVCaptureDevicePositionFront] hasFlash]) {
		if ([[self cameraWithPosition:AVCaptureDevicePositionFront] lockForConfiguration:nil]) {
			if ([[self cameraWithPosition:AVCaptureDevicePositionFront] isFlashModeSupported:AVCaptureFlashModeOn]) {
				[[self cameraWithPosition:AVCaptureDevicePositionFront] setFlashMode:AVCaptureFlashModeOn];
			}
			[[self cameraWithPosition:AVCaptureDevicePositionFront] unlockForConfiguration];
		}
	}
    [_overlayView changeFlashButtonToOn];
}

- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{    
        CGPoint tapPoint = [gestureRecognizer locationInView: self.view];
        CGPoint convertedFocusPoint = CGPointMake(tapPoint.y/_previewLayer.frame.size.height,tapPoint.x/_previewLayer.frame.size.width);
    AVCaptureDevice *device = [_currentInput device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:convertedFocusPoint];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:convertedFocusPoint];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [device unlockForConfiguration];
        }
    }
}

- (void) tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    AVCaptureDevice *device = [_currentInput device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:CGPointMake(0.5f, 0.5f)];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			
		}
	}
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate didFinishSelectingImage:_imageArray];
    
    [MobClick event:@"cameraPhotosCount"];
}

-(void)openFlash:(id)sender
{
    isFlashOn = !isFlashOn;
    if (isFlashOn) {
        [self turnOnFlash];
    }
    else{
        [self tureOffFlash];
    }
}

-(void)takePhoto:(id)sender
{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    if ([_imageArray count] >= 9) {
        return;
    }
    
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:_overlayView.frame];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _imageOutPut.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    if ([videoConnection isVideoOrientationSupported]){
        [videoConnection setVideoOrientation:_orientation];
    }
    
    [_imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             [library writeImageToSavedPhotosAlbum:[image CGImage]
                                       orientation:(ALAssetOrientation)[image imageOrientation]
                                   completionBlock:nil];
             UIImage *smallImage;
             if (image.size.height > 480) {
                 smallImage = [image imageByResizing: CGSizeMake(image.size.width * 480 / image.size.height, 480)];
             }
             else if(image.size.width > 640){
                 smallImage = [image imageByResizing: CGSizeMake(640, image.size.height * 640 / image.size.width)];
             }
             else{
                 smallImage = image;
             }

             [_imageArray addObject:smallImage];
        }
     }];
    [_overlayView changeTakePhotoButton:[_imageArray count] + 1];
}

-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 发送取消信息给对方
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelAddImage toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

-(void)switchCamera:(UIButton *) button{
    AVCaptureDeviceInput *newCaptureInput;
    AVCaptureDevicePosition position = _currentInput.device.position;
    
    if (position == AVCaptureDevicePositionBack){
        newCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:nil];
        [_overlayView hideFlashButton];
    }
    else if (position == AVCaptureDevicePositionFront){
        newCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:nil];
        [_overlayView showFlashButton];
    }
    [_session removeInput:_currentInput];
    if (newCaptureInput != nil) {
        [_session beginConfiguration];
        if ([_session canAddInput:newCaptureInput]) {
            [_session addInput:newCaptureInput];
            _currentInput=newCaptureInput;
        }
        else {
            [_session addInput:_currentInput];
        }
        [_session commitConfiguration];
    }
}

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		_orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		_orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		_orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		_orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

@end
