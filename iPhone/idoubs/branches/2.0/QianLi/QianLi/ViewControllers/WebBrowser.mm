//
//  WebBrowser.m
//  QianLi
//
//  Created by lutan on 10/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "WebBrowser.h"
#import "WebHistoryDataAccessor.h"
#import "WebHistoryCell.h"
#import "SipStackUtils.h"
#import "Global.h"
#import "MobClick.h"
#import "SVProgressHUD.h"

#define ToolBarHeight 48

@interface WebBrowser ()
{
    float offsetY;
    BOOL didControlsHide;
    BOOL didJustLoad;
    BOOL isUserInput;
}

@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *synButton;
@property (weak, nonatomic) IBOutlet UITextField *urlInput;
@property (weak, nonatomic) IBOutlet UIImageView *urlInputUIImageView;
@property (weak, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *currentURL;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) UIView *tableBackView;
@property (weak, nonatomic) UITableView *histTableView;
@property (nonatomic, strong) NSMutableArray *historyArray;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *checkMarkImageView;
@property (strong, nonatomic) UIImageView *crossImageView;
@property (strong, nonatomic) NSTimer *stopSynTimer;

- (IBAction)synChronize:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)openHistory:(id)sender;
- (IBAction)goButtonPressed:(id)sender;

@end

@implementation WebBrowser

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
    CGRect winSize = [UIScreen mainScreen].bounds;
    UIWebView *interView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 62, 320, winSize.size.height - 62)];
    _webView = interView;
    [self.view addSubview:_webView];
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    
    _toolbar.backgroundColor = [UIColor whiteColor];
    [self.view bringSubviewToFront:_toolbar];
    [self.view bringSubviewToFront:_urlInputUIImageView];
    [self.view bringSubviewToFront:_urlInput];
    [self.view bringSubviewToFront:_synButton];
    [self.view bringSubviewToFront:_goButton];
    _backButton.enabled = NO;
    _forwardButton.enabled = NO;
    
    offsetY = 0;
    didControlsHide = NO;
    didJustLoad = YES;
    
    _urlInput.clearsOnBeginEditing = YES;
    _urlInput.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator = activityIndicator;
    [_activityIndicator sizeToFit];
    [_activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [_activityIndicator setFrame:CGRectMake(CGRectGetMinX(_activityIndicator.frame)+3, CGRectGetMinY(_activityIndicator.frame)+3, CGRectGetWidth(_activityIndicator.frame), CGRectGetHeight(_activityIndicator.frame))];
    
    _checkMarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkForSync.png"]];
    [_checkMarkImageView setFrame:CGRectMake(CGRectGetMinX(_checkMarkImageView.frame)+3, CGRectGetMinY(_checkMarkImageView.frame)+3, CGRectGetWidth(_checkMarkImageView.frame), CGRectGetHeight(_checkMarkImageView.frame))];
    _crossImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crossForSync.png"]];
    [_crossImageView setFrame:CGRectMake(CGRectGetMinX(_crossImageView.frame)+3, CGRectGetMinY(_crossImageView.frame)+3, CGRectGetWidth(_crossImageView.frame), CGRectGetHeight(_crossImageView.frame))];
    
    [_synButton addSubview:_activityIndicator];
    [_synButton addSubview:_checkMarkImageView];
    [_synButton addSubview:_crossImageView];
    
    CGPoint center = _synButton.center;
    _synButton.center = CGPointMake(center.x, 41);
    _checkMarkImageView.alpha = 0;
    _crossImageView.alpha = 0;
    
    _fromRemote = NO;
    _urlInput.center = CGPointMake(_urlInput.center.x, 41);
    _urlInput.placeholder = NSLocalizedString(@"urlInput", nil);
    [_synButton setTitle:NSLocalizedString(@"Synchronize", nil) forState:UIControlStateNormal];
    [_goButton setTitle:NSLocalizedString(@"go", nil) forState:UIControlStateNormal];
    [_cancelButton setTitle:NSLocalizedString(@"Quit", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: YES];
    [MobClick beginEvent:@"browseAnyWebsite"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGPoint faButtonCenter = _synButton.center;
    _synButton.center = CGPointMake(faButtonCenter.x, 41);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endEvent:@"browseAnyWebsite"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _webView.delegate = nil;
}

#pragma mark --UITextFieldDelegate--

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.frame = CGRectMake(CGRectGetMinX(textField.frame), CGRectGetMinY(textField.frame), CGRectGetWidth(textField.frame)-CGRectGetWidth(_goButton.frame), CGRectGetHeight(textField.frame));
    
    [_synButton setEnabled:NO];
    [_synButton setAlpha:0.5];
    
    //展示前往按钮
    [_goButton setHidden:NO];
    
    isUserInput = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *searchString = _urlInput.text;
    NSURL *url;
    if ([self validateUrl:searchString]) {
        if ([searchString hasPrefix:@"http://"] || [searchString hasPrefix:@"https://"]){
            url = [NSURL URLWithString:searchString];
        }
        else{
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", searchString]];
        }
    }
    if (url == nil) {
        if (![searchString isEqualToString:@""]) {
            url =  [NSURL URLWithString: [NSString stringWithFormat:@"http://www.google.com/search?q=%@", searchString]];
        // 为了照顾国内用户,换为baidu搜索,今后根据实际情况调整
//        url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.baidu.com/baidu?tn=baidu&word=%@", searchString]];
        // 发现该方法展示的baidu界面不能对手机屏幕自适应,所以转回使用google搜索
        }
        else {
            url = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.baidu.com/"]];
        }
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // 还原同步和前往按钮
    textField.frame = CGRectMake(CGRectGetMinX(textField.frame), CGRectGetMinY(textField.frame), CGRectGetWidth(textField.frame)+CGRectGetWidth(_goButton.frame), CGRectGetHeight(textField.frame));
    
    [_synButton setEnabled:YES];
    [_synButton setAlpha:1];
    [_goButton setHidden:YES];
}

- (void)goButtonPressed:(id)sender
{
    [_urlInput resignFirstResponder];
}

- (BOOL)validateUrl: (NSString *) candidate
{
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            return YES;
        }
    }
    return NO;
}

