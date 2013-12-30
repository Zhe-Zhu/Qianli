//
//  QianLiContactsAccessor.h
//  QianLi
//
//  Created by lutan on 9/22/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QianLiAppDelegate.h"

@interface QianLiContactsAccessor : NSObject

+ (id)sharedInstance;
- (void)clearSharedInstance;
- (NSArray *)getAllContacts;
- (NSString *)getNameForRemoteParty:(NSString *)remoteParty;
- (UIImage *)getProfileForRemoteParty:(NSString *)remoteParty;
- (void)insertNewObject:(NSString *)name Email: (NSString *)email Profile:(UIImage *)profile Numbers:(NSString *)number UpdateCounter:(NSInteger)nums;
- (void)deleteAllObjects;
- (void)deleteItemForRemoteParty:(NSString *)remoteParty;

- (void)updateName:(NSString *)name forNumber:(NSString *)number;
- (void)updateProfile:(UIImage *)profile updateCounter:(NSInteger)updateCouner forNumber:(NSString *)number;
- (void)updateProfile:(UIImage *)profile updateCounter:(NSInteger)updateCouner name:(NSString *)name forNumber:(NSString *)number;
- (void)updateCounter:(NSInteger)updateCouner forNumber:(NSString *)number;
- (BOOL)hasContactNumber:(NSString *)number;

@end
