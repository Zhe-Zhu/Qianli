//
//  SipCallManager.m
//  QianLi
//
//  Created by lutan on 12/2/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import "SipCallManager.h"
#import "SVProgressHUD.h"
#import "Global.h"

@interface SipCallManager ()

@property(nonatomic, weak) NSTimer *timer;
@end

@implementation SipCallManager

static SipCallManager *callManager = nil;

+(SipCallManager *)SharedInstance
{
    if (callManager == nil) {
        callManager = [[SipCallManager alloc] init];
        callManager.didEndInerruptionCall = NO;
        callManager.didHavePhoneCall = NO;
        callManager.endWithoutDismissAudioVC = NO;
        callManager.netDidWorkChanged = NO;
        [[NSNotificationCenter defaultCenter] addObserver:callManager selector:@selector(receiveIncomingMessage:) name:@"receivedImageNotification" object:nil];
    }
    return callManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)makeQianliCallToRemote:(NSString *)remoteParty
{
    if ([remoteParty isEqualToString:QianLiRobotNumber]) {
        kIsCallingQianLiRobot = YES;
        kQianLiRobotSharedDoodleNum = 0;
        kQianLiRobotSharedPhotoNum = 0;
        kQianLiRobotSharedWebNum = 0;
        kQianLiRobotsharedVideoNum = 0;
    }
    else
    {
        kIsCallingQianLiRobot = NO;
    }
    if ([remoteParty isEqualToString:[UserDataAccessor getUserRemoteParty]]) {
        return;
    }
    
    if (![Utils checkInternetAndDispWarning:YES]) {
        //if (kIsCallingQianLiRobot) {
            //[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CallQianLiRobotNetworkFailed", nil)];
          //  return;
        //}
        return;
    }
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
    if (registrationState != CONN_STATE_CONNECTED) {
        [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    }
    
    long sID;
    if([[SipStackUtils sharedInstance].audioService makeAudioCallWithRemoteParty:remoteParty andSipStack:[[SipStackUtils sharedInstance].sipService getSipStack]  sessionid:&sID])
    {
        //audioCallViewController
            //[[SipStackUtils sharedInstance].soundService playRingBackTone];
        [[SipStackUtils sharedInstance] setRemotePartyNumber:remoteParty];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UINavigationController *audioCallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallNavigationController"];
        QianLiAudioCallViewController *audioCallViewController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallViewController"];
        audioCallNavigationController.viewControllers = @[audioCallViewController];
        audioCallViewController.remotePartyNumber = remoteParty;
        audioCallViewController.ViewState = Calling;
        QianLiAppDelegate *app = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
        [app.tabController presentViewController:audioCallNavigationController animated:YES completion:nil];
        [SipCallManager SharedInstance].audioVC = audioCallViewController;
        audioCallViewController.audioSessionID = sID;
        NSString *imageSessionID = [NSString stringWithFormat:@"%@%@",[UserDataAccessor getUserRemoteParty], remoteParty];
        [[PictureManager sharedInstance] setImageSession:imageSessionID];
        
        // Add to history record
        DetailHistEvent *event = [[DetailHistEvent alloc] init];
        event.remoteParty = remoteParty;
        event.type = kMediaType_Audio;
        event.status = kHistoryEventStatus_Outgoing;
        event.start = [[NSDate date] timeIntervalSince1970];
        audioCallViewController.activeEvent = event;
        
        // Add to main recent
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:remoteParty Content:NSLocalizedString(@"historyCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoindCall"];
        [Utils updateMainHistNameForRemoteParty:remoteParty];
    }
    else{
        
    }
}

- (void)reconnectVoiceCall:(NSString *)remoteParty
{
    _endWithoutDismissAudioVC = NO;
    _didHavePhoneCall = NO;
    long sID;
    if([[SipStackUtils sharedInstance].audioService makeAudioCallWithRemoteParty:remoteParty andSipStack:[[SipStackUtils sharedInstance].sipService getSipStack]  sessionid:&sID])
    {
        _audioVC.audioSessionID = sID;
    }
}

- (void)resumeCallWithID:(long)callID
{
    if (_audioVC && _endWithoutDismissAudioVC) {
        [SipStackUtils sharedInstance].sessionID = callID;
        _endWithoutDismissAudioVC = NO;
        _didHavePhoneCall = NO;
        _audioVC.audioSessionID = callID;
        [[SipStackUtils sharedInstance].audioService acceptCall];
    }
}

- (void)sendInterruptionMessage:(NSString *)message
{
    [SipCallManager SharedInstance].endWithoutDismissAudioVC = YES;
    [SipCallManager SharedInstance].didHavePhoneCall = NO;
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

- (void)sendNetworkChangeMessage
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kWillChangeNetwork toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[SipCallManager SharedInstance] selector:@selector(handleConnectionChange) userInfo:nil repeats:NO];
}

- (void)handleConnectionChange
{
    [[NgnEngine sharedInstance].sipService stopStackSynchronously];
    [[NgnEngine sharedInstance].sipService registerIdentity];
    [[SipCallManager SharedInstance] sendInterruptionMessage:kChangeNetWork];
}

- (void)setAudioVC:(QianLiAudioCallViewController *)audioVC
{
    _audioVC = audioVC;
    _endWithoutDismissAudioVC = NO;
    _didHavePhoneCall = NO;
    _netDidWorkChanged = NO;
}

- (void)clearCallManager
{
    callManager = nil;
}

#pragma mark -- handling receiving message method--
- (void)receiveIncomingMessage:(NSNotification *)notification
{
    NSString *info = notification.object;
    NSArray* words = [info componentsSeparatedByString:kSeparator];
    NSString *message;
    if ([words count] > 0) {
        message = [words objectAtIndex:0];
    }
    
    if ([message isEqualToString:kInterruption]) {
        _endWithoutDismissAudioVC = YES;
        _didHavePhoneCall = NO;
        [[SipStackUtils sharedInstance].audioService hangUpCall];
    }
    else if ([message isEqualToString:kPhoneCallInterruption]){
        _endWithoutDismissAudioVC = YES;
        _didHavePhoneCall = YES;
        [[SipStackUtils sharedInstance].audioService hangUpCall];
    }
    else if ([message isEqualToString:kEndInterruptionCall]){
        _didEndInerruptionCall = YES;
        [[SipStackUtils sharedInstance].soundService stopInterruptionCall];
    }
    else if ([message isEqualToString:kInterruptionOK]){
        
    }
    else if ([message isEqualToString:kWillChangeNetwork]){
        _netDidWorkChanged = YES;
        _endWithoutDismissAudioVC = YES;
        [[SipStackUtils sharedInstance].messageService sendMessage:kChangeNetworkOK toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    }
    else if ([message isEqualToString:kChangeNetworkOK]){
       // [_timer fire];
    }
    else if ([message isEqualToString:kChangeNetWork]){
         _endWithoutDismissAudioVC = YES;
        _netDidWorkChanged = YES;
        [[SipStackUtils sharedInstance].audioService hangUpCall];
    }
}

@end
