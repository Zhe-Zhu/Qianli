//
//  SipCallManager.h
//  QianLi
//
//  Created by lutan on 12/2/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QianLiAudioCallViewController.h"
#import "QianLiAppDelegate.h"
#import "Global.h"
#import "SipStackUtils.h"

@interface SipCallManager : NSObject

@property(nonatomic, weak) QianLiAudioCallViewController *audioVC;
@property(nonatomic, assign) BOOL endWithoutDismissAudioVC;
@property(nonatomic, assign) BOOL didHavePhoneCall;
@property(nonatomic, assign) BOOL netDidWorkChanged;

+ (SipCallManager *)SharedInstance;
- (void)clearCallManager;
- (void)makeQianliCallToRemote:(NSString *)remoteParty;
- (void)reconnectVoiceCall:(NSString *)remoteParty;
- (void)resumeCallWithID:(long)callID;
- (void)sendInterruptionMessage:(NSString *)message;
- (void)sendNetworkChangeMessage;
- (void)handleConnectionChange;

@end
