//
//  Utils.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeychain.h"
#import "Reachability.h"

// this class implement some useful utilites functions.
@interface Utils : NSObject

// used to inform user the network is not reachable.
+ (void)networkAlert:(NSString *)message;
// used to inform user when new message is coming. 
+ (void)newMessageAlert:(NSString *)message;

+ (NSString *)readableTimeFromSecondsSince1970: (double)time;
// 内容友好的时间显示方式微信版
+ (NSString *)readableTimeFromSecondsSince1970LikeWeixin: (double)time;
+ (NSString *)getDeviceUDID;

+ (BOOL)checkInternetAndDispWarning:(BOOL)willDisplay;
+ (NSString *)stringbyRmovingSpaceFromString:(NSString *)string;

+(void)updateMainHistNameForRemoteParty:(NSString *)remote;
@end
