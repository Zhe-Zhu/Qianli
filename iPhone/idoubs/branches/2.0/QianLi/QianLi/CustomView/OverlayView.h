//
//  OverlayView.h
//  CameraApp
//
//  Created by lutan on 11/1/12.
//  Copyright (c) 2012 lutan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol OverLayViewDelegate

- (void)cancel:(UIButton *) button;
- (void)switchCamera:(UIButton *) button;
- (void)takePhoto:(UIButton *) button;
- (void)done:(UIButton *) button;
- (void)openFlash: (UIButton *) button;
@end

@interface OverlayView : UIView

@property (nonatomic, assign) id<OverLayViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)changeFlashButtonToOn;
- (void)changeFlashButtonToOff;
- (void)hideFlashButton;
- (void)showFlashButton;
- (void)changeTakePhotoButton:(int)numberOfPhotos;
@end
