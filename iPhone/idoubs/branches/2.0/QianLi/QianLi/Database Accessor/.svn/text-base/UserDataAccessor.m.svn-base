//
//  UserDataAccessor.m
//  QianLi
//
//  Created by lutan on 9/5/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "UserDataAccessor.h"

@implementation UserDataAccessor

+ (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}


+ (UIImage *)getUserProfile
{
    NSString *filePath = [self documentsPathForFileName:@"Profile.jpeg"];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    return image;
}

+ (BOOL)setUserProfile:(UIImage *)image
{
    NSData *pngData = UIImageJPEGRepresentation(image, 0.5);
    NSString *filePath = [self documentsPathForFileName:@"Profile.jpeg"];
    return [pngData writeToFile:filePath atomically:YES];
}

+ (NSString *)getUserRemoteParty
{
    NSString *remoteParty = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERREMOTEPARTY"];
    return remoteParty;
}

+ (void)setUserRemoteParty:(NSString *)remoteParty
{
    [[NSUserDefaults standardUserDefaults] setObject:remoteParty forKey:@"USERREMOTEPARTY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIImage *)getUserPhoneDispImage
{
    NSString *filePath = [self documentsPathForFileName:@"PhoneImage.jpeg"];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    return image;
}

+ (BOOL)setUserPhoneDispImage:(UIImage *)image
{
    NSData *pngData = UIImageJPEGRepresentation(image, 0.5);
    NSString *filePath = [self documentsPathForFileName:@"PhoneImage.jpeg"];
    return [pngData writeToFile:filePath atomically:YES];
}

+ (NSString *)getUserName
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"];
    return name;
}

+ (void)setUserName:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"USERNAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
