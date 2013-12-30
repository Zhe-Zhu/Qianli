//
//  WebHistoryDataAccessor.h
//  QianLi
//
//  Created by lutan on 10/18/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebHistoryDataAccessor : NSObject

+ (WebHistoryDataAccessor *)sharedInstance;
- (void)clearSharedInstance;
- (void)insert:(NSString *)title url:(NSString *)url type:(NSString *)type;
- (void)update:(NSString *)title url:(NSString *)url type:(NSString *)type;
- (NSArray *)getAllObjectsWithType:(NSString *)type;
- (void)deleteObjectForType:(NSString *)type;

@end
