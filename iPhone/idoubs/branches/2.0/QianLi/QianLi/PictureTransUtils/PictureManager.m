//
//  PictureManager.m
//  NetWorkTest
//
//  Created by lutan on 7/3/13.
//  Copyright (c) 2013 Ashstudio. All rights reserved.
//

#import "PictureManager.h"
#import "Utils.h"

//// Remote notificaton registration
@interface APNStokenwrapping : NSObject

@property(nonatomic) const void *token;
//@property(nonatomic) NSString *token;

@end

// Account class is used  by RestKit to map to json struction for registration.
@interface Account : NSObject

@property(nonatomic, strong) NSString *udid; // user name used to generate sip account name;
@property(nonatomic, strong) NSString *password;  // user password used to generate sip account password;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *systemIndicator;
@property(nonatomic, strong) NSString *avatarURL;
@property(nonatomic, strong) NSString *bigAvatarURL;

@end

// Account class is used  by RestKit to map to json struction for registration.
@interface VerifyAccount : NSObject

@property(nonatomic, strong) NSString *udid; // user name used to generate sip account name;
@property(nonatomic, strong) NSString *password;  // user password used to generate sip account password;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *systemIndicator;
@property(nonatomic, strong) NSString *avatarURL;
@property(nonatomic, strong) NSString *verificationCode;

@end


// Picture class is used by RestKit to map to Json struction for upload image to server.
@interface Picture : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSString *date;
@property(nonatomic) NSInteger index;
@property(nonatomic, strong) NSString *sessionID;
@property(nonatomic) BOOL available;
@property(nonatomic, strong) NSString *receiver;
@property(nonatomic, strong) NSString *sender;

@end

@interface ImageTransferSession : NSObject

@property(nonatomic, strong) NSString *sessionID;

@end

@interface ImageTransBegining : NSObject

@property(nonatomic) int numberOfImages;
@property(nonatomic,strong) NSString *sessionID;
@property(nonatomic) int baseIndex;

@end


@interface TotalImages : NSObject

@property(nonatomic, assign) int totalImages;

@end

@interface RegistrationStatus : NSObject

@property(nonatomic, assign) NSInteger status;

@end

@interface VerifyStatus : NSObject

@property(nonatomic, assign) NSInteger status;

@end


@implementation VerifyStatus

@synthesize status;

@end

@implementation VerifyAccount

@synthesize udid, password, nickname, phoneNumber, emailAddress, systemIndicator, avatarURL, verificationCode;

@end

@implementation RegistrationStatus
@synthesize status;
@end

@implementation Account
@synthesize udid, password, nickname, phoneNumber, emailAddress, systemIndicator, avatarURL, bigAvatarURL;
@end

@implementation APNStokenwrapping
@synthesize token;
@end

@implementation ImageTransBegining
@synthesize baseIndex, numberOfImages, sessionID;
@end

@implementation ImageTransferSession
@synthesize sessionID;
@end

@implementation TotalImages
@synthesize totalImages;
@end

@implementation Picture
@synthesize name, date, sender, receiver, sessionID,available, index, url;
@end

@interface PictureManager ()
@property(nonatomic, strong) NSString *imageSessionID;
@end

// Implementation of pictureManager
@implementation PictureManager

static PictureManager *pictureManager;

+ (id)sharedInstance
{
    if (!pictureManager) {
        pictureManager = [[PictureManager alloc] init];
    }
    return pictureManager;
}

+ (NSData *)getImageAtPath:(NSString *)index
{
    // If path is nil, then we throw an exception.
    if (index == nil) {
        [NSException raise:@"Image path can not be nil" format:@"Image path must not be nil"];
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@%@/%@/",@"http://112.124.36.134:8080/pictures/getpic/",[[PictureManager sharedInstance] getImageSession], index];
    NSError *error;
    // Downloading Image is a very basic operation, therefore, we just invoke the method provided by ios.
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:path] options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSError *err;
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:path] options:NSDataReadingMappedIfSafe error:&err];
        if (err) {
            return nil;
        }
    }
    return imageData;
}

