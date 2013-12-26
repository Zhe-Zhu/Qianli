//
//  HistroyRecordDetailsViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistroyRecordDetailsViewController.h"
#import "Reachability.h"
#import "QianLiContactsAccessor.h"
#import "MobClick.h"
#import "APNsTransUtils.h"
#import "SipCallManager.h"

@interface HistroyRecordDetailsViewController ()
{
    NSMutableArray *_chatRecords; // chatRecords每个数组元素的内容包括: cellType(描述该cell展示的内容,是通话记录还是照片等), cellContent(cell的内容,根据不同的type,内容不同,可能是照片数组或者是指示符)
    // 在cellType中1代表通话记录, 2代表照片
    QianLiTableMenuBar *menuBar;
    NSInteger loadTimes;
}


@property (weak, nonatomic) IBOutlet UITableView *historyDetailTableView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (assign, nonatomic) BOOL shouldLoad;
@property (strong, nonatomic) UIImageView *cover;
- (IBAction)call:(id)sender;

@end

@implementation HistroyRecordDetailsViewController

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
    _shouldLoad = NO;
    loadTimes = 1;
   // [self editHistory:nil];
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more.png"] landscapeImagePhone:[UIImage imageNamed:@"more.png"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonMorePressed)];
    if (!IS_OS_7_OR_LATER) {
        more = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"historyDetailMore", nil) style:UIBarButtonItemStylePlain target:self action:@selector(buttonMorePressed)];
    }
    more.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:more];
    //[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // 加入遮盖原view的imageview
    UITapGestureRecognizer *tapCover = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenuBar)];
    _cover = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0;
    [_cover addGestureRecognizer:tapCover];
    _cover.userInteractionEnabled = YES;
    [self.view addSubview:_cover];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayHistoryWithEntryNumber) name:kHistoryChangedNotification object:nil];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayHistoryWithEntryNumber];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 如果Menu Bar升起则将其dismiss
    [super viewWillDisappear:animated];
    if (menuBar) {
        [self dismissMenuBar];
        menuBar=nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)displayHistoryWithEntryNumber
{
    [self loadDetailHistory];
    [self.historyDetailTableView reloadData];
}

- (void)loadDetailHistory
{
    
    if (!_chatRecords) {
        _chatRecords = [[NSMutableArray alloc] initWithCapacity:1];
    }
    else{
        [_chatRecords removeAllObjects];
    }
    
//    [[SipStackUtils sharedInstance].historyService loadWithRemoteParty:_remotePartyPhoneNumber WithEntriesLength:loadTimes * 12];
//    // Sort the entries in history array
//    NSSortDescriptor *sortDescriptor;
//    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSMutableArray *sortedArray;
//    sortedArray = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:[[[SipStackUtils sharedInstance].historyService events] allValues]] sortedArrayUsingDescriptors:sortDescriptors]];
    _chatRecords = [NSMutableArray array];
    NSArray *array = [[DetailHistoryAccessor sharedInstance] getDetailHistForRemoteParty:_remotePartyPhoneNumber withNumber:loadTimes * 12];
    for (NSManagedObject *object in array) {
        DetailHistEvent *detailHist = [[DetailHistEvent alloc] init];
        detailHist.content = [object valueForKey:@"content"];
        detailHist.status = [object valueForKey:@"status"];
        detailHist.start = [[object valueForKey:@"start"] doubleValue];
        detailHist.end = [[object valueForKey:@"end"] doubleValue];
        detailHist.type = [object valueForKey:@"type"];
        detailHist.remoteParty = [object valueForKey:@"remoteParty"];
        [_chatRecords addObject:detailHist];
    }
}

- (void)clearDetailHistory
{
    [_chatRecords removeAllObjects];
}

- (void)loadMoreMessages
{
    if ([_chatRecords count] < loadTimes * 12) {
        return;
    }
    loadTimes ++;
    [self displayHistoryWithEntryNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryDetailCell *cell = (HistoryDetailCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return CGRectGetHeight(cell.frame);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chatRecords count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryDetailCell";
    
	HistoryDetailCell *historyCell = (HistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (historyCell == nil) {
		historyCell = [[HistoryDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    DetailHistEvent *history = (DetailHistEvent *)[_chatRecords objectAtIndex:indexPath.row];
    NSInteger recordType = 1;
    if ([history.status isEqualToString: kHistoryEventStatus_Outgoing]) {
        recordType = 1;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            double duration = history.end - history.start;
            int minutes = floor(duration / 60);
            int seconds = floor(duration - minutes * 60);
            NSString *str;
            if (minutes > 0) {
                str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTime", nil), minutes, seconds];
            }
            else{
                str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTimeSecond", nil), seconds];
            }
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: str];
        }
    }
    else if ([history.status isEqualToString:kHistoryEventStatus_OutgoingCancelled]){
        recordType = 1;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailCancel", nil)];
        }
    }
    else if ([history.status isEqualToString:kHistoryEventStatus_OutgoingRejected]){
        recordType = 1;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailReject", nil)];
        }
    }
    else if ([history.status isEqualToString: kHistoryEventStatus_Incoming]){
        recordType = 2;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            double duration = history.end - history.start;
            int minutes = floor(duration / 60);
            int seconds = floor(duration - minutes * 60);
            NSString *str;
            if (minutes > 0) {
                str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTime", nil), minutes, seconds];
            }
            else{
                str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTimeSecond", nil), seconds];
            }
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: str];
        }
    }
    else if ([history.status isEqualToString: kHistoryEventStatus_IncomingCancelled]){
        recordType = 2;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailCancel", nil)];
        }
    }
    else if ([history.status isEqualToString: kHistoryEventStatus_IncomingRejected]){
        recordType = 2;
        if ([history.type isEqualToString: kMediaType_Audio]) {
            [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailReject", nil)];
        }
    }
    else if ([history.status isEqualToString: kHistoryEventStatus_Missed]){
        // add missed call history
        recordType = 3;
        [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailMissedCall", nil)];
    }
    else if ([history.status isEqualToString: kHistoryEventStatus_Appointment]){
        recordType = 4;
        [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote: NSLocalizedString(@"historyDetailAppointment", nil)];
    }
    
    
    if ([history.type isEqualToString: kMediaType_Image]){
        NgnHistoryImageEvent *event = (NgnHistoryImageEvent *)history;
        NSArray *imageArray = [NSKeyedUnarchiver unarchiveObjectWithData:event.content];
        double duration = history.end - history.start;
        int minutes = floor(duration / 60);
        int seconds = floor(duration - minutes * 60);
        NSString *str;
        if (minutes > 0) {
            str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTime", nil), minutes, seconds];
        }
        else{
            str = [NSString stringWithFormat:NSLocalizedString(@"historyDetailTimeSecond", nil), seconds];
        }
        [historyCell setCallRecord:recordType timeLabel:[Utils readableTimeFromSecondsSince1970LikeWeixin:history.start] footnote:str images:imageArray];
    }
    
    return historyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"selected row %d",  indexPath.row);
}

