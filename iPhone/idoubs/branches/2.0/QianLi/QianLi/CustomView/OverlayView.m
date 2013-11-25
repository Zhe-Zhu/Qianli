//
//  OverlayView.m
//  CameraApp
//
//  Created by lutan on 11/1/12.
//  Copyright (c) 2012 lutan. All rights reserved.
//

#import "OverlayView.h"

@interface OverlayView ()

@property (nonatomic,weak) UIButton *doneButton;
@property (nonatomic,weak) UIButton *switchCameraButton;
@property (nonatomic,weak) UIButton *cancelButton;
@property (nonatomic,weak) UIButton *takePhotoButton;
@property (nonatomic,weak) UIButton *openFlashButton;

@end

@implementation OverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // 加入底部背景
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        UIImageView *bottomBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, height - 70, width, 70)];
        bottomBackground.backgroundColor = [UIColor blackColor];
        bottomBackground.alpha = 0.2;
        [self addSubview:bottomBackground];
        
        _doneButton= [UIButton buttonWithType:UIButtonTypeCustom];
      //  UIImage *doneIcon=[UIImage imageNamed:@"doodlePalette.png"];
//       [_doneButton setImage:doneIcon forState:UIControlStateNormal];
        [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_doneButton setTintColor:[UIColor whiteColor]];
        [_doneButton setFrame:CGRectMake(width-40-10, frame.size.height - 50, 40, 40)];
        [_doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_doneButton];
        
        _switchCameraButton= [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *switchCameraIcon=[UIImage imageNamed:@"cameraRotation.png"];
        [_switchCameraButton setImage:switchCameraIcon forState:UIControlStateNormal];
        [_switchCameraButton setFrame:CGRectMake(width-70-10, 10, 70, 35)];
        [_switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCameraButton];
        
        _cancelButton= [UIButton buttonWithType:UIButtonTypeCustom];
       // UIImage *cancelFaceIcon=[UIImage imageNamed:@"doodlePalette.png"];
//        [_cancelButton setImage:cancelFaceIcon forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setFrame:CGRectMake(10, frame.size.height - 50, 40, 40)];
        [_cancelButton setTintColor:[UIColor whiteColor]];
//        [_cancelButton setAlpha:0.5];
        [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        _takePhotoButton= [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhotoPressed.png"] forState:UIControlStateHighlighted];
        [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhotoNormal.png"] forState:UIControlStateNormal];
        [_takePhotoButton setFrame:CGRectMake(width/2-30, frame.size.height - 65, 60, 60)];
//        [_takePhotoButton setAlpha:0.5];
        [_takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takePhotoButton];
        
        _openFlashButton= [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *flashImageIcon=[UIImage imageNamed:@"cameraFlashOff.png"];
        [_openFlashButton setImage:flashImageIcon forState:UIControlStateNormal];
        [_openFlashButton setFrame:CGRectMake(10, 10, 70, 35)];
        [_openFlashButton addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_openFlashButton];
    }
    return self;
}

-(void)done:(id)sender
{
    [_delegate done:sender];
}

-(void)switchCamera:(id)sender
{
    [_delegate switchCamera:sender];
}

-(void)openFlash:(id)sender
{
    [_delegate openFlash:sender];
}

-(void)takePhoto:(id)sender
{
    [_delegate takePhoto:sender];
}

-(void)cancel:(id)sender
{
    [_delegate cancel:sender];
}

- (void)changeFlashButtonToOn
{
    [_openFlashButton setImage:[UIImage imageNamed:@"cameraFlashOn.png"] forState:UIControlStateNormal];
}

- (void)changeFlashButtonToOff
{
    [_openFlashButton setImage:[UIImage imageNamed:@"cameraFlashOff.png"] forState:UIControlStateNormal];
}

- (void)hideFlashButton
{
    [_openFlashButton setHidden:YES];
}

- (void)showFlashButton
{
    [_openFlashButton setHidden:NO];
}

- (void)changeTakePhotoButton:(int)numberOfPhotos
{
    switch (numberOfPhotos) {
        case 1:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto1.png"] forState:UIControlStateNormal];
            break;
        case 2:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto2.png"] forState:UIControlStateNormal];
            break;
        case 3:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto3.png"] forState:UIControlStateNormal];
            break;
        case 4:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto4.png"] forState:UIControlStateNormal];
            break;
        case 5:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto5.png"] forState:UIControlStateNormal];
            break;
        case 6:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto6.png"] forState:UIControlStateNormal];
            break;
        case 7:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto7.png"] forState:UIControlStateNormal];
            break;
        case 8:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto8.png"] forState:UIControlStateNormal];
            break;
        case 9:
            [_takePhotoButton setImage:[UIImage imageNamed:@"cameraTakePhoto9.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

@end
