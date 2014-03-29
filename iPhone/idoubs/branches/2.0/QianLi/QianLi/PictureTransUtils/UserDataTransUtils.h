//
//  UserDataTransUtils.h
//  QianLi
//
//  Created by lutan on 9/23/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Global.h"

@interface UserDataTransUtils : NSObject

+ (void)getUserUpdateInfo:(NSString *)number Completion:(void(^)(NSInteger updateTime))success;
+ (void)deleteAccount:(NSString *)number Completion:(void(^)(BOOL updateTime))success;
+ (void)getUserData:(NSString *)number Completion:(void(^)(NSString* name, NSString* avatarURL))success;
+ (void)getImageAtPath:(NSString *)relavtivePath completion:(void(^)(UIImage *image))success;
+ (void)patchUserName:(NSString *)name number:(NSString *)number Completion:(void(^)(BOOL success))success;
+ (void)patchUserProfile:(UIImage *)image number:(NSString *)number Completion:(void(^)(BOOL success))success;
+ (void)patchUserPhoneDispImage:(UIImage *)image number:(NSString *)number Completion:(void(^)(BOOL success))success;
+ (void)getUserBigAvatar:(NSString *)number Completion:(void(^)(NSString* bigAvatarURL))success;
+ (void)updateOneFriendName:(NSString *)name number:(NSString *)number completion:(void(^)(BOOL success))success;
@end

