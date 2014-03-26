//
//  SipStackUtils.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SipService.h"
#import "ConfigurationService.h"
#import "NetworkService.h"
#import "ErrorHandling.h"
#import "AudioService.h"
#import "SoundService.h"
#import "MessageService.h"
#import "HistoryService.h"
#import "DetailHistoryAccessor.h"

// this class is warpper of the IOS-NGN-Stack for the convenience of changing sip framework in future.
//******* structure of this class **********/
//                                         SipStackUtils
//     SipService ConfigurationService NetworkService AudioService SoundService MessageService
// SipService: the warpper of the SipService of IOS-NGN-Stack
// Configuration: the warpper of the ConfigurationService of IOS-NGN-Stack
// NetworkService: the warppr of the NetworkService of IOS-NGN-Stack
// AudioService: the warpper of the NgnAVSession of IOS-NGN-Stack
// SoundService: the warpper of the SoundService of IOS-NGN-Stack
// MessageService: the warpper of the NgnMessagingSession of IOS-NGN-Stack
//*****************************************/
// this class encapsulates all the related methods of IOS-NGN-Stack.
// all IOS-NGN-Stack related methods must be called through this class.
@interface SipStackUtils : NSObject

@property(nonatomic, readonly, strong) SipService * sipService;
@property(nonatomic, readonly, strong) ConfigurationService * configurationService;
@property(nonatomic, readonly, strong) NetworkService * networkService;
@property(nonatomic, readonly, strong) AudioService * audioService;
@property(nonatomic, readonly, strong) SoundService * soundService;
@property(nonatomic, readonly, strong) MessageService * messageService;
//@property(nonatomic, readonly, strong) HistoryService * historyService;
// currently active audio session id.
@property(nonatomic, assign) long sessionID;

// for global access, only has one instance when app lives.
+ (SipStackUtils *)sharedInstance;
- (void)clearAllService;
// sip register method
- (BOOL)queryConfigurationAndRegister;
- (BOOL)unRegisterIdentity;
// start the NgnEngine of IOS-NGN-Stack
- (void)start;
// stop the NgnEngine.
- (void)stop;

// Utility methods
// return null string.
- (const NSString *)nullValue;
//judge whether a URI is null or empty.
- (BOOL)isNullOrEmpty:(NSString *)uri;
// just for unit test
- (void)onInviteEvent:(NSNotification*)notification;
// Get the number of remoteParty not the uri
- (NSString *)getRemotePartyNumber;
- (void)setRemotePartyNumber:(NSString *)remoteParty;
- (void)cancelCallingNotification;
@end
