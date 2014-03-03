//
//  DetailHistoryAccessor.h
//  QianLi
//
//  Created by lutan on 11/28/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QianLiAppDelegate.h"
#import "DetailHistEvent.h"

@interface DetailHistoryAccessor : NSObject

+ (DetailHistoryAccessor *)sharedInstance;
- (void)clearSharedInstance;
- (NSArray *)getDetailHistForRemoteParty:(NSString *)remoteParty withNumber:(NSInteger)number;
- (NSArray *)getAllDetailHistForRemoteParty:(NSString *)remoteParty;
- (void)addEventWithRemoteParty:(NSString *)remote start:(double)startT end:(double)endT status:(NSString *)status type:(NSString *)type content:(NSData *)content;
- (void)addHistEntry:(DetailHistEvent *)entry;
- (void)deleteHistoryForRemoteParty:(NSString *)remoteParty;
- (void)deleteAllHistory;
@end
