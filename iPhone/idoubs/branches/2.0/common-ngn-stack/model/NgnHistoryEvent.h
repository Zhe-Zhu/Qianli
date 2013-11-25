/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

#import <UIKit/UIKit.h>
#import "media/NgnMediaType.h"

typedef	NSMutableArray NgnHistoryEventMutableArray;
typedef NSArray	NgnHistoryEventArray;
typedef	NSMutableDictionary NgnHistoryEventMutableDictionary;
typedef	NSDictionary NgnHistoryEventDictionary;

@class NgnHistoryImageEvent;
@class NgnHistoryAVCallEvent;
@class NgnHistorySMSEvent;

typedef enum HistoryEventStatus_e{
	HistoryEventStatus_Outgoing = 0x01<<0,
	HistoryEventStatus_Incoming = 0x01<<1,
	HistoryEventStatus_Missed = 0x01<<2,
	HistoryEventStatus_Failed = 0x01<<3,
	HistoryEventStatus_Appointment = 0x01<<4,
    HistoryEventStatus_OutgoingCancelled = 0x01<<5,
    HistoryEventStatus_OutgoingRejected = 0x01<<6,
    HistoryEventStatus_IncomingCancelled = 0x01<<7,
    HistoryEventStatus_IncomingRejected = 0x01<<8,
    
	HistoryEventStatus_All = (HistoryEventStatus_Outgoing | HistoryEventStatus_Incoming | HistoryEventStatus_Missed | HistoryEventStatus_Failed | HistoryEventStatus_Appointment | HistoryEventStatus_OutgoingCancelled | HistoryEventStatus_OutgoingRejected | HistoryEventStatus_IncomingCancelled |HistoryEventStatus_IncomingRejected)
}
HistoryEventStatus_t;

@interface NgnHistoryEvent : NSObject {
	long long id;
	NgnMediaType_t mediaType;
	NSTimeInterval start;
	NSTimeInterval end;
	NSString* remoteParty;
	NSString* remotePartyDisplayName;
	BOOL seen;
	HistoryEventStatus_t status;
}

@property(readwrite)long long id;
@property(readwrite)NgnMediaType_t mediaType;
@property(readwrite)NSTimeInterval start;
@property(readwrite)NSTimeInterval end;
@property(readonly)NSString* remotePartyDisplayName;
@property(readwrite,retain)NSString* remoteParty;
@property(readwrite)BOOL seen;
@property(readwrite)HistoryEventStatus_t status;

-(NgnHistoryEvent*) initWithMediaType: (NgnMediaType_t)type andRemoteParty:(NSString*)remoteParty;
-(void) setRemotePartyWithValidUri:(NSString *)uri;
-(NSComparisonResult)compare:(NgnHistoryEvent *)otherEvent;
-(NSComparisonResult)compareHistoryEventByDateASC:(NgnHistoryEvent *)otherEvent;
-(NSComparisonResult)compareHistoryEventByDateDESC:(NgnHistoryEvent *)otherEvent;

+(NgnHistoryAVCallEvent*)createAudioVideoEventWithRemoteParty: (NSString*)remoteParty andVideo:(BOOL)video;
+(NgnHistorySMSEvent*)createSMSEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty;
+(NgnHistorySMSEvent*)createSMSEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty andContent:(NSData*)content;

//LG
+(NgnHistoryImageEvent*)createImageEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty;
+(NgnHistoryImageEvent*)createImageEventWithStatus:(HistoryEventStatus_t) status andRemoteParty:(NSString*)remoteParty andContent:(NSData*)content;

@end
