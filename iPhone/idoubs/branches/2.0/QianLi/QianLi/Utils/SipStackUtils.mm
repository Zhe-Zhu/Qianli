//
//  SipStackUtils.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SipStackUtils.h"
#import "Global.h"
#import "iOSNgnStack.h"
#import "MediaContent.h"
#import "MediaSessionMgr.h"
#import "tsk_base64.h"
#import "QianLiAppDelegate.h"
#import "QianLiContactsAccessor.h"
#import "QianLiAppDelegate.h"
#import "HistoryTransUtils.h"
#import "QianLiAudioCallViewController.h"
#import "UserDataTransUtils.h"
#import "Utils.h"
#import "SipCallManager.h"

// global instance
static SipStackUtils * sipStackUtilsInstance;

@interface SipStackUtils()
{
 @private
    SipService * _sipService;
    ConfigurationService * _configurationService;
    NetworkService * _networkService;
    AudioService * _audioService;
    SoundService * _soundService;
    MessageService * _messageService;
    BOOL nativeABChangedWhileInBackground;
	BOOL scheduleRegistration;
    long _sessionID;
    NSString *_remoteParty;
    
    NSInteger localNofificationTimes;
}

// the read-write version of the properites
@property(nonatomic, readwrite, strong) SipService * sipService;
@property(nonatomic, readwrite, strong) ConfigurationService * configurationService;
@property(nonatomic, readwrite, strong) NetworkService * networkService;
@property(nonatomic, readwrite, strong) AudioService * audioService;
@property(nonatomic, readwrite, strong) SoundService * soundService;
@property(nonatomic, readwrite, strong) MessageService * messageService;
@property(nonatomic, readwrite, strong) NSString *remoteParty;
@property(nonatomic, strong) UILocalNotification *localNotif;
@end

@implementation SipStackUtils

@synthesize sipService              = _sipService;
@synthesize configurationService    = _configurationService;
@synthesize networkService          = _networkService;
@synthesize audioService            = _audioService;
@synthesize soundService            = _soundService;
@synthesize messageService          = _messageService;
@synthesize sessionID               = _sessionID;
@synthesize remoteParty             = _remoteParty;

#pragma mark -- init methods --

+ (SipStackUtils *)sharedInstance
{
    if (sipStackUtilsInstance == nil) {
        sipStackUtilsInstance = [[SipStackUtils alloc] init];
    }
    assert(sipStackUtilsInstance != nil);
    return sipStackUtilsInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        // init the services
//        _sipService = [[SipService alloc] init];
//        _configurationService = [[ConfigurationService alloc] init];
//        _networkService = [[NetworkService alloc] init];
//        _audioService = [[AudioService alloc] init];
//        _soundService = [[SoundService alloc] init];
//        _messageService = [[MessageService alloc] init];
        //_historyService = [[HistoryService alloc] init];
        // add observers
        
        // when network condition changed, post the notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
        // when contact changes , post the notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onNativeContactEvent:) name:kNgnContactEventArgs_Name object:nil];
        // when stack event happen, post the notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onStackEvent:) name:kNgnStackEventArgs_Name object:nil];
        // when registration status changes, post this notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onRegistrationEvent:) name:kNgnRegistrationEventArgs_Name object:nil];
        // when receive a invite event, post this notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onInviteEvent:) name:kNgnInviteEventArgs_Name object:nil];
        // when receive a incoming message, post this notification
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(onMessagingEvent:) name:kNgnMessagingEventArgs_Name object:nil];

    }
    return self;
}

#pragma mark -- Sip Stack Callback --

