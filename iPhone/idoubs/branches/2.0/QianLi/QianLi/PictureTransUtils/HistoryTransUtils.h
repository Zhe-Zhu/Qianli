//
//  HistoryTransUtils.h
//  QianLi
//
//  Created by lutan on 10/16/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataAccessor.h"
#import "DetailHistEvent.h"
#import "DetailHistoryAccessor.h"

@interface HistoryTransUtils : NSObject<NSURLConnectionDelegate>

+(HistoryTransUtils *)sharedInstance;

- (void)getHistoryInBackground:(BOOL)willVibrate;
@end
