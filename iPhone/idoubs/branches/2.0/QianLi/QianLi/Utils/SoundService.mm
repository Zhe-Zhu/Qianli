//
//  SoundService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SoundService.h"
#import "SipCallManager.h"

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
    [audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    [audioSession setActive:YES error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (void)handleAudioInterruption:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:AVAudioSessionInterruptionTypeKey] integerValue]== AVAudioSessionInterruptionTypeBegan) {
        [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    }
    else{
        [[AVAudioSession sharedInstance] setActive:YES error:NULL];
        //[self resumeCallAfterInterruption];
    }
}

- (BOOL)enableBackgroundSound
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
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
    if (error) {
        return NO;
    }
    return YES;
}

- (void)resumeCallAfterInterruption
{
    if ([SipCallManager SharedInstance].audioVC) {
//        [self startAudioSession];
//        [self enableBackgroundSound];
        [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    }
    else{
        [self startAudioSession];
    }
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

- (void)playDtmf:(int)tag
{
    
    [[NgnEngine sharedInstance].soundService playDtmf:tag];
    
}

@end
