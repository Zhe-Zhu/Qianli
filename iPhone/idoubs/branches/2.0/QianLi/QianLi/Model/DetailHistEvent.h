//
//  DetailHistEvent.h
//  QianLi
//
//  Created by lutan on 11/28/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailHistEvent : NSObject

@property(strong, nonatomic) NSString *type;
@property(strong, nonatomic) NSString *remoteParty;
@property(strong, nonatomic) NSString *status;
@property(nonatomic) double end;
@property(nonatomic) double start;
@property(strong, nonatomic) NSData *content;

@end