- (void)onNetworkEvent:(NSNotification*)notification {
	NgnNetworkEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case NETWORK_EVENT_STATE_CHANGED:
		default:
		{
			
			if([NgnEngine sharedInstance].networkService.reachable)
            {
				BOOL onMobileNework = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
				if(onMobileNework)
                {
                    // 3G, 4G, EDGE ...
					MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_medium);
                    // QCIF, SQCIF
				}
				else
                {
                    // WiFi
                    MediaSessionMgr::defaultsSetBandwidthLevel(tmedia_bl_unrestricted);
                    // SQCIF, QCIF, CIF ...
				}
				// unregister the application and schedule another registration
                // Downgraded to 3G even if it could be 4G or EDGE
				BOOL on3G = onMobileNework;
				BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
				if(on3G && !use3G){
                    // can not use 3G
                    [ErrorHandling handleError:Network3GNotEnabled];
					[[NgnEngine sharedInstance].sipService stopStackAsynchronously];
				}
				else {
                    // "on3G and use3G" or on WiFi
					// stop stack => clean up all dialogs
                    BOOL willSendMessage = NO;
                    NSString *str;
                    if ([SipCallManager SharedInstance].audioVC) {
                        willSendMessage = YES;
                        str = [SipCallManager SharedInstance].audioVC.remotePartyNumber;
                    }
                    
                    //sometimes when 3g and wifi are available at the same time
                    if (willSendMessage) {
//                        [[SipCallManager SharedInstance] sendNetworkChangeMessage];
//                        [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                        //[[NgnEngine sharedInstance].sipService registerIdentity];
                        [self performSelectorInBackground:@selector(stopSipStackAndRegisterAgain) withObject:nil];
//                        [[SipStackUtils sharedInstance].messageService sendMessage:kHangUpcall toRemoteParty:str];
                    }
                    else
                    {
//                        [[NgnEngine sharedInstance].sipService stopStackSynchronously];
                        //[[NgnEngine sharedInstance].sipService registerIdentity];
                        [self performSelectorInBackground:@selector(stopSipStackAndRegisterAgain) withObject:nil];
                    }
				}
                
                // download history
                if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
                    [[HistoryTransUtils sharedInstance] getHistoryInBackground:YES];
                }
                [Utils lookupHostIPAddressForURL:[NSURL URLWithString:@"http://www.qlcall.com"]];
			}
            else{
                // the network becomes unreachable.
                if([NgnEngine sharedInstance].sipService.registered){
                    [[NgnEngine sharedInstance].sipService stopStackAsynchronously];
                }
                if ([SipCallManager SharedInstance].audioVC) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"TerminateCall", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"iknow", nil) otherButtonTitles: nil];
                    [alertView performSelector:@selector(show) withObject:nil afterDelay:2.0];
                }
            }
			break;
		}
	}
}

//== Native Contact events == //
//TODO: what is this fuction used for
- (void)onNativeContactEvent:(NSNotification*)notification {
	NgnContactEventArgs *eargs = [notification object];
	
	switch (eargs.eventType) {
		case CONTACT_RESET_ALL:
		default:
		{
			if([UIApplication sharedApplication].applicationState != UIApplicationStateActive){
				self->nativeABChangedWhileInBackground = YES;
			}
			// otherwise addAll will be called when the client registers
			break;
		}
	}
}

- (void)onStackEvent:(NSNotification*)notification {
	NgnStackEventArgs * eargs = [notification object];
	switch (eargs.eventType) {
		case STACK_STATE_STARTING:
		{
			// this is the only place where we can be sure that the audio system is up
			[[NgnEngine sharedInstance].soundService setSpeakerEnabled:YES];
			
			break;
		}
		default:
			break;
	}
}

//== REGISTER events == //
- (void)onRegistrationEvent:(NSNotification*)notification {
	// gets the new registration state
	ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
	switch (registrationState) {
		case CONN_STATE_NONE:
		case CONN_STATE_TERMINATED:
			if(scheduleRegistration){
                // if schedule a new registration, then do it.
				scheduleRegistration = FALSE;
				//[[NgnEngine sharedInstance].sipService registerIdentity];
                [self queryConfigurationAndRegister];
			}
			break;
			
		case CONN_STATE_CONNECTING:
		case CONN_STATE_TERMINATING:
		case CONN_STATE_CONNECTED:
		default:
			break;
	}
}

