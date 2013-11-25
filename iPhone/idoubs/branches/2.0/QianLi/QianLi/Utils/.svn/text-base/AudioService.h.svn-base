//
//  AudioService 
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSNgnStack.h"

// this class is the warpper of NgnAVSession of IOS-NGN-Stack
@interface AudioService : NSObject

// currently on going audio session id
@property(nonatomic, assign)long sessionID;

// make a audio call
- (BOOL)makeAudioCallWithRemoteParty: (NSString*) remoteUri andSipStack: (NgnSipStack*) sipStack sessionid:(long *)sessionID;
// hangUp a audio call
- (void)hangUpCall;
// accept a audio call
- (void)acceptCall;
// release the audio session
- (void)releaseAudioSession;
// whether there is on-going audio session
- (BOOL)doesExistOnGoingAudioSession;
// whether there is active session in the sessions array
- (BOOL)hasActiveSession;
// if there is audio session associated with the session id in the sessions array.
- (BOOL)hasSessionWithId:(long)sID;
// get the on-going audio session state
- (InviteState_t)getAudioSessionState;
// get the on-gong audio session histroy event.
- (NgnHistoryEvent *)getHistoryEvent;
// get on-going audio session remote party display name.
- (NSString *)getRemotePartyDisplayName;

- (BOOL)updateSession;
- (BOOL)isSecure;
- (BOOL)isSpeakerEnabled;
- (BOOL)isMuted;
- (BOOL)isLocalHeld;
- (BOOL)configureMute:(BOOL)isMute;
- (void)configureSpeakerEnabled:(BOOL)speakerEnabled;

- (void)toggleHoldResume;
- (void)sendDTMF:(int)tag;
    
@end
