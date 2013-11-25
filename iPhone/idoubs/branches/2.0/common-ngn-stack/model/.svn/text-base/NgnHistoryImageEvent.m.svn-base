//
//  NgnHistoryImageHistory.m
//  ios-ngn-stack
//
//  Created by lutan on 7/22/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "NgnHistoryImageEvent.h"

@implementation NgnHistoryImageEvent

@synthesize content = _content;

-(NgnHistoryImageEvent*) initWithStatus:(HistoryEventStatus_t)_status andRemoteParty:(NSString*)_remoteParty
{
    return [self initWithStatus:_status andRemoteParty:_remoteParty andContent:nil];
}

-(NgnHistoryImageEvent*) initWithStatus:(HistoryEventStatus_t)_status andRemoteParty:(NSString*)_remoteParty andContent:(NSData*)contentArg{
    if((self = (NgnHistoryImageEvent*)[super initWithMediaType:MediaType_Image andRemoteParty: _remoteParty])){
		self.status = _status;
		self.content = contentArg;
	}
	return self;
}

-(void)dealloc{
    [super dealloc];
    [_content release];
}

@end
