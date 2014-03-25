//
//  ErrorHandling.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "ErrorHandling.h"
#import "Utils.h"
#import "Global.h"

@implementation ErrorHandling

// TODO: implement the error handling function
+ (void)handleError:(int)errorType
{
    switch (errorType) {
        case NetworkNotReachable:
        {
            break;
        }
        case Network3GNotEnabled:
        {
            break;
        }
        case SipRegisterFailed:
        {
            //TODO: inform user that user register failed
            //NSLog(@"Sip Register Failed");
            assert(NO);
            break;
        }
        case DecodeMessageContentFailed:
        {
            //TODO: inform user that decodeMessage ContentFailed.
            //NSLog(@"Decode message content failed");
            assert(NO);
        }
            
        default:
            break;
    }
}

@end
