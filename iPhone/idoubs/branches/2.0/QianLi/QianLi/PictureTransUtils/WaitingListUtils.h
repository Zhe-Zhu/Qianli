//
//  WaitingListUtils.h
//  QianLi
//
//  Created by LG on 2/13/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface WaitingListUtils : NSObject<NSURLConnectionDelegate>

+ (WaitingListUtils *)sharedInstance;
- (void)getWaitingStatus;
- (void)addPartner:(NSString *)partnerNumber;

@end
