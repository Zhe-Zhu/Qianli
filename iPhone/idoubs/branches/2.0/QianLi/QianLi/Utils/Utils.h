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
#import <sys/utsname.h>

// this class implement some useful utilites functions.
@interface Utils : NSObject

+ (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message;

+ (NSString *)readableTimeFromSecondsSince1970: (double)time;
// 内容友好的时间显示方式微信版
+ (NSString *)readableTimeFromSecondsSince1970LikeWeixin: (double)time;
+ (NSString *)getDeviceUDID;

+ (BOOL)checkInternetAndDispWarning:(BOOL)willDisplay;
+ (NSString *)stringbyRmovingSpaceFromString:(NSString *)string;

+(void)updateMainHistNameForRemoteParty:(NSString *)remote;

+(void)changeNavigationBarButtonLookingForiOS6;
+ (BOOL)isHeadsetPluggedIn;
+ (UIImage*)screenshot:(UIView *)view toSize:(CGSize)size;
+ (BOOL)isChineseSystem;

+ (void)lookupHostIPAddressForURL:(NSURL*)url;
+ (void)configureParmsWithNumber:(NSString *)number;
+ (NSString*)deviceModelName;
+ (void)clearAllSharedInstance;
@end