//== PagerMode IM (MESSAGE) events == //
- (void)onMessagingEvent:(NSNotification*)notification {
	NgnMessagingEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case MESSAGING_EVENT_CONNECTING:
		case MESSAGING_EVENT_CONNECTED:
		case MESSAGING_EVENT_TERMINATING:
		case MESSAGING_EVENT_TERMINATED:
		case MESSAGING_EVENT_FAILURE:
		case MESSAGING_EVENT_SUCCESS:
		case MESSAGING_EVENT_OUTGOING:
		default:
		{
			break;
		}
			
		case MESSAGING_EVENT_INCOMING:
		{
			if(eargs.payload){
				// The payload is a NSData object which means that it could contain binary data
				// here I consider that it's utf8 text message
				NSString* contentType = [eargs getExtraWithKey: kExtraMessagingEventArgsContentType];
				//NSString* from = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUri];
				//NSString* userName = [eargs getExtraWithKey: kExtraMessagingEventArgsFromUserName];
				//content-transfer-encoding: base64\r\n
				//NSString* content = [NSString stringWithUTF8String: (const char*)[eargs.payload bytes]];
				
				//NSLog(@"Incoming message from:%@\n with ctype:%@\n and content:%@", from, contentType, content);
				
				// default content: e.g. plain/text
				NSData *content = eargs.payload;
				
				// message/cpim content
				if(contentType && [[contentType lowercaseString] hasPrefix:@"message/cpim"]){
					MediaContent *_content = MediaContent::parse([eargs.payload bytes], [eargs.payload length], [NgnStringUtils toCString:@"message/cpim"]);
					if(_content){
						unsigned _clen = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadLength();
						const void* _cptr = dynamic_cast<MediaContentCPIM*>(_content)->getPayloadPtr();
						if(_clen && _cptr){
							const char* _contentTransferEncoding = dynamic_cast<MediaContentCPIM*>(_content)->getHeaderValue("content-transfer-encoding");
							
							if(tsk_striequals(_contentTransferEncoding, "base64")){
								char *_ascii = tsk_null;
								int ret = tsk_base64_decode((const uint8_t*)_cptr, _clen, &_ascii);
								if((ret > 0) && _ascii){
									content = [NSData dataWithBytes:_ascii length:ret];
								}
								else {
                                    //TODO: add code here to handle the error
                                    [ErrorHandling handleError:DecodeMessageContentFailed];
									TSK_DEBUG_ERROR("tsk_base64_decode() failed with error code equal to %d", ret);
								}
								
								TSK_FREE(_ascii);
							}
							else {
								content = [NSData dataWithBytes:_cptr length:_clen];
							}
						}
						delete _content;
					}
				}
								
                // post notification
				if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                    NSString * str = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
                    NSNotification *receivedImageNotification = [NSNotification notificationWithName:@"receivedImageNotification" object:str];
                    [[NSNotificationCenter defaultCenter] postNotification:receivedImageNotification];
                    
                    if (localNofificationTimes == 0) {
                        NSArray* words = [str componentsSeparatedByString:kSeparator];
                        if (![[words objectAtIndex:0] isEqualToString:kAppointment] && ![[words objectAtIndex:0] isEqualToString:kEndInterruptionCall]) {
                            localNofificationTimes ++;
                            NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:self.remoteParty];
                            if ((name == nil) | [name isEqualToString:@""]) {
                                name = [[MainHistoryDataAccessor sharedInstance] getNameForRemoteParty:self.remoteParty];
                            }
                            NSString *message;
                            if (!name | [name isEqualToString:@""]) {
                                message = [NSString stringWithFormat:NSLocalizedString(@"LOCALMESSAGE", nil), self.remoteParty];
                            }
                            else{
                                message = [NSString stringWithFormat:NSLocalizedString(@"LOCALMESSAGE", nil), name];
                            }
                            
                            UILocalNotification *locaNotif = [[UILocalNotification alloc] init];
                            locaNotif.alertBody = message;
                            locaNotif.soundName = UILocalNotificationDefaultSoundName;
                            [[UIApplication sharedApplication] presentLocalNotificationNow:locaNotif];
                        }
                    }
                }
				else {
                    NSString * str = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
                    NSNotification *receivedImageNotification = [NSNotification notificationWithName:@"receivedImageNotification" object:str];
                    [[NSNotificationCenter defaultCenter] postNotification:receivedImageNotification];
				}
			}
			break;
		}
	}
}

