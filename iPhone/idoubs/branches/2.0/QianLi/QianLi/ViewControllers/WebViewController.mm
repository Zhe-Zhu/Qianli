//
//  WebViewController.m
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//  CODEREVIEW DONE

#import "WebViewController.h"
#import "Global.h"
#import "SipStackUtils.h"
#import "UIImageExtras.h"
#import "MobClick.h"

#define MaxiNum 3

@interface WebViewController ()

@property (strong, nonatomic) NSString *request;
@property (weak, nonatomic) NSTimer *stopSynTimer;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIBarButtonItem *normalSynButton;
@property (strong, nonatomic) UIBarButtonItem *loadingSynButton;
@property (strong, nonatomic) UIBarButtonItem *checkMarkButton;
@property (strong, nonatomic) UIBarButtonItem *crossButton;
@property (strong, nonatomic) UIBarButtonItem *moreButton;
@property (strong, nonatomic) NSMutableArray *synImages;
@property (assign, nonatomic) double beginTime;

@end

@implementation WebViewController

@synthesize actionSheet = _actionSheet;

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
    if (_initialURL == Nil || (NSNull *)_initialURL == [NSNull null]) {
        // 跳转到让用户输入URL的界面
    }
    else {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_initialURL]]];
    }
    
    _webView.delegate = self;
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showMore)];
    _moreButton = moreButton;
    self.navigationItem.rightBarButtonItem = moreButton;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator = activityIndicator;
    [_activityIndicator sizeToFit];
    [_activityIndicator setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    _loadingSynButton = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    
    UIImageView *checkMarkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkForSync.png"]];
    _checkMarkButton = [[UIBarButtonItem alloc] initWithCustomView:checkMarkImage];
    _checkMarkButton.tintColor = [UIColor colorWithRed:16/255.0 green:169/255.0 blue:16/255.0 alpha:1.0f];
    
    _crossButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"crossForSync.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
    _crossButton.tintColor = [UIColor colorWithRed:169/255.0 green:16/255.0 blue:16/255.0 alpha:1.0f];
    
    _normalSynButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Synchronize", nil) style:UIBarButtonItemStylePlain target:self action:@selector(synchronize)];
    self.navigationItem.leftBarButtonItem = _normalSynButton;
    _fromRemote = NO;
    
    //record the beginning time
    _beginTime = [[NSDate date] timeIntervalSince1970];
    
    if (!IS_OS_7_OR_LATER) {
        UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonPressed = [[UIImage imageNamed:@"barButtonBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonPressed = [[UIImage imageNamed:@"barButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonDisabled = [[UIImage imageNamed:@"barButtonBackDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonDisabled = [[UIImage imageNamed:@"barButtonDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6CallNavigationBackground.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, 320, 44)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blueColor]];
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginEvent:@"browseShopping"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endEvent:@"browseShopping"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_synImages removeAllObjects];
}

- (void)loadWebWithURL:(NSString *)url
{
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)showMore
{
    UIActionSheet *chooesPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"webEndBrowser", nil) otherButtonTitles:NSLocalizedString(@"taobao", nil),NSLocalizedString(@"yhd", nil), NSLocalizedString(@"jd", nil), nil];
    [chooesPhoto showInView:self.view];
    _actionSheet = chooesPhoto;
}

- (void)synchronize
{
    // 对网页内容进行同步
    //CODE_REVIEW:在iphone4S和iphone5上测试，不能同步。
    float offsetx = _webView.scrollView.contentOffset.x;
    float offsety = _webView.scrollView.contentOffset.y;
    NSString *message = [NSString stringWithFormat:@"%@%@%@%@%f%@%f", kShoppingSyn, kSeparator, _request, kSeparator,offsetx, kSeparator, offsety];
    [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    
    // Change to UIActivityView
    self.navigationItem.leftBarButtonItem = _loadingSynButton;
    [_activityIndicator startAnimating];
    _stopSynTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(stopSyn) userInfo:nil repeats:NO];
}

