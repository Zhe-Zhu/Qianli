//
//  HistoryRecordsMainViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryRecordsMainViewController.h"
#import "Reachability.h"
#import "APNsTransUtils.h"
#import "UserDataAccessor.h"
#import "MobClick.h"
#import "UserDataTransUtils.h"

#define CellHeight 80

@interface HistoryRecordsMainViewController ()
{
    NSMutableArray *_historyRecords;
}

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) HistroyRecordDetailsViewController *detailCV;

@end

@implementation HistoryRecordsMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAppointment:) name:@"receivedImageNotification" object:nil];
    _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayHistory) name:kHistoryChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    QianLiAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.didJustLaunch) {
        appDelegate.didJustLaunch = NO;
        [[HistoryTransUtils sharedInstance] getHistoryInBackground:NO];
    }
    NSIndexPath *selectdPath = [_historyTableView indexPathForSelectedRow];
    [_historyTableView deselectRowAtIndexPath:selectdPath animated:YES];
    // Connect to server to get unanwsered calls
    [self displayHistory];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateActive) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    QianLiAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setTabItemBadge:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)displayHistory
{
    [self loadHistory];
    [self.historyTableView reloadData];
}

- (void)loadHistory
{
    if (!_historyRecords) {
        _historyRecords = [[NSMutableArray alloc] initWithCapacity:1];
    }
    else{
        [_historyRecords removeAllObjects];
    }
    
    // Sort the entries in history array
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray;
    
    sortedArray = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:[[MainHistoryDataAccessor sharedInstance] getAllObjects]] sortedArrayUsingDescriptors:sortDescriptors]];
    for (int i = 0; i < [sortedArray count]; ++i) {
        NSManagedObject *object = [sortedArray objectAtIndex:i];
        MainHistoryEntry *entry = [[MainHistoryEntry alloc] init];
        entry.content = [object valueForKey:@"content"];
        entry.remoteParty = [object valueForKey:@"remoteParty"];
        entry.time = [[object valueForKey:@"time"] doubleValue];
        entry.type = [object valueForKey:@"type"];
        entry.name = [object valueForKey:@"name"];
        if (!entry.name) {
            [UserDataTransUtils getUserData:entry.remoteParty Completion:^(NSString *name, NSString *avatarURL) {
                entry.name = name;
                [[MainHistoryDataAccessor sharedInstance] updateNameForRemotyParty:entry.remoteParty withName:name];
            }];
        }
        entry.profile = [[QianLiContactsAccessor sharedInstance] getProfileForRemoteParty: [object valueForKey:@"remoteParty"]];
        [_historyRecords addObject:entry];
    }
}

- (void)restoreHistory
{
    [self loadHistory];
    if (_detailCV) {
        [_detailCV loadDetailHistory];
    }
}

- (void)clearHistory
{
    [_historyRecords removeAllObjects];
    if (_detailCV) {
        [_detailCV clearDetailHistory];
    }
}

# pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_historyRecords count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainHistoryEntry *entry = (MainHistoryEntry *) [_historyRecords objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"HistoryMainCell";
	HistoryMainCell *historyCell = (HistoryMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // 因为所继承的cell每次都把view清理,所以每次都要重新Init一遍,否则backview会丢失
    
    historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    historyCell.historyMainCelldelegate = self;
    UIImage *avatar = entry.profile;
    if (avatar == nil) {
        avatar = [UIImage imageNamed:@"blank.png"];
    }
    NSString *name = entry.name;
    if (name == nil) {
        name = NSLocalizedString(@"unknownName", nil);
    }
    
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:entry.time] Content:entry.content];
    if ([entry.type isEqualToString:@"MissedCall"]) {
        [historyCell isMissedCall:YES];
    }
    
    if ([entry.type isEqualToString:kMainHistAppMark]) {
        [historyCell activateRequestStatus];
    }
    
    return historyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _detailCV = [storyboard instantiateViewControllerWithIdentifier:@"HistoryDetailController"];
    MainHistoryEntry *entry = (MainHistoryEntry *) [_historyRecords objectAtIndex:indexPath.row];
    _detailCV.title = entry.name;
    _detailCV.remotePartyPhoneNumber = entry.remoteParty;
    // 进入detailView时自动隐藏Tabbar
    _detailCV.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:_detailCV animated:YES];
}

