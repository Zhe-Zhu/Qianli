//
//  SoundService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SoundService.h"
#import "SipCallManager.h"

@interface SoundService(){
    
}

@property(strong, nonatomic) AVAudioPlayer *inCallPlayer;
@end

@implementation SoundService

#pragma mark -- utilies --

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)configureAudioSession
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    return [self startAudioSession];
}

- (BOOL)startAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    [audioSession setActive:YES error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)disableAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setActive:NO error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (void)handleAudioInterruption:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] integerValue]== AVAudioSessionInterruptionTypeBegan) {
        if ([SipCallManager SharedInstance].audioVC.viewState == InCall) {
            [[SipCallManager SharedInstance] sendInterruptionMessage:kInterruption];
        }
    }
    else if([[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] integerValue]== AVAudioSessionInterruptionTypeEnded){
        if ([SipCallManager SharedInstance].audioVC && [SipCallManager SharedInstance].endWithoutDismissAudioVC) {
            [self enableBackgroundSound];
            [[SipCallManager SharedInstance] reconnectVoiceCall:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
        }
    }
}

- (BOOL)enableBackgroundSound
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    [audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    [audioSession setActive:YES error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)disableBackgroundSound
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)enableInComingCallSound
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    [audioSession setActive:YES error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)configureSpeakerEnabled:(BOOL)speakerEnabled
{
    
    return [[NgnEngine sharedInstance].soundService setSpeakerEnabled:speakerEnabled];
}

- (void)playRingTone
{
    
    [[NgnEngine sharedInstance].soundService playRingTone];
}

- (void)stopRingTone
{
    [[NgnEngine sharedInstance].soundService stopRingTone];
}

- (void)playRingBackTone
{
    [[NgnEngine sharedInstance].soundService playRingBackTone];
}

- (void)stopRingBackTone
{
    [[NgnEngine sharedInstance].soundService stopRingBackTone];
}

- (void)playInCallSound
{
    if (![SipCallManager SharedInstance].audioVC || [SipCallManager SharedInstance].audioVC.didPressEndCall == YES) {
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CallLater" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath: path];
	NSError *error;
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    player.numberOfLoops = 2;
    self.inCallPlayer = player;
	if (player == nil){
		return;
	}
    [player play];
}

- (void)stopInCallSound
{
    [self.inCallPlayer stop];
    self.inCallPlayer = nil;
}

- (void)playDtmf:(int)tag
{
    [[NgnEngine sharedInstance].soundService playDtmf:tag];
}

#pragma mark --AVAudioPlayerDelegate--
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == _inCallPlayer) {
        self.inCallPlayer = nil;
    }
}

@end
