//
//  ConfigurationService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "ConfigurationService.h"

@implementation ConfigurationService

- (BOOL)getBoolWithKey:(NSString *)key
{
    return [[NgnEngine sharedInstance].configurationService getBoolWithKey:key];
}

- (void)setStringWithKey:(NSString *)key andValue:(NSString *)value
{
    [[NgnEngine sharedInstance].configurationService setStringWithKey:key andValue:value];
}

- (void)setBoolWithKey:(NSString *)key andValue:(BOOL)value
{
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:key andValue:value];
}

@end