#pragma mark -- HistoryMainCellDelegate --
- (void)sendRequest:(HistoryMainCell *)historyMainCell
{
    if (![Utils checkInternetAndDispWarning:YES]) {
        return;
    }
    // send some request
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:historyMainCell selector:@selector(stopSpin) userInfo:nil repeats:NO];
    NSIndexPath *indexPath = [_historyTableView indexPathForCell:historyMainCell];
    MainHistoryEntry *entry = (MainHistoryEntry *)[_historyRecords objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"%@%@%@", kAppointment,kSeparator,[UserDataAccessor getUserRemoteParty]];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:entry.remoteParty];
    
    // Add to history record TODO: modify the media_type of the event
    NgnHistoryAVCallEvent *event = [[NgnHistoryAVCallEvent alloc] init:NO withRemoteParty:entry.remoteParty];
    event.status = HistoryEventStatus_Appointment;
    [[SipStackUtils sharedInstance].historyService addEvent:event];
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:entry.remoteParty Content:NSLocalizedString(@"historyAppointment", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"MakeAppointment"];
    [Utils updateMainHistNameForRemoteParty:entry.remoteParty];
    
    [NSTimer scheduledTimerWithTimeInterval:1.4 target:self selector:@selector(displayHistory) userInfo:nil repeats:NO];
    
    // send push notification
    [APNsTransUtils postAPNsTo:entry.remoteParty sender:[UserDataAccessor getUserRemoteParty] type:@"1" completion:nil];
    
    [MobClick event:@"makeAppointment" label:@"Swipe"];
}

- (void)cancelRequest:(HistoryMainCell *)historyMainCell
{
    NSIndexPath *indexPath = [_historyTableView indexPathForCell:historyMainCell];
    MainHistoryEntry *entry = (MainHistoryEntry *)[_historyRecords objectAtIndex:indexPath.row];
    [[MainHistoryDataAccessor sharedInstance] updateTypeForRemotyParty:entry.remoteParty withType:@"AppointmentCancelled"];
    [self displayHistory];
}

- (void)makeACall:(HistoryMainCell *)historyMainCell
{
    NSIndexPath *indexPath = [_historyTableView indexPathForCell:historyMainCell];
    MainHistoryEntry *entry = (MainHistoryEntry *)[_historyRecords objectAtIndex:indexPath.row];
    [self call:entry.remoteParty];
}

- (void)receiveAppointment:(NSNotification *)notification
{
    NSString *info = notification.object;
    NSArray* words = [info componentsSeparatedByString:kSeparator];
    if ([[words objectAtIndex:0] isEqualToString:kAppointment]) {
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
            [[HistoryTransUtils sharedInstance] getHistoryInBackground:YES];
        }
    }
}

// TODO: 考虑把call作为全局函数, 目前太多相同的地方了
- (void)call:(NSString *)remotePartyPhoneNumber
{
    if ([remotePartyPhoneNumber isEqualToString:[UserDataAccessor getUserRemoteParty]]) {
        return;
    }
    
    if (![Utils checkInternetAndDispWarning:YES]) {
        return;
    }
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
    if (registrationState != CONN_STATE_CONNECTED) {
        [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    }
    
    [[SipStackUtils sharedInstance] setRemotePartyNumber:remotePartyPhoneNumber];
    NSString *remoteUri  = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *audioCallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallNavigationController"];
    QianLiAudioCallViewController *audioCallViewController = (QianLiAudioCallViewController *)audioCallNavigationController.topViewController;
    audioCallViewController.ViewState = Calling;
    audioCallViewController.remotePartyNumber = remoteUri;
    [self presentViewController:audioCallNavigationController animated:YES completion:nil];
    
    long sID;
    if([[SipStackUtils sharedInstance].audioService makeAudioCallWithRemoteParty:remoteUri andSipStack:[[SipStackUtils sharedInstance].sipService getSipStack]  sessionid:&sID])
    {
        audioCallViewController.audioSessionID = sID;
        NSString *imageSessionID = [NSString stringWithFormat:@"%@%@",[UserDataAccessor getUserRemoteParty],remoteUri];
        [[PictureManager sharedInstance] setImageSession:imageSessionID];
        
        // Add to history record
        NgnHistoryAVCallEvent *event = [[NgnHistoryAVCallEvent alloc] init:NO withRemoteParty:remotePartyPhoneNumber];
        audioCallViewController.activeEvent = event;
        event.start = [[NSDate date] timeIntervalSince1970];
        event.status = HistoryEventStatus_Outgoing;
        //[[SipStackUtils sharedInstance].historyService addEvent:event];
        
        // Add to main recent
//        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:remotePartyPhoneNumber Content:[NSString stringWithFormat:@"Called %@",[[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:remotePartyPhoneNumber]] Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoindCall"];
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:remotePartyPhoneNumber Content:NSLocalizedString(@"historyCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"OutGoindCall"];
        [Utils updateMainHistNameForRemoteParty:remotePartyPhoneNumber];
    }
    else{
    }
    
    [MobClick event:@"makeCall" label:@"swipe"];
}

@end
