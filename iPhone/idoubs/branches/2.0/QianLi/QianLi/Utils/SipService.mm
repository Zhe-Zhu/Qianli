//
//  SipService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SipService.h"

@implementation SipService

#pragma mark -- utilies --

- (BOOL)registerUser
{
    return [[NgnEngine sharedInstance].sipService registerIdentity];
}

- (BOOL)isRegistered
{
    return [[NgnEngine sharedInstance].sipService isRegistered];
}

- (ConnectionState_t)getRegistrationState
{
    return [[NgnEngine sharedInstance].sipService getRegistrationState];
}

- (NgnSipStack *)getSipStack
{
    return [[NgnEngine sharedInstance].sipService getSipStack];
}

@end
