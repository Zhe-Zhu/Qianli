//
//  SoundService.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSNgnStack.h"

// this class is warpper of the SoundService of IOS-NGN-Stack
@interface SoundService : NSObject

- (BOOL)configureAudioSession;

- (BOOL)enableBackgroundSound;
- (BOOL)disableBackgroundSound;
- (BOOL)enableInComingCallSound;

- (BOOL)configureSpeakerEnabled:(BOOL)speakerEnabled;

- (void)playRingTone;

- (void)stopRingTone;

- (void)playRingBackTone;

- (void)stopRingBackTone;

- (void)playDtmf:(int)tag;

@end
