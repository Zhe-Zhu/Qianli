//
//  CameraViewController.h
//  CameraApp
//
//  Created by lutan on 10/29/12.
//  Copyright (c) 2012 lutan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "OverlayView.h"
#import "ImagePickerViewController.h"
#import "UIImageExtras.h"

@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, OverLayViewDelegate,UIGestureRecognizerDelegate>{
}

@property(weak,nonatomic) id<SelectImageDelegate> delegate;
@end