+ (void)putImages:(NSArray *)imageArray SessionID:(NSString *)sessionID StartIndex:(NSInteger)index Receiver:(NSString *)receiver Sender:(NSString *)sender Success:(void(^)(NSArray *info))success Completion:(void(^)(BOOL finished))completion
{
    // Throw an exception if the image to be posted is nil;
    if (imageArray == nil) {
        [NSException raise:@"Posted Image can not be nil" format:@"Image must not be nil"];
        return;
    }
    RKObjectManager *manager = [RKObjectManager sharedManager];
    if (manager == nil) {
        manager  = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
        [RKObjectManager setSharedManager:manager];
    }
    
    BOOL haveAdded = NO;
    NSArray *array = [manager requestDescriptors];
    for (RKRequestDescriptor *request in array) {
        if ([request.objectClass isSubclassOfClass:[Picture class]]) {
            haveAdded = YES;
        }
    }
    if (!haveAdded) {
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Picture class]];
        [objectMapping addAttributeMappingsFromDictionary:@{@"id": @"name", @"picture": @"url", @"session_id": @"sessionID",@"index": @"index", @"send_date": @"date",@"is_available": @"available",@"send_from": @"sender",@"send_to": @"receiver"}];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objectMapping method:RKRequestMethodPUT pathPattern:@"/pictures/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping *imageTransMapping = [RKObjectMapping requestMapping];
        [imageTransMapping addAttributeMappingsFromDictionary:@{@"name": @"id", @"sessionID": @"session_id", @"url": @"picture",  @"index": @"index", @"date": @"send_date", @"available": @"is_available",@"sender": @"send_from",@"receiver": @"send_to"}];
        RKRequestDescriptor *imageTransDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:imageTransMapping objectClass:[Picture class] rootKeyPath:nil method:RKRequestMethodPUT];
        [manager addRequestDescriptor:imageTransDescriptor];
        [manager addResponseDescriptor:responseDescriptor];
    }

    NSInteger __block total = [imageArray count];
    NSInteger __block finished = 0;
    
    // We use RestKit frame work to post image to server because we can skip the step of parsing Json struction and contructing the Json struction to be posted by http request.
    for (int i = 0; i < [imageArray count]; ++i) {
        // Put the image to server
        Picture *pic = [Picture new];
        pic.sessionID = sessionID;
        pic.index = index + i;
        pic.receiver = receiver;
        pic.sender = sender;
        
        NSMutableURLRequest *request = [manager multipartFormRequestWithObject:pic method:RKRequestMethodPUT path:@"/pictures/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
            [formData appendPartWithFileData:UIImageJPEGRepresentation([imageArray objectAtIndex: i], 0.5)
                                        name:@"picture"
                                    fileName:@"image.jpeg"
                                    mimeType:@"image/jpeg"];
        }];
        
        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ){
            // If the operation is successful, RestKit will automatically map the reponse json to a local picure instance. We can access this instance to get the path of image stored in the server.
            Picture *reponsedPic = (Picture *)[mappingResult firstObject];
            
            // In the success block, this function give others an opportunity to handle the path of the image stored in server.
            NSMutableArray *info = [NSMutableArray array];
            [info addObject:[NSString stringWithFormat:@"%d",reponsedPic.index]];
            if (success) {
                success(info);
            }
            finished ++;
            if (finished == total) {
                if (completion) {
                    completion(YES);
                }
            }
            
        } failure:^( RKObjectRequestOperation *operation , NSError *error){
            
        }];
        // Put the post image operation in the request queue.
        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    }
}

+ (void)registerImageTransSession:(NSString *)sessionID Success:(void(^)(BOOL success))success
{
    //assert(sessionID != nil);
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *imageMapping = [RKObjectMapping mappingForClass:[ImageTransferSession class]];
    [imageMapping addAttributeMappingsFromDictionary:@{@"session_id": @"sessionID"}];
    RKResponseDescriptor *imageResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imageMapping method:RKRequestMethodPOST pathPattern:@"/pictures/registersessionid/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *imageRequestMapping = [RKObjectMapping requestMapping];
    [imageRequestMapping addAttributeMappingsFromDictionary:@{@"sessionID": @"session_id"}];
    RKRequestDescriptor *imageDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:imageRequestMapping objectClass:[ImageTransferSession class] rootKeyPath:nil method:RKRequestMethodPOST];
    [manager addRequestDescriptor:imageDescriptor];
    [manager addResponseDescriptor:imageResponseDescriptor];
    
    ImageTransferSession *session = [ImageTransferSession new];
    session.sessionID = sessionID;
    //RKObjectManager *manager = [self getSharedManager];
    [manager postObject:session path:@"/pictures/registersessionid/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        if (success) {
            success(YES);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // do it again if the first time is a failure
        [manager postObject:session path:@"/pictures/registersessionid/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
         {
             if (success) {
                 success(YES);
             }
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             
         }];
    }];
}

