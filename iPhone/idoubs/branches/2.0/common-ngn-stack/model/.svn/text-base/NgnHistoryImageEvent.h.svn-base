//
//  NgnHistoryImageHistory.h
//  ios-ngn-stack
//
//  Created by lutan on 7/22/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "model/NgnHistoryEvent.h"

@interface NgnHistoryImageEvent : NgnHistoryEvent{
	NSData *_content;
}

@property(nonatomic, retain) NSData *content;

-(NgnHistoryImageEvent*) initWithStatus:(HistoryEventStatus_t)_status andRemoteParty:(NSString*)_remoteParty;

-(NgnHistoryImageEvent*) initWithStatus:(HistoryEventStatus_t)_status andRemoteParty:(NSString*)_remoteParty andContent:(NSData*)contentArg;

@end
