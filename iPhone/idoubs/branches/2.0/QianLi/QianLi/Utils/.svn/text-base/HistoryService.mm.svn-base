//
//  HistoryService.m
//  VoIPModule
//
//  Created by lutan on 7/22/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryService.h"

@implementation HistoryService

-(BOOL) load{
     return [[NgnEngine sharedInstance].historyService load];
}

-(BOOL) loadWithRemoteParty:(NSString *)remoteParty WithEntriesLength:(int)length
{
    return [[NgnEngine sharedInstance].historyService loadWithRemoteParty:remoteParty WithEntriesLength:length];
}

-(BOOL) isLoading{
    return [[NgnEngine sharedInstance].historyService isLoading];
}

-(BOOL) addEvent: (NgnHistoryEvent*) event{
    return [[NgnEngine sharedInstance].historyService addEvent:event];
}

-(BOOL) updateEvent: (NgnHistoryEvent*) event{
    return [[NgnEngine sharedInstance].historyService updateEvent:event];
}

-(BOOL) deleteEvent: (NgnHistoryEvent*) event{
    return [[NgnEngine sharedInstance].historyService deleteEvent:event];
}

-(BOOL) deleteEventAtIndex: (int) location{
    return [[NgnEngine sharedInstance].historyService deleteEventAtIndex:location];
}

-(BOOL) deleteEventWithId: (long long) eventId{
    return [[NgnEngine sharedInstance].historyService deleteEventWithId:eventId];
}

-(BOOL) deleteEvents: (NgnMediaType_t) mediaType{
    return [[NgnEngine sharedInstance].historyService deleteEvents:mediaType];
}

-(BOOL) deleteEvents: (NgnMediaType_t) mediaType withRemoteParty: (NSString*)remoteParty{
    return [[NgnEngine sharedInstance].historyService deleteEvents:mediaType withRemoteParty:remoteParty];
}

-(BOOL) deleteEventsArray: (NSArray*) events{
    return [[NgnEngine sharedInstance].historyService deleteEventsArray:events];
}

-(BOOL) clear{
    return [[NgnEngine sharedInstance].historyService clear];
}

-(NgnHistoryEventDictionary*) events{
    return [[NgnEngine sharedInstance].historyService events];
}

- (void)deleteAllObjects
{
    BOOL beginDelete = YES;
    while (beginDelete) {
        [self load];
        NSArray *array = [[self events] allValues];
        if ([array count] == 0) {
            beginDelete = NO;
        }
        else{
            for (int i = 0; i < [array count]; ++i) {
                [self deleteEvent:[array objectAtIndex:i]];
            }
        }
    }
}

@end