// ScrollView Delegate;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= MAX(scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom, 0))
    {
        _shouldLoad = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (menuBar) {
        [menuBar dismiss];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_shouldLoad) {
        _shouldLoad = NO;
        [self loadMoreMessages];
    }
}

- (IBAction)call:(id)sender
{
    [[SipCallManager SharedInstance] makeQianliCallToRemote:_remotePartyPhoneNumber];
    [MobClick event:@"makeCall" label:@"touch"];
}

- (void)sendRequest
{
    if (![Utils checkInternetAndDispWarning:YES]) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@%@%@", kAppointment,kSeparator,[UserDataAccessor getUserRemoteParty]];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:_remotePartyPhoneNumber];
    
    DetailHistEvent *event = [[DetailHistEvent alloc] init];
    event.remoteParty = _remotePartyPhoneNumber;
    event.type = kMediaType_Audio;
    event.status = kHistoryEventStatus_Appointment;
    event.start = [[NSDate date] timeIntervalSince1970];
    event.end = event.start;
    [[DetailHistoryAccessor sharedInstance] addHistEntry:event];
    
    [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:_remotePartyPhoneNumber Content:NSLocalizedString(@"historyAppointment", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"MakeAppointment"];
    //    [self displayHistory];
    [Utils updateMainHistNameForRemoteParty:_remotePartyPhoneNumber];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayHistory) userInfo:nil repeats:NO];
    
    // send push notification
    [APNsTransUtils postAPNsTo:_remotePartyPhoneNumber sender:[UserDataAccessor getUserRemoteParty] type:@"1" completion:nil];
    
    [self dismissMenuBar];
    
    [MobClick event:@"makeAppointment" label:@"touch"];
}

- (void)displayHistory
{
    [self loadDetailHistory];
    [self.historyDetailTableView reloadData];
}

- (void)clearAll
{
    loadTimes = 1;
    [[DetailHistoryAccessor sharedInstance] deleteHistoryForRemoteParty:_remotePartyPhoneNumber];
    [[MainHistoryDataAccessor sharedInstance] deleteObjectForRemoteParty:_remotePartyPhoneNumber];
    [self displayHistoryWithEntryNumber];
    [self dismissMenuBar];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)buttonMorePressed
{
    if (menuBar) {
        if (menuBar.isShow==YES) {
//            [menuBar dismiss];
            [self dismissMenuBar];
            return;
        }
    }
//    // 加入遮盖原view的imageview
//    UIImageView *cover = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    cover.backgroundColor = [UIColor blackColor];
//    cover.alpha = 0;
//    [self.view addSubview:cover];
    
    [self showCover];
    
    CGSize size = CGSizeMake(self.view.bounds.size.width, 60);
    QianLiTableMenuBarItem *item1 = [[QianLiTableMenuBarItem alloc] initWithTitle:NSLocalizedString(@"historyDetailMoreCall", nil) target:self image:[UIImage imageNamed:@"phoneBlack.png"] action:@selector(call:) size:size];
    QianLiTableMenuBarItem *item2 = [[QianLiTableMenuBarItem alloc] initWithTitle:NSLocalizedString(@"historyDetailMoreAppointment", nil) target:self image:[UIImage imageNamed:@"appointment.png"] action:@selector(sendRequest) size:size];
    QianLiTableMenuBarItem *item3 = [[QianLiTableMenuBarItem alloc] initWithTitle:NSLocalizedString(@"historyDetailMoreClear", nil) target:self image:[UIImage imageNamed:@"trash.png"] action:@selector(clearAll) size:size];
    [item3 highlight];
    
    menuBar = [[QianLiTableMenuBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, size.height*3) items:@[item1, item2, item3]];
    menuBar.delegate = self;
    [menuBar show];
}

- (void)showCover
{
    [UIView animateWithDuration:0.2 animations:^{
        _cover.alpha = 0.35;
    }];
}

- (void)dismissMenuBar
{
    [menuBar dismiss];
    [UIView animateWithDuration:0.2 animations:^{
        _cover.alpha = 0.0;
    }];
}

@end
