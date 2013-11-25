//
//  SipService.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "../../../ios-ngn-stack/iOSNgnStack.h"
#import "iOSNgnStack.h"


// this class is the warpper of the SipService of IOS-NGN-Stack
@interface SipService : NSObject

// do sip registration
- (BOOL)registerUser;
// whether the user is registered
- (BOOL)isRegistered;
// get registration state
- (ConnectionState_t)getRegistrationState;
// get the sip stack.
-(NgnSipStack*)getSipStack;
@end