#pragma mark  -- UIWebViewDelegate --
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_urlInput.text && isUserInput) {
        NSURL *url =  [NSURL URLWithString: [NSString stringWithFormat:@"http://www.google.com/search?q=%@", _urlInput.text]];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        isUserInput = NO;
    }
    else {
        [_webView stopLoading];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [request.URL absoluteString];
    if (![url isEqualToString:@"about:blank"]) {
        self.currentURL = url;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!didJustLoad) {
        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSString *url = [[[webView request] URL] absoluteString];
        [[WebHistoryDataAccessor sharedInstance] update:title url:url type:@"HISTORY"];
    }
    else{
        didJustLoad = NO;
    }
    
    if (![_webView canGoBack]) {
        _backButton.enabled = NO;
    }
    else{
        _backButton.enabled = YES;
    }
    
    if (![_webView canGoForward]) {
        _forwardButton.enabled = NO;
    }
    else{
        _forwardButton.enabled = YES;
    }
    
    if (_fromRemote) {
//        if ([[[webView.request URL] absoluteString] isEqualToString:_remoteURL]) {
            _fromRemote = NO;
            [self setOffset:_remoteOffset];
//        }
    }
    
    _urlInput.text = [[webView.request URL] absoluteString];
    
    NSString *str = [webView.request.URL absoluteString];
    if (![_currentURL isEqualToString:str]) {
        self.currentURL = str;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"did start url:%@", [[webView.request URL] absoluteString]);
//    _urlInput.text = [[webView.request URL] absoluteString];
    
//    if (_fromRemote) {
////        if ([[[webView.request URL] absoluteString] isEqualToString:_remoteURL]) {
//            _fromRemote = NO;
//            [self setOffset:_remoteOffset];
////        }
//    }
}

- (void)setOffset:(CGPoint)offset
{
    _webView.scrollView.scrollEnabled = TRUE;
    [_webView.scrollView setContentOffset:offset animated:YES];
//    NSString *scrollString = [NSString stringWithFormat:@"window.scrollTo(%d, %d);", int(offset.x), int(offset.y)];
  //  [_webView stringByEvaluatingJavaScriptFromString:scrollString];
    //  it seems to work
}

- (IBAction)synChronize:(id)sender {
    if (kIsCallingQianLiRobot) {
        kQianLiRobotSharedWebNum++;
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QianLiRobotSynWeb", nil),[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]]];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(synSuccessed) userInfo:nil repeats:NO];
    }
    // 对网页内容进行同步
    float offsetx = _webView.scrollView.contentOffset.x;
    float offsety = _webView.scrollView.contentOffset.y;
    NSString *message = [NSString stringWithFormat:@"%@%@%@%@%f%@%f", kBrowserSyn, kSeparator, /*[[_webView.request URL] absoluteString]*/ _currentURL, kSeparator,offsetx, kSeparator, offsety];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];

    [_synButton setTitle:@"" forState:UIControlStateNormal];
    [_activityIndicator startAnimating];
    _stopSynTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(stopSyn) userInfo:nil repeats:NO];
}

- (void)synSuccessed
{
    [_activityIndicator stopAnimating];
    // Show the Checkmark
    _checkMarkImageView.alpha = 1;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(backToNormalButton) userInfo:nil repeats:NO];
    
    // Stop the stopsyn timer
    [_stopSynTimer invalidate];
    _stopSynTimer = nil;
}

- (void)stopSyn
{
    [_activityIndicator stopAnimating];
    _crossImageView.alpha = 1;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(backToNormalButton) userInfo:nil repeats:NO];
}

- (void)backToNormalButton
{
    _crossImageView.alpha = 0;
    _checkMarkImageView.alpha = 0;
    [_synButton setTitle:NSLocalizedString(@"Synchronize", nil) forState:UIControlStateNormal];
}

