//
//  APNsTransUtils.m
//  QianLi
//
//  Created by lutan on 10/3/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "APNsTransUtils.h"

@interface UserNumber : NSObject

@property(nonatomic, strong) NSString *phone_receiver;
@property(nonatomic, strong) NSString *phone_sender;
@property(nonatomic, strong) NSString *type;

@end

@interface AllResponse : NSObject

@property(nonatomic, strong) NSString *message;

@end

@implementation UserNumber

@synthesize phone_receiver = _phone_receiver;
@synthesize phone_sender = _phone_sender;
@synthesize type = _type;

@end

@implementation AllResponse

@synthesize message = _message;

@end

@implementation APNsTransUtils

+ (void)postAPNsTo:(NSString *)number sender:(NSString *)senderNumber type:(NSString *)type completion:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    
    RKObjectMapping *apnsMapping = [RKObjectMapping mappingForClass:[AllResponse class]];
    [apnsMapping addAttributeMappingsFromDictionary:@{@"message": @"message"}];
    NSString *path = @"/notification/send/";
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:apnsMapping method:RKRequestMethodPOST pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *apnsRequestMapping = [RKObjectMapping requestMapping];
    [apnsRequestMapping addAttributeMappingsFromDictionary:@{@"phone_sender": @"phone_number_sender", @"phone_receiver": @"phone_number_receiver", @"type" : @"type"}];
    RKRequestDescriptor *apnsDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:apnsRequestMapping objectClass:[UserNumber class] rootKeyPath:nil method:RKRequestMethodPOST];
    [manager addResponseDescriptor:responseDescriptor];
    [manager addRequestDescriptor:apnsDescriptor];
    
    UserNumber *message = [UserNumber new];
    message.phone_sender = senderNumber;
    message.phone_receiver = number;
    message.type = type;
    
    [manager postObject:message path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(YES);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // try push it once more
        [manager postObject:message path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (success) {
                success(YES);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
    }];
}

@end
