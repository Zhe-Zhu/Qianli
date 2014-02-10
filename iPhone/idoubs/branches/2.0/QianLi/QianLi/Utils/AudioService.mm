//
//  AVService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "AudioService.h"
#import "SipStackUtils.h"
#import "UserDataAccessor.h"

@interface AudioService ()
{
 @private
    long _sessionID;
    NgnAVSession* _audioSession;
}

@end

@implementation AudioService

@synthesize sessionID       = _sessionID;
@synthesize audioSession    = _audioSession;

#pragma mark -- audio call methods --

- (BOOL)makeAudioCallWithRemoteParty:(NSString *)remoteUri andSipStack:(NgnSipStack *)sipStack sessionid: (long *) sessionID;
{
    if(![NgnStringUtils isNullOrEmpty:remoteUri])
    {
		NgnAVSession* aSession = [NgnAVSession makeAudioCallWithRemoteParty: remoteUri
                                                                    andSipStack: [[NgnEngine sharedInstance].sipService getSipStack]];
        
        if (aSession != nil) {
            [SipStackUtils sharedInstance].sessionID = aSession.id;
            *sessionID = aSession.id;
            return YES;
        }
    }
    return NO;
}

- (void)hangUpCall
{
	if(_audioSession != nil)
    {
        [_audioSession hangUpCall];
    }
}

- (void)acceptCall
{
    
	if(_audioSession != nil)
    {
        [_audioSession acceptCall];
    }
    
}


- (void)setSessionID:(long)sessionID
{
    _sessionID = sessionID;
    _audioSession = nil;
    self.audioSession = [NgnAVSession getSessionWithId: sessionID];
}


- (BOOL)doesExistOnGoingAudioSession
{
    return (_audioSession != nil);
}

- (BOOL)hasActiveSession
{
    return [NgnAVSession hasActiveSession];
}

- (BOOL)hasSessionWithId:(long)sID
{
    return [NgnAVSession hasSessionWithId:sID];
}

- (InviteState_t)getAudioSessionState
{
	if(_audioSession != nil)
    {
        return _audioSession.state;
    }
    return INVITE_STATE_NONE;
}

- (NgnHistoryEvent *)getHistoryEvent
{
	if(_audioSession != nil)
    {
        return _audioSession.historyEvent;
    }
    return nil;
}

- (NSString *)getRemotePartyDisplayName
{
	if(_audioSession != nil)
    {
        return _audioSession.historyEvent.remotePartyDisplayName;
    }
    return nil;
}

- (void)releaseAudioSession
{
    NgnAVSession * aSession = [NgnAVSession getSessionWithId: _sessionID];
    if (aSession) {
        [NgnAVSession releaseSession:&aSession];
    }
}

#pragma mark -- configuration methods --

- (BOOL)isSecure
{
	if(_audioSession != nil)
    {
        return _audioSession.isSecure;
    }
    return NO;
}

- (BOOL)isSpeakerEnabled
{
	if(_audioSession != nil)
    {
        return [_audioSession isSpeakerEnabled];
    }
    return NO;
    
}

- (BOOL)isLocalHeld
{
	if(_audioSession != nil)
    {
        return [_audioSession isLocalHeld];
    }
    return NO;
    
}

- (BOOL)isMuted
{
	if(_audioSession != nil)
    {
        return [_audioSession isMuted];
    }
    return NO;
    
}

- (BOOL)configureMute:(BOOL)isMute
{
	if(_audioSession)
    {
        return [_audioSession setMute:isMute];
    }
    return NO;
}

- (void)configureSpeakerEnabled:(BOOL)speakerEnabled
{
	if(_audioSession)
    {
        [_audioSession setSpeakerEnabled:speakerEnabled];
    }
}

- (void)toggleHoldResume
{
	if(_audioSession)
    {
        [_audioSession toggleHoldResume];
    }
}

- (void)sendDTMF:(int)tag
{
	if(_audioSession)
    {
        [_audioSession sendDTMF:tag];
    }
}

- (BOOL)updateSession
{
    if(_audioSession)
    {
      return  [_audioSession updateSession:MediaType_Audio];
    }
    return NO;
}
@end
