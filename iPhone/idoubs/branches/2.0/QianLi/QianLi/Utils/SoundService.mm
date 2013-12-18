//
//  SoundService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SoundService.h"

@implementation SoundService

#pragma mark -- utilies --

- (BOOL)configureAudioSession
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
