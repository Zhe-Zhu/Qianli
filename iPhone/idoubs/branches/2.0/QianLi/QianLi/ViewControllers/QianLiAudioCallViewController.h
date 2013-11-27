//
//  QianLiAudioCallViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QianLiUIMenuBar.h"
#import "QianLiUIMenuBarItem.h"
#import "AssetGroupPickerController.h"
#import "SipStackUtils.h"
#import "PictureManager.h"
#import "ImageDisplayController.h"
#import "MainHistoryDataAccessor.h"
#import "VideoViewController.h"
#import "UINavigationControllerPortraitViewController.h"
#import "QianLiContactsAccessor.h"
#import "CameraViewController.h"

// this class implements the audio call view.
// it has three states: Calling, ReceivingCall, InCall. different states have different UIs.

typedef enum
{
    None,      //none
    Calling,    // calling someone
    ReceivingCall, // receive a call
    InCall, //during a call
}ViewState;

@interface QianLiAudioCallViewController : UIViewController <QianLiUIMenuBarDelegate, SelectImageDelegate>

// the state the audio call view.
@property(nonatomic, assign)ViewState viewState;
// the sessionID used by doubango to identify the audio session.
@property(nonatomic, assign)long audioSessionID;
// the phone number of the remote one.
@property(nonatomic, strong)NSString * remotePartyNumber;
// the head portrait of the remote one
@property(nonatomic, strong) UIImage * remoteHeadPortrait;

@property(nonatomic, strong) NgnHistoryAVCallEvent *activeEvent;

@end
