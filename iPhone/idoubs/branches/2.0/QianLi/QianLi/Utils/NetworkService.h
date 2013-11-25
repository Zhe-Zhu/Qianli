//
//  NetworkService.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

// this class is the warpper of NetworkService of IOS-NGN-Stack.

@interface NetworkService : NSObject

// judge whether the network is reachable.
- (BOOL)reachable;

@end