//== INVITE (audio/video, file transfer, chat, ...) events == //
- (void)onInviteEvent:(NSNotification*)notification {
	NgnInviteEventArgs* eargs = [notification object];
	
	switch (eargs.eventType) {
		case INVITE_EVENT_INCOMING:
		{
			NgnAVSession* incomingSession = [NgnAVSession getSessionWithId: eargs.sessionId];
            if(incomingSession){
                // when app is in forground, present the audioCallViewController.
                localNofificationTimes = 0;
                NSString *remotePartyUri = [incomingSession getRemotePartyUri];
                if ([SipCallManager SharedInstance].audioVC) {
                    if (![[SipCallManager SharedInstance].audioVC.remotePartyNumber isEqualToString:[self getRemoteParty:remotePartyUri]]) {
                        //refuse other people's call when you are in a call
                        [self.messageService sendMessage:kInCall toRemoteParty:remotePartyUri];
                        return;
                    }
                    else{
                        //resume previous call if the call is interrupted
                        if ([SipCallManager SharedInstance].audioVC && [SipCallManager SharedInstance].endWithoutDismissAudioVC) {
                            [[SipCallManager SharedInstance] resumeCallWithID:eargs.sessionId];
                            return;
                        }
                    }
                }
                self.remoteParty = [self getRemoteParty:remotePartyUri];
				[self receiveIncomingCall:incomingSession];
			}
			if (incomingSession && [UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
                // when app is in background, post a local notification to inform user.
                UILocalNotification *locaNotif = [[UILocalNotification alloc] init];
                NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:self.remoteParty];
                if ((name == nil) | [name isEqualToString:@""]) {
                    name = [[MainHistoryDataAccessor sharedInstance] getNameForRemoteParty:self.remoteParty];
                }
                NSString *message;
                if (!name | [name isEqualToString:@""]) {
                    message = NSLocalizedString(@"IncomingCallWithOutName", nil);
                }
                else{
                    message = [NSString stringWithFormat:NSLocalizedString(@"PUSHCALLING", nil), name];
                }
                locaNotif.alertBody = message;
                locaNotif.soundName = @"ringtone.mp3";
                locaNotif.alertAction = @"PUSHACTIONKEY";
                locaNotif.userInfo = @{@"IDKey": @"IncomingCall"};
                [[UIApplication sharedApplication] presentLocalNotificationNow:locaNotif];
                self.localNotif = locaNotif;
            }
			break;
		}
			
		case INVITE_EVENT_MEDIA_UPDATED:
		{
			NgnAVSession* session = [NgnAVSession getSessionWithId:eargs.sessionId];
			if(session){
				// Dismiss previous and display(present) the new one
				// animation must be NO because we are calling dismiss then present
				[self displayCall:session];
                NSString *remotePartyUri = [session getRemotePartyUri];
                self.remoteParty = [self getRemoteParty:remotePartyUri];
			}
			//[NgnAVSession releaseSession:&session];
			break;
		}
		
		case INVITE_EVENT_TERMINATED:
		{
            localNofificationTimes = 0;
            [[SipStackUtils sharedInstance].soundService stopRingTone];
            if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
                QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
                QianLiAudioCallViewController *audioVC = (QianLiAudioCallViewController *) [appDelegate getAppDelegateAudioVC];
                if (audioVC) {
                    [appDelegate.tabController dismissViewControllerAnimated:NO completion:nil];
                    if (audioVC.viewState != InCall) {
                        NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
                        if (name) {
                            [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"historyDetailMissedCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"MissedCall"];
                        }
                        else{
                            //go to server to get name;
                            [UserDataTransUtils getUserData:[[SipStackUtils sharedInstance] getRemotePartyNumber] Completion:^(NSString *name, NSString *avatarURL) {
                                [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"historyDetailMissedCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"MissedCall"];
                            }];
                        }
                        [Utils updateMainHistNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
                        
                        audioVC.activeEvent.status = kHistoryEventStatus_Missed;
                        [[DetailHistoryAccessor sharedInstance] addHistEntry:audioVC.activeEvent];
                        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 1 + badge;
                        QianLiAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                        [appDelegate setTabItemBadge:1 + badge];
                    }
                }
            }
            
            if (_localNotif) {
                [[UIApplication sharedApplication] cancelLocalNotification:_localNotif];
                self.localNotif = nil;
            }
			break;
		}
            
		default:
		{
			break;
		}
	}
}

- (void)receiveIncomingCall:(NgnAVSession*)session
{
    // jump the audio calling view
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              kNotifKey_IncomingCall, kNotifKey,
                              [NSNumber numberWithLong:session.id], kNotifIncomingCall_SessionId,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveIncomingCallNotifName object:self userInfo:userInfo];
}

- (void)displayCall:(NgnAVSession*)session
{
    // jump the audio calling view
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              kNotifKey_IncomingCall, kNotifKey,
                              [NSNumber numberWithLong:session.id], kNotifIncomingCall_SessionId,
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReceiveIncomingCallNotifName object:self userInfo:userInfo];
}

