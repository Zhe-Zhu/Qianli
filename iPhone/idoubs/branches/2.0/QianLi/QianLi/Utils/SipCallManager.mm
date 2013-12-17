//
//  SipCallManager.m
//  QianLi
//
//  Created by lutan on 12/2/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import "SipCallManager.h"

@interface SipCallManager ()

@end

@implementation SipCallManager

+(SipCallManager *)SharedInstance
{
    static SipCallManager *callManager = nil;
    if (callManager == nil) {
        callManager = [[SipCallManager alloc] init];
    }
    return callManager;
}

- (void)makeQianliCallToRemote:(NSString *)remoteParty
{
    if ([remoteParty isEqualToString:[UserDataAccessor getUserRemoteParty]]) {
        return;
    }
    
    if (![Utils checkInternetAndDispWarning:YES]) {
        return;
    }
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
    if (registrationState != CONN_STATE_CONNECTED) {
        [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    }
    
    long sID;
    if([[SipStackUtils sharedInstance].audioService makeAudioCallWithRemoteParty:remoteParty andSipStack:[[SipStackUtils sharedInstance].sipService getSipStack]  sessionid:&sID])
    {
        [[SipStackUtils sharedInstance] setRemotePartyNumber:remoteParty];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UINavigationController *audioCallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallNavigationController"];
        QianLiAudioCallViewController *audioCallViewController = (QianLiAudioCallViewController *)audioCallNavigationController.topViewController;
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

@end
