//
//  MessageService.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 3/7/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "MessageService.h"
#import "iOSNgnStack.h"

@implementation MessageService

- (BOOL)sendMessage:(NSString *)text toRemoteParty:(NSString *)remoteParty
{
    NgnHistorySMSEvent* event = [NgnHistoryEvent createSMSEventWithStatus:HistoryEventStatus_Outgoing
                                                           andRemoteParty: remoteParty
                                                               andContent:[text dataUsingEncoding:NSUTF8StringEncoding]];
    NgnMessagingSession* session = [NgnMessagingSession createOutgoingSessionWithStack:[[NgnEngine sharedInstance].sipService getSipStack]
                                                                              andToUri: [NgnUriUtils makeValidSipUri:remoteParty]];
    event.status = [session sendTextMessage:text contentType: kContentTypePlainText] ? HistoryEventStatus_Outgoing : HistoryEventStatus_Failed;
    //[[NgnEngine sharedInstance].historyService addEvent: event];
    if (event.status == HistoryEventStatus_Outgoing) {
        return YES;
    }
    return NO;
}

@end