- (void)synSuccessed
{
    [_activityIndicator stopAnimating];
    // Show the Checkmark
    [self.navigationItem setLeftBarButtonItem:_checkMarkButton animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(backToNormalButton) userInfo:nil repeats:NO];
    
    // Stop the stopsyn timer
    [_stopSynTimer invalidate];
    _stopSynTimer = nil;
    
    // add to history
    [self addImages:[Utils screenshot:self.view toSize:CGSizeMake(HistoryImageSize, HistoryImageSize)]];
}

- (void)backToNormalButton
{
    [self.navigationItem setLeftBarButtonItem:_normalSynButton animated:YES];
}

- (void)stopSyn
{
    if (self.navigationItem.leftBarButtonItem == _loadingSynButton) {
        [_activityIndicator stopAnimating];
        [self.navigationItem setLeftBarButtonItem:_crossButton animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(backToNormalButton) userInfo:nil repeats:NO];
    }
}

- (void)addImages:(UIImage *)image;
{
    if (_synImages == nil) {
        _synImages = [NSMutableArray array];
    }
    if ([_synImages count] == MaxiNum) {
        [_synImages removeObjectAtIndex:0];
    }
    [_synImages addObject:image];
}

#pragma mark  --ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self quit];
    }
    else if (buttonIndex == 1) {
        _request = @"http://m.taobao.com/";
        [self loadWebWithURL:_request];
    }
    else if (buttonIndex == 2) {
        _request = @"http://m.yhd.com/";
        [self loadWebWithURL:_request];
    }
    else if (buttonIndex == 3) {
        _request = @"http://m.jd.com/";
        [self loadWebWithURL:_request];
    }
}

- (void)cancelFromRemoteParty
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([_synImages count] == 0) {
        [self addImages:[Utils screenshot:self.view toSize:CGSizeMake(HistoryImageSize, HistoryImageSize)]];
    }
    
    // add to history
    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:_synImages];
    DetailHistEvent *imageEvent = [[DetailHistEvent alloc] init];
    imageEvent.remoteParty = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    imageEvent.content = imageData;
    imageEvent.type = kMediaType_Image;
    imageEvent.start = _beginTime;
    imageEvent.end = [[NSDate date] timeIntervalSince1970];
    if (_inComing) {
        imageEvent.status = kHistoryEventStatus_Incoming;
    }
    else{
        imageEvent.status = kHistoryEventStatus_Outgoing;
    }
    [[DetailHistoryAccessor sharedInstance] addHistEntry:imageEvent];
}

- (void)quit
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelShopping toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [self cancelFromRemoteParty];
}

- (void)setOffset:(CGPoint)offset
{
//    [_webView.scrollView setContentOffset:offset animated:YES];
    NSString *scrollString = [NSString stringWithFormat:@"window.scrollTo(%d, %d);", int(offset.x), int(offset.y)];
    [_webView stringByEvaluatingJavaScriptFromString:scrollString];
//  it seems to work
}

#pragma mark  -- UIWebViewDelegate --
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error load:%@", [[webView.request URL] absoluteString]);
    //_fromRemote = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    _request = [[request URL] absoluteString];
    if ([_request isEqualToString:@"http://cdn.tanx.com/t/acookie/acbeacon2.html"]) {
        return NO;
    }
    if ([_request isEqualToString:@"about:blank"]) {
        return NO;
    }
    //}
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_fromRemote) {
        if ([[[webView.request URL] absoluteString] isEqualToString:_remoteURL]) {
            //_fromRemote = NO;
            _webView.scrollView.scrollEnabled = TRUE;
            [self setOffset:_remoteOffset];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"did start url:%@", [[webView.request URL] absoluteString]);
//    if (_fromRemote) {
//        if ([[[webView.request URL] absoluteString] isEqualToString:_remoteURL]) {
//            //_fromRemote = NO;
//            [self setOffset:_remoteOffset];
//        }
//    }
}

@end
