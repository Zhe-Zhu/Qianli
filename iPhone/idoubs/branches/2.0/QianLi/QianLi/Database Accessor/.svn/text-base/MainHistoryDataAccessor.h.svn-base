//
//  MainHistoryDataAccessor.h
//  QianLi
//
//  Created by lutan on 8/21/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QianLiAppDelegate.h"

@interface MainHistoryDataAccessor : NSObject

- (NSArray *)getAllObjects;
- (void)deleteObjectForRemoteParty:(NSString *)remoteParty;
- (void)updateForRemoteParty:(NSString *)remoteParty Content: (NSString *)content Time:(double)time Type:(NSString *)type;
- (void)updateNameForRemotyParty:(NSString *)remoteParty withName:(NSString *)name;
+ (id)sharedInstance;
- (void)deleteAllObjects;
- (NSString *)getNameForRemoteParty:(NSString *)remote;
- (void)updateTypeForRemotyParty:(NSString *)remoteParty withType:(NSString *)type;
@end
