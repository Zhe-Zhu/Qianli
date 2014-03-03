//
//  UserDataAccessor.h
//  QianLi
//
//  Created by lutan on 9/5/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataAccessor : NSObject

+ (UIImage *)getUserProfile;
+ (BOOL)setUserProfile:(UIImage *)image;
+ (UIImage *)getUserPhoneDispImage;
+ (BOOL)setUserPhoneDispImage:(UIImage *)image;
+ (void)deleteUserImages;

+ (NSString *)getUserRemoteParty;
+ (void)setUserRemoteParty:(NSString *)remoteParty;

+ (NSString *)getUserName;
+ (void)setUserName:(NSString *)name;

//+ (UIImage *)getCacheBigPhoto:(NSString *)remoteParty;
//+ (void)setCacheBigPhoto:(NSString *)remoteParty setImage:(UIImage *)bigPhoto;

+ (NSString *)getUserWaitingNumber;
+ (void)setUserWaitingNumber:(NSString *)number;

+ (NSString *)getUserPartnerNumber;
+ (void)setUserPartnerNumber:(NSString *)number;
@end
