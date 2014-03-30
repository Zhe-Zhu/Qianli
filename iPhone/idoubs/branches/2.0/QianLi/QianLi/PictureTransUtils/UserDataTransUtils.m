//
//  UserDataTransUtils.m
//  QianLi
//
//  Created by lutan on 9/23/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "UserDataTransUtils.h"
#import "UserDataAccessor.h"

@interface UserData : NSObject

@property(nonatomic, strong) NSString *udid;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *phone_number;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *os_type;
@property(nonatomic, strong) NSString *avatarURL;

@end

@interface UserName : NSObject

@property(nonatomic, strong) NSString *name;

@end

@interface UpdateInfo : NSObject

@property(nonatomic, assign) NSInteger infoID;
@property(nonatomic, assign) NSInteger update_time;
@property(nonatomic, strong) NSString *phone_number;

@end

@interface updateFriend : NSObject
@property(nonatomic, strong) NSString *user_number;
@property(nonatomic, strong) NSString *friend_number;
@property(nonatomic, strong) NSString *friend_name;

@end

@interface receivedMessage : NSObject
@property(nonatomic, strong) NSString *message;
@end

@interface BigProfile : NSObject
@property(nonatomic, strong) NSString *bigAavatar;
@end

@implementation UpdateInfo
@synthesize infoID, update_time, phone_number;
@end

@implementation UserData
@synthesize udid, phone_number, email, os_type, avatarURL, name;
@end

@implementation UserName
@synthesize name;
@end

@implementation updateFriend
@synthesize user_number, friend_name, friend_number;
@end

@implementation receivedMessage
@synthesize message;
@end

@implementation BigProfile
@synthesize bigAavatar;
@end

@interface UserDataTransUtils ()

@property(nonatomic, strong)  NSURLSessionDataTask *task;
@end

@implementation UserDataTransUtils

+ (void)getUserUpdateInfo:(NSString *)number Completion:(void(^)(NSInteger updateTime))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[UpdateInfo class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"id": @"infoID", @"update_time": @"update_time", @"phone_number": @"phone_number"}];
    NSString *path = [NSString stringWithFormat:@"/users/update/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodGET pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         UpdateInfo *info = (UpdateInfo *)[mappingResult firstObject];
         if (success) {
             success(info.update_time);
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
          {
              UpdateInfo *info = (UpdateInfo *)[mappingResult firstObject];
              if (success) {
                  success(info.update_time);
              }
          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
              
          }];
     }];
}

+ (void)deleteAccount:(NSString *)number Completion:(void(^)(BOOL updateTime))success
{
    NSString *path = [NSString stringWithFormat:@"/users/logout/%@/",number];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    [manager deleteObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         if (success) {
             success(YES);
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [manager deleteObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
          {
              if (success) {
                  success(YES);
              }
          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
              
          }];
     }];
}

+ (void)getUserData:(NSString *)number Completion:(void(^)(NSString* name, NSString* avatarURL))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[UserData class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"name": @"name", @"phone_number": @"phone_number", @"email": @"email",@"os_type": @"os_type",@"avatar": @"avatarURL"}];
    NSString *path = [NSString stringWithFormat:@"/users/phone/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodGET pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         UserData *userData = (UserData *)[mappingResult firstObject];
          NSArray* words = [userData.avatarURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/."]];
         if ([words count] == 3) {
             if (success) {
                 success(userData.name, [words objectAtIndex:1]);
             }
         }
         else{
             if (success) {
                 success(userData.name, nil);
             }
         }
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
          {
              UserData *userData = (UserData *)[mappingResult firstObject];
              NSArray* words = [userData.avatarURL componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/."]];
              if ([words count] == 3) {
                  if (success) {
                      success(userData.name, [words objectAtIndex:1]);
                  }
              }
              else{
                  if (success) {
                      success(userData.name, nil);
                  }
              }
              
          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
              
          }];
     }];
}

+ (void)getImageAtPath:(NSString *)relavtivePath completion:(void(^)(UIImage *image))success
{
    NSString *path = [NSString stringWithFormat:@"%@/users/avatar/%@/",kBaseURL ,relavtivePath];
    //NSError *error;
    if (IS_OS_7_OR_LATER) {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:path] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == NULL) {
                success([UIImage imageWithData:data]);
            }
            else{
                NSURLSessionTask *secondTask = [session dataTaskWithURL:[NSURL URLWithString:path] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error == NULL) {
                        success([UIImage imageWithData:data]);
                    }
                    else{
                        success(nil);
                    }
                }];
                [secondTask resume];
            }
        }];
        [task resume];
    }
    else{
        NSURL *url = [NSURL URLWithString:path];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if ([data length] > 0 && error == nil){
                success([UIImage imageWithData:data]);
            }
            else if ([data length] == 0 && error == nil){
                success(nil);
            }
            else if (error != nil){
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     if ([data length] > 0 && error == nil){
                         success([UIImage imageWithData:data]);
                     }
                     else if ([data length] == 0 && error == nil){
                         success(nil);
                     }
                     else if (error != nil && error.code == NSURLErrorTimedOut){
                         success(nil);
                     }
                     else if (error != nil){
                         success(nil);
                     }
                 }];
            }
        }];
    }
}

