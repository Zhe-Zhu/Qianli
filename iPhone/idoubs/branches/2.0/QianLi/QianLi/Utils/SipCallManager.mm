//
//  SipCallManager.m
//  QianLi
//
//  Created by lutan on 12/2/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import "SipCallManager.h"

@interface SipCallManager ()

@end

@implementation SipCallManager

+(SipCallManager *)SharedInstance
{
    static SipCallManager *callManager = nil;
    if (callManager == nil) {
        callManager = [[SipCallManager alloc] init];
    }
    return callManager;
}

@end
