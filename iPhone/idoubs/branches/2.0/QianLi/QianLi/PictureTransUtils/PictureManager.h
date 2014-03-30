//
//  PictureManager.h
//  NetWorkTest
//
//  Created by lutan on 7/3/13.
//  Copyright (c) 2013 Ashstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Global.h"

// This class is used to handle image uploading to server and downloading from server and registration.
@interface PictureManager : NSObject

// Load image from server.
+ (void)getImageAtPath:(NSString *)index completion:(void(^)(UIImage *image))success;

// post an image to server，if the opreation succeed, the string of the block parameter is the path of the poted image in server.
+ (void)putImages:(NSArray *)imageArray SessionID:(NSString *)sessionID StartIndex:(NSInteger)index Receiver:(NSString *)receiver Sender:(NSString *)sender Success:(void(^)(NSArray *info))success Completion:(void(^)(BOOL finished))completion;

// Udid, password, nickname are required and can not be nil. Either phoneNumber or emailAddress must not be nil. systemIndicator should be 'i'(ios), 'a'(android), 'o'(others)
+ (void)registerWithUDID:(NSString *)udid Password:(NSString *)password Name:(NSString *)name PhoneNumber:(NSString *)phoneNumber Email:(NSString *)email OS:(NSString *)os Avatar:(UIImage *)avatar Success:(void(^)(int status))success;
+(void)verifyWithUDID:(NSString *)udid Password:(NSString *)password Name:(NSString *)name PhoneNumber:(NSString *)phoneNumber Email:(NSString *)email OS:(NSString *)os Avatar:(UIImage *)avatar Verification:(NSString *)verificationCode Success:(void(^)(int status))success;
+ (void)getVerificationCodeByAudio:(NSString *)number Success:(void(^)(int status))success;


+ (void)registerImageTransSession:(NSString *)sessionID Success:(void(^)(BOOL success))success;
+ (void)startImageTransSession:(int)numberOfImages SessionID:(NSString *)sessionID Success:(void(^)(NSInteger baseIndex))success;
+ (void)getMaximumIndex:(NSString *)sessionID Success:(void(^)(NSInteger number))success;
+ (void)endImageSession:(NSString *)sessionID Success:(void(^)(BOOL success))success;

+ (PictureManager*)sharedInstance;
- (void)clearSharedInstance;
- (void)setImageSession:(NSString *)imageSessionID;
- (NSString *)getImageSession;

@end