#pragma mark -- utilies --

- (BOOL)queryConfigurationAndRegister
{
    // whether user is using 3G
    BOOL on3G = ([NgnEngine sharedInstance].networkService.networkType & NetworkType_WWAN);
    // can the app use 3G
	BOOL use3G = [[NgnEngine sharedInstance].configurationService getBoolWithKey:NETWORK_USE_3G];
	if(on3G && !use3G){
        [ErrorHandling handleError:Network3GNotEnabled];
		return NO;
	}
    else if(![[NgnEngine sharedInstance].networkService isReachable]){
        [ErrorHandling handleError:NetworkNotReachable];
		return NO;
    }
	else {
		//return [[NgnEngine sharedInstance].sipService registerIdentity];
		[[NgnEngine sharedInstance].sipService performSelectorInBackground:@selector(registerIdentity) withObject:nil];
        return YES;
        
	}
    
}

- (void)stopSipStackAndRegisterAgain
{
    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
    [[NgnEngine sharedInstance].sipService registerIdentity];
    
}

- (BOOL)unRegisterIdentity
{
   return [[NgnEngine sharedInstance].sipService unRegisterIdentity];
}

- (void)start
{
    [[NgnEngine sharedInstance] start];
}

- (void)stop
{
    [[NgnEngine sharedInstance] stop];
}

- (const NSString *)nullValue
{
    return [NgnStringUtils nullValue];
}

- (BOOL)isNullOrEmpty:(NSString *)uri
{
    return [NgnStringUtils isNullOrEmpty:uri];
}

- (void)setSessionID:(long)sessionID
{
    _sessionID = sessionID;
    _audioService.sessionID = _sessionID;
}

- (void)setRemotePartyNumber:(NSString *)remoteParty
{
    self.remoteParty = remoteParty;
}

- (NSString *)getRemotePartyNumber
{
    return self.remoteParty;
}

- (NSString *)getRemoteParty:(NSString *)remoteUri
{
    NSArray *array = [remoteUri componentsSeparatedByString:@"@"];
    if ([array count] < 1) {
        NSLog(@"remoteparty error");
        return nil;
    }
    NSArray *subArr = [[array objectAtIndex:0] componentsSeparatedByString:@":"];
    if ([subArr count] < 2) {
        NSLog(@"remoteparty error");
        return nil;
    }
    NSString *number = [subArr objectAtIndex:1];
    return number;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (SipService *)sipService
{
    if (!_sipService) {
        _sipService = [[SipService alloc] init];
    }
    return _sipService;
}

- (ConfigurationService *)configurationService
{
    if (!_configurationService) {
        _configurationService = [[ConfigurationService alloc] init];
    }
    return _configurationService;
}

- (NetworkService *)networkService
{
    if (!_networkService) {
        _networkService = [[NetworkService alloc] init];
    }
    return _networkService;
}

- (AudioService *)audioService
{
    if (!_audioService) {
        _audioService = [[AudioService alloc] init];
    }
    return _audioService;
}

- (SoundService *)soundService
{
    if (!_soundService) {
        _soundService = [[SoundService alloc] init];
    }
    return _soundService;
}

- (MessageService *)messageService
{
    if (!_messageService) {
        _messageService = [[MessageService alloc] init];
    }
    return _messageService;
}

- (void)clearAllService
{
    _sipService = nil;
    _configurationService = nil;
    _networkService = nil;
    _audioService = nil;
    _soundService = nil;
    _messageService = nil;
}

@end