- (void)loadWebWithURL:(NSString *)url
{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)cancelFromRemoteParty
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelBrowser toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (IBAction)goForward:(id)sender
{
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}

- (IBAction)openHistory:(id)sender
{
    [self loadHistory];
    CGRect winSize = [UIScreen mainScreen].bounds;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.size.height, 320, winSize.size.height)];
    _tableBackView = view;
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor darkGrayColor];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self action:@selector(cancelHistory) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(15, 25, 60, 30);
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    [view addSubview:cancelButton];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearButton addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
    clearButton.frame = CGRectMake(260, 25, 45, 30);
    [clearButton setTintColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
    [clearButton setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
    [view addSubview:clearButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, winSize.size.height - 60)];
    _histTableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [view addSubview:tableView];
    
    [self.view addSubview:_tableBackView];
    [_histTableView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        _tableBackView.frame = CGRectMake(0, 0, 320, winSize.size.height);
    } completion:nil];
}

- (void)loadHistory
{
    if (_historyArray == nil) {
        _historyArray = [NSMutableArray array];
    }
    else{
        [_historyArray removeAllObjects];
    }
    NSArray *arry = [[WebHistoryDataAccessor sharedInstance] getAllObjectsWithType:@"HISTORY"];
    for (int i = [arry count] - 1; i >= 0; --i) {
        [_historyArray addObject:[arry objectAtIndex:i]];
    }
}

- (void)cancelHistory
{
    CGRect winSize = [UIScreen mainScreen].bounds;
    CGRect rect = _tableBackView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        _tableBackView.frame = CGRectMake(0, winSize.size.height, rect.size.width, rect.size.height);
    } completion:^(BOOL finished) {
        [_tableBackView removeFromSuperview];
        _historyArray = nil;
    }];
}

- (void)clearHistory
{
    [[WebHistoryDataAccessor sharedInstance] deleteObjectForType:@"HISTORY"];
    [_historyArray removeAllObjects];
    [_histTableView reloadData];
}

#pragma mark --UIScrollViewDelegare --
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    offsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > offsetY + 5) {
        if (!didControlsHide) {
            [self hideControls];
        }
    }
    else if (scrollView.contentOffset.y < offsetY - 5){
        if (didControlsHide) {
            [self showControls];
        }
    }
}

- (void)hideControls
{
    CGRect winSize = self.view.frame;
    CGPoint urlInputCenter = _urlInput.center;
    CGPoint faButtonCenter = _synButton.center;
    CGPoint urlInputImageCenter = _urlInputUIImageView.center;
    didControlsHide = YES;
    [UIView animateWithDuration:0.2 animations:^{
        _urlInputUIImageView.center = CGPointMake(urlInputImageCenter.x, -_urlInputUIImageView.frame.size.height / 2.0);
        _urlInput.center = CGPointMake(urlInputCenter.x, -_urlInput.frame.size.height / 2.0);
        _synButton.center = CGPointMake(faButtonCenter.x, -_synButton.frame.size.height / 2.0);
        _toolbar.center = CGPointMake(160, winSize.size.height + _toolbar.frame.size.height / 2.0);
        _webView.frame = CGRectMake(0, 20, 320, winSize.size.height - 20);
        _goButton.center = CGPointMake(_goButton.center.x, -_goButton.frame.size.height / 2.0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showControls
{
    CGRect winSize = self.view.frame;
    CGPoint urlInputCenter = _urlInput.center;
    CGPoint faButtonCenter = _synButton.center;
    CGPoint urlInputImageCenter = _urlInputUIImageView.center;
    didControlsHide = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _urlInputUIImageView.center = CGPointMake(urlInputImageCenter.x, 41);
        _urlInput.center = CGPointMake(urlInputCenter.x, 41);
        _synButton.center = CGPointMake(faButtonCenter.x, 41);
        _toolbar.center = CGPointMake(160, winSize.size.height - _toolbar.frame.size.height / 2.0);
        _webView.frame = CGRectMake(0, 62, 320, winSize.size.height - 62);
        _goButton.center = CGPointMake(_goButton.center.x, 41);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_historyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WebHistoryCell";
    
	WebHistoryCell *cell = (WebHistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[WebHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.frame = CGRectMake(0.0, 0.0, 320.0, 60);
    }
    NSManagedObject *object = [_historyArray objectAtIndex:indexPath.row];
    
    cell.urlLabel.text = (NSString *)[object valueForKey:@"url"];
    cell.titelLabel.text = (NSString *)[object valueForKey:@"title"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [_historyArray objectAtIndex:indexPath.row];
    NSString *url = (NSString *)[object valueForKey:@"url"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    CGRect winSize = [UIScreen mainScreen].bounds;
    CGRect rect = _tableBackView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        _tableBackView.frame = CGRectMake(0, winSize.size.height, rect.size.width, rect.size.height);
    } completion:^(BOOL finished) {
        [_tableBackView removeFromSuperview];
        _historyArray = nil;
    }];
}

@end