+ (void)patchUserName:(NSString *)name number:(NSString *)number Completion:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[UserData class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"name": @"name", @"phone_number": @"phone_number", @"email": @"email",@"os_type": @"os_type",@"avatar": @"avatarURL"}];
    NSString *path = [NSString stringWithFormat:@"/users/phone/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodPATCH pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *updateRequestMapping = [RKObjectMapping requestMapping];
    [updateRequestMapping addAttributeMappingsFromDictionary:@{@"name": @"name"}];
    RKRequestDescriptor *updateDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:updateRequestMapping objectClass:[UserName class] rootKeyPath:nil method:RKRequestMethodPATCH];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addRequestDescriptor:updateDescriptor];
    
    UserName *userName = [UserName new];
    userName.name = name;
    
    [manager patchObject:userName path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(YES);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [manager patchObject:userName path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (success) {
                success(YES);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
    }];
}

+ (void)patchUserProfile:(UIImage *)image number:(NSString *)number Completion:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[UserData class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"name": @"name", @"phone_number": @"phone_number", @"email": @"email",@"os_type": @"os_type",@"avatar": @"avatarURL"}];
    NSString *path = [NSString stringWithFormat:@"/users/phone/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodPATCH pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    NSInteger __block triedTime = 0;
    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:nil method:RKRequestMethodPATCH path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5)
                                    name:@"avatar"
                                fileName:@"avatar.jpeg"
                                mimeType:@"image/jpeg"];
    }];
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ){
        if (success) {
            success(YES);
        }
    } failure:^( RKObjectRequestOperation *operation , NSError *error){
        if (triedTime <= 0) {
            [manager enqueueObjectRequestOperation:operation];
            triedTime ++;
        }
    }];
    [manager enqueueObjectRequestOperation:operation];
}

+ (void)patchUserPhoneDispImage:(UIImage *)image number:(NSString *)number Completion:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[UserData class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"name": @"name", @"phone_number": @"phone_number", @"email": @"email",@"os_type": @"os_type",@"avatar": @"avatarURL"}];
    NSString *path = [NSString stringWithFormat:@"/users/phone/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodPATCH pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    NSInteger __block triedTime = 0;
    NSMutableURLRequest *request = [manager multipartFormRequestWithObject:nil method:RKRequestMethodPATCH path:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5)
                                    name:@"large_avatar"
                                fileName:@"avatar.jpeg"
                                mimeType:@"image/jpeg"];
    }];
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ){
        if (success) {
            success(YES);
        }
    } failure:^( RKObjectRequestOperation *operation , NSError *error){
        if (triedTime <= 0) {
            [manager enqueueObjectRequestOperation:operation];
            triedTime ++;
        }
    }];
    [manager enqueueObjectRequestOperation:operation];
}

+ (void)getUserBigAvatar:(NSString *)number Completion:(void(^)(NSString* bigAvatarURL))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[BigProfile class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"large_avatar": @"bigAavatar"}];
    NSString *path = [NSString stringWithFormat:@"/users/phone/%@/", number];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodGET pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];
    
    [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         BigProfile *userData = (BigProfile *)[mappingResult firstObject];
         NSArray* words = [userData.bigAavatar componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/."]];
         if ([words count] == 3) {
             if (success) {
                 success([words objectAtIndex:1]);
             }
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
          {
              BigProfile *userData = (BigProfile *)[mappingResult firstObject];
              NSArray* words = [userData.bigAavatar componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/."]];
              if ([words count] == 3) {
                  if (success) {
                      success([words objectAtIndex:1]);
                  }
              }
          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
              
          }];
     }];
}


+ (void)updateOneFriendName:(NSString *)name number:(NSString *)number completion:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *updateMapping = [RKObjectMapping mappingForClass:[receivedMessage class]];
    [updateMapping addAttributeMappingsFromDictionary:@{@"message": @"message"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:updateMapping method:RKRequestMethodPUT pathPattern:@"/friend/add/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *updateRequestMapping = [RKObjectMapping requestMapping];
    [updateRequestMapping addAttributeMappingsFromDictionary:@{@"user_number": @"user_number", @"friend_number": @"friend_number", @"friend_name": @"friend_name"}];
    RKRequestDescriptor *updateDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:updateRequestMapping objectClass:[updateFriend class] rootKeyPath:nil method:RKRequestMethodPUT];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addRequestDescriptor:updateDescriptor];
    
    updateFriend *updateinfo = [updateFriend new];
    updateinfo.user_number = [UserDataAccessor getUserRemoteParty];
    updateinfo.friend_number = number;
    updateinfo.friend_name = name;
    
    [manager putObject:updateinfo path:@"/friend/add/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(YES);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [manager putObject:updateinfo path:@"/friend/add/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (success) {
                success(YES);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];
    }];
}

@end