+ (void)startImageTransSession:(int)numberOfImages SessionID:(NSString *)sessionID Success:(void(^)(NSInteger baseIndex))success
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    if (manager == nil) {
        manager  = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
        [RKObjectManager setSharedManager:manager];
    }
    
    BOOL haveAdded = NO;
    NSArray *array = [manager requestDescriptors];
    for (RKRequestDescriptor *request in array) {
        if ([request.objectClass isSubclassOfClass:[ImageTransBegining class]]) {
            haveAdded = YES;
        }
    }
    if (!haveAdded) {
        //  Starting image session
        RKObjectMapping *imageStartMapping = [RKObjectMapping mappingForClass:[ImageTransBegining class]];
        [imageStartMapping addAttributeMappingsFromDictionary:@{@"image_amount": @"numberOfImages", @"start_index": @"baseIndex", @"session_id": @"sessionID"}];
        RKResponseDescriptor *imageStartResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:imageStartMapping method:RKRequestMethodPOST pathPattern:@"/pictures/getstartindex/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping *imageStartRequestMapping = [RKObjectMapping requestMapping];
        [imageStartRequestMapping addAttributeMappingsFromDictionary:@{@"numberOfImages": @"image_amount", @"baseIndex": @"start_index", @"sessionID": @"session_id"}];
        RKRequestDescriptor *imageStartDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:imageStartRequestMapping objectClass:[ImageTransBegining class] rootKeyPath:nil method:RKRequestMethodPOST];
        [manager addResponseDescriptor:imageStartResponseDescriptor];
        [manager addRequestDescriptor:imageStartDescriptor];
    }
    
    ImageTransBegining *startSession = [ImageTransBegining new];
    startSession.baseIndex = 0;
    startSession.numberOfImages = numberOfImages;
    startSession.sessionID = sessionID;
    
    [manager postObject:startSession path:@"/pictures/getstartindex/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        ImageTransBegining *starter = (ImageTransBegining *)[mappingResult firstObject];
        if (success) {
            success(starter.baseIndex);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [manager postObject:startSession path:@"/pictures/getstartindex/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            ImageTransBegining *starter = (ImageTransBegining *)[mappingResult firstObject];
            if (success) {
                success(starter.baseIndex);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
        }];
    }];
}

+ (void)getMaximumIndex:(NSString *)sessionID Success:(void(^)(NSInteger number))success
{
    //  maximum_index
    NSString *str1 = @"/pictures/getmaximumindex/";
    NSString *str2 = @"/";
    NSString *path = [NSString stringWithFormat:@"%@%@%@",str1, sessionID, str2];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    RKObjectMapping *totalImageMapping = [RKObjectMapping mappingForClass:[TotalImages class]];
    [totalImageMapping addAttributeMappingsFromDictionary:@{@"maximum_index": @"totalImages"}];
    RKResponseDescriptor *totalImageResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:totalImageMapping method:RKRequestMethodGET pathPattern:path keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:totalImageResponseDescriptor];
    
    [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
        TotalImages *total = (TotalImages *)[mappingResult firstObject];
         if (success) {
             success(total.totalImages);
         }
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
          {
              TotalImages *total = (TotalImages *)[mappingResult firstObject];
              if (success) {
                  success(total.totalImages);
              }
          } failure:^(RKObjectRequestOperation *operation, NSError *error) {
              
          }];
     }];
}

+ (void)endImageSession:(NSString *)sessionID Success:(void(^)(BOOL success))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    NSString *str1 = @"/pictures/endsession/";
    NSString *str2 = @"/";
    NSString *path = [NSString stringWithFormat:@"%@%@%@",str1, sessionID, str2];
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

- (void)setImageSession:(NSString *)imageSessionID
{
    [PictureManager sharedInstance].imageSessionID = imageSessionID;
}

- (NSString *)getImageSession
{
    return [PictureManager sharedInstance].imageSessionID;
}

