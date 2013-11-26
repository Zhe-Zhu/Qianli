//
//  VideoViewController.m
//  QianLi
//
//  Created by lutan on 9/15/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "VideoViewController.h"
#import "SipStackUtils.h"
#import "UIImageExtras.h"

@interface VideoViewController (){
    MoviePlayerViewController __weak *_moviePlayer;
    double beginTime;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) MoviePlayerViewController *moviePlayer;
@property (strong, nonatomic) NSMutableArray *vedioThumbs;

@end

@implementation VideoViewController

@synthesize moviePlayer = _moviePlayer;
@synthesize webView = _webView;
@synthesize vedioThumbs = _vedioThumbs;

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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self loadWebSite];
    _lateSynTime = 0;
    _vedioThumbs = [NSMutableArray array];
    beginTime = [[NSDate date] timeIntervalSince1970];
    
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
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  -- UIWebViewDelegate --
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //NSLog(@"error load:%@", [[webView.request URL] absoluteString]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSArray* words = [url componentsSeparatedByString:@"/"];
    for (int i =0; i < [words count]; ++i){
        if ([[words objectAtIndex:i] isEqualToString:@"v_show"]){
            NSArray *array = [[words objectAtIndex:i + 1] componentsSeparatedByString:@"."];
            NSString *videoID = [[array objectAtIndex:0] substringFromIndex:3];
            NSString *videoURL = [self getVedioURL:videoID];
            [self playMovieStream:[NSURL URLWithString:videoURL]];
            NSString *message = [NSString stringWithFormat:@"%@%@%@",kPlayVideo, kSeparator, videoURL];
            [[SipStackUtils sharedInstance].messageService sendMessage:message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
            [self getHistoryImage];
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"finish load:%@", [[webView.request URL] absoluteString]);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //NSLog(@"did start url:%@", [[webView.request URL] absoluteString]);
}

- (void)loadWebSite
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:request];
}

- (NSString *)getVedioURL:(NSString *)vedioID
{
    NSString *str = [NSString stringWithFormat:@"http://v.youku.com/player/getRealM3U8/vid/%@/type//video.m3u8", vedioID];
    return str;
}

- (void)cancel
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kVideoCancel toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [self addHistory];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelFromRemote
{
    if (_moviePlayer) {
        [_moviePlayer cancelMoviePlayer];
        [_moviePlayer dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [self addHistory];
}

- (void)addHistory
{
    // add to history
    if ([_vedioThumbs count] == 0) {
        [_vedioThumbs addObject:[self smallScreenshot]];
    }
    NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:_vedioThumbs];
    NgnHistoryImageEvent *imageEvent = [NgnHistoryEvent createImageEventWithStatus:HistoryEventStatus_Incoming andRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] andContent:imageData];
    imageEvent.start = beginTime;
    imageEvent.end = [[NSDate date] timeIntervalSince1970];
    if (_isIncoming) {
        imageEvent.status = HistoryEventStatus_Incoming;
    }
    else{
        imageEvent.status = HistoryEventStatus_Outgoing;
    }
    [[SipStackUtils sharedInstance].historyService addEvent:(NgnHistoryEvent *)imageEvent];
}

- (void)cancelPlayerFromRemote
{
    if (_moviePlayer) {
        [_moviePlayer cancelMoviePlayer];
        [_moviePlayer dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)playMovieStream:(NSURL *)movieFileURL
{
    MoviePlayerViewController *player = [[MoviePlayerViewController alloc] init];
    player.thumbs = _vedioThumbs;
    _moviePlayer = player;
   [self presentViewController:player animated:YES completion: nil];
    [_moviePlayer playMovieStream:movieFileURL];
}

- (void)pauseFromRemote:(BOOL)paused;
{
    [_moviePlayer pauseFromRemote:paused];
}

- (void)backwardFromRemote:(float)currentTime
{
    [_moviePlayer backwardFromRemote:currentTime];
}

- (void)forwardFromRemote:(float)currentTime
{
    [_moviePlayer forwardFromRemote:currentTime];
}

- (void)getHistoryImage
{
    if ([_vedioThumbs count] < 6) {
        [_vedioThumbs addObject:[self smallScreenshot]];
    }
    else{
        [_vedioThumbs removeObjectAtIndex:0];
        [_vedioThumbs addObject:[self smallScreenshot]];
    }
}

- (UIImage*)smallScreenshot
{
    // Create a graphics context with the target size
    CGSize imageSize = self.view.bounds.size;
    if (NULL != UIGraphicsBeginImageContextWithOptions){
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    }
    else{
        UIGraphicsBeginImageContext(imageSize);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[self.view layer] renderInContext:context];
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *samllImage = [image imageByResizing:CGSizeMake(HistoryImageSize, HistoryImageSize)];
    
    return samllImage;
}

@end
