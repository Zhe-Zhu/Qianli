//
//  SipCallManager.h
//  QianLi
//
//  Created by lutan on 12/2/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QianLiAudioCallViewController.h"

@interface SipCallManager : NSObject

@property(nonatomic, weak) QianLiAudioCallViewController *audioVC;

+(SipCallManager *)SharedInstance;
@end