+(void)registerWithUDID:(NSString *)udid Password:(NSString *)password Name:(NSString *)name PhoneNumber:(NSString *)phoneNumber Email:(NSString *)email OS:(NSString *)os Avatar:(UIImage *)avatar Success:(void(^)(int status))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    // For registration.
    RKObjectMapping *registerMapping = [RKObjectMapping mappingForClass:[RegistrationStatus class]];
    [registerMapping addAttributeMappingsFromDictionary:@{@"status": @"status"}];
    RKResponseDescriptor *registerResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:registerMapping method:RKRequestMethodPOST pathPattern:@"/users/register/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *registerRequestMapping = [RKObjectMapping requestMapping];
    [registerRequestMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"password": @"password", @"nickname": @"name", @"phoneNumber": @"phone_number", @"emailAddress": @"email", @"systemIndicator": @"os_type", @"avatarURL": @"avatar", @"bigAvatarURL": @"large_avatar"}];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:registerRequestMapping objectClass:[Account class] rootKeyPath:nil method:RKRequestMethodPOST];
    [manager addResponseDescriptor:registerResponseDescriptor];
    [manager addRequestDescriptor:requestDescriptor];
    
    // Initilize a new account used to mapped to the registration request Json stuction during registration.
    Account *account = [Account new];
    account.nickname = [Utils stringbyRmovingSpaceFromString:name];
    account.udid = [Utils stringbyRmovingSpaceFromString:udid];
    account.phoneNumber = [Utils stringbyRmovingSpaceFromString:phoneNumber];
    account.emailAddress = [Utils stringbyRmovingSpaceFromString:email];
    account.systemIndicator = [Utils stringbyRmovingSpaceFromString:os];
    account.avatarURL = nil;
    account.bigAvatarURL = nil;
    account.password = [Utils stringbyRmovingSpaceFromString:password];
    // If the shared object manager is nil, we initialize a new one.
    // If the user does not provide profile, then we just use all the information to register an account.
    [manager postObject:account path:@"/users/register/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        RegistrationStatus *regStatus = (RegistrationStatus *)[mappingResult firstObject];
        if (success) {
            success(regStatus.status);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [manager postObject:account path:@"/users/register/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            RegistrationStatus *regStatus = (RegistrationStatus *)[mappingResult firstObject];
            if (success) {
                success(regStatus.status);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (success) {
                success(-1);
            }
        }];
    }];

}

+(void)verifyWithUDID:(NSString *)udid Password:(NSString *)password Name:(NSString *)name PhoneNumber:(NSString *)phoneNumber Email:(NSString *)email OS:(NSString *)os Avatar:(UIImage *)avatar Verification:(NSString *)verificationCode Success:(void(^)(int status))success
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
    // For registration.
    RKObjectMapping *verifyMapping = [RKObjectMapping mappingForClass:[VerifyStatus class]];
    [verifyMapping addAttributeMappingsFromDictionary:@{@"status": @"status"}];
    RKResponseDescriptor *verifyResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:verifyMapping method:RKRequestMethodPOST pathPattern:@"/users/verify/" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *verifyRequestMapping = [RKObjectMapping requestMapping];
    [verifyRequestMapping addAttributeMappingsFromDictionary:@{@"udid": @"udid", @"password": @"password", @"nickname": @"name", @"phoneNumber": @"phone_number", @"emailAddress": @"email", @"systemIndicator": @"os_type", @"avatarURL": @"avatar", @"verificationCode": @"captcha"}];
    RKRequestDescriptor *verifyDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:verifyRequestMapping objectClass:[VerifyAccount class] rootKeyPath:nil method:RKRequestMethodPOST];
    [manager addRequestDescriptor:verifyDescriptor];
    [manager addResponseDescriptor:verifyResponseDescriptor];
    
    // Initilize a new account used to mapped to the registration request Json structure during registration.
    VerifyAccount *account = [VerifyAccount new];
    account.nickname = [Utils stringbyRmovingSpaceFromString:name];
    account.udid = [Utils stringbyRmovingSpaceFromString:udid];
    account.phoneNumber = [Utils stringbyRmovingSpaceFromString:phoneNumber];
    account.emailAddress = [Utils stringbyRmovingSpaceFromString:email];
    account.systemIndicator = [Utils stringbyRmovingSpaceFromString:os];
    account.avatarURL = nil;
    account.password = [Utils stringbyRmovingSpaceFromString:password];
    account.verificationCode = verificationCode;
    
    [manager postObject:account path:@"/users/verify/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        VerifyStatus *regStatus = (VerifyStatus *)[mappingResult firstObject];
        if (success) {
            success(regStatus.status);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [manager postObject:account path:@"/users/verify/" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            VerifyStatus *regStatus = (VerifyStatus *)[mappingResult firstObject];
            if (success) {
                success(regStatus.status);
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        }];
    }];
}

+ (void)getVerificationCodeByAudio:(NSString *)number
{
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString: kBaseURL]];
}

- (void)clearSharedInstance
{
    pictureManager = nil;
}

@end
