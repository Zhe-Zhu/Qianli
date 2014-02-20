//
//  MoviePlayerViewController.m
//  QianLi
//
//  Created by lutan on 9/23/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//  CODEREVIEW DONE

#import "MoviePlayerViewController.h"
#import "SipStackUtils.h"
#import "UIImageExtras.h"
#import "MobClick.h"
#import "SVProgressHUD.h"
#import "Global.h"

@interface MoviePlayerViewController ()
{
    CGFloat totalDurationLength;
    CGFloat totalDuration;
}

@property (weak, nonatomic) UIView *movieView;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL controlON;
@property (nonatomic, weak) UIView *controls;
@property (strong, nonatomic) NSTimer *hideControlsTimer;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) UIButton *pauseButton;

@property (weak, nonatomic) UIView *playingProgress;
@property (weak, nonatomic) UIView *availableProgress;
@property (weak, nonatomic) NSTimer *progressTimer;
@property (weak, nonatomic) UILabel *totalTimeLabel;
@property (weak, nonatomic) UILabel *currentTimeLabel;
@end

@implementation MoviePlayerViewController

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
    NSTimer *progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(adjustProgress) userInfo:nil repeats:YES];
     _progressTimer = progressTimer;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDuration) name:MPMovieDurationAvailableNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    [MobClick beginEvent:@"watchVideo"];
    NSError *setCategoryError = nil;
    if (![Utils isHeadsetPluggedIn]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: &setCategoryError];
    }
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeMoviePlayback error:&setCategoryError];
    if (setCategoryError){
        NSLog(@"error");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [MobClick endEvent:@"watchVideo"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[SipStackUtils sharedInstance].soundService enableBackgroundSound];
    if (![Utils isHeadsetPluggedIn]) {
        [[SipStackUtils sharedInstance].soundService configureSpeakerEnabled:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_progressTimer invalidate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)getDuration
{
    totalDuration = floorf(_moviePlayerController.duration);
    NSInteger minute = floorf(totalDuration / 60);
    if (minute < 10) {
        NSString *str;
        if (int(totalDuration - minute * 60) > 9) {
            str = [NSString stringWithFormat:@"0%d:%d", minute, int(totalDuration - minute * 60)];
        }
        else{
            str = [NSString stringWithFormat:@"0%d:0%d", minute, int(totalDuration - minute * 60)];
        }
        _totalTimeLabel.text = str;
    }
    else{
        NSString *str;
        if (int(totalDuration - minute * 60) > 9) {
            str = [NSString stringWithFormat:@"%d:%d", minute, int(totalDuration - minute * 60)];
        }
        else{
            str = [NSString stringWithFormat:@"%d:0%d", minute, int(totalDuration - minute * 60)];
        }
        _totalTimeLabel.text = str;
    }
}

- (void)adjustProgress
{
    CGFloat currentTime = floorf(_moviePlayerController.currentPlaybackTime);
    NSInteger minute = floorf(currentTime / 60);
    if (minute < 10) {
        NSString *str;
        if (int(currentTime - minute * 60) > 9) {
            str = [NSString stringWithFormat:@"0%d:%d", minute, int(currentTime - minute * 60)];
        }
        else{
            str = [NSString stringWithFormat:@"0%d:0%d", minute, int(currentTime - minute * 60)];
        }
        _currentTimeLabel.text = str;
    }
    else{
        NSString *str;
        if (int(currentTime - minute * 60) > 9) {
            str = [NSString stringWithFormat:@"%d:%d", minute, int(currentTime - minute * 60)];
        }
        else{
            str = [NSString stringWithFormat:@"%d:0%d", minute, int(currentTime - minute * 60)];
        }
        _currentTimeLabel.text = str;
    }
    
    CGFloat length = totalDurationLength * currentTime / totalDuration;
    CGRect frame = _playingProgress.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, length, frame.size.height);
    _playingProgress.frame = frame;
}

-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    
    if (player)
    {
        /* Save the movie object. */
        _paused = NO;
        [self setMoviePlayerController:player];
        [player setContentURL:movieURL];
        [player setMovieSourceType:sourceType];
        [player setRepeatMode: MPMovieRepeatModeOne];
        player.controlStyle = MPMovieControlStyleNone;
        player.scalingMode = MPMovieScalingModeAspectFit;
       // player.useApplicationAudioSession = YES;
        /* Add a background view as a subview to hide our other view controls
         underneath during movie playback. */
        
        CGRect viewInsetRect = CGRectInset ([self.view bounds], 0, 0);
        /* Inset the movie frame in the parent view frame. */
        [[player view] setFrame:viewInsetRect];
        [player view].backgroundColor = [UIColor lightGrayColor];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, player.view.bounds.size.height - 60, player.view.bounds.size.width, 70)];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _controls = view;

        totalDurationLength = player.view.bounds.size.width - 160;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(80, 12, totalDurationLength, 2)];
        lineView.backgroundColor = [UIColor colorWithRed:99 / 255.0 green:99 / 255.0 blue:99 / 255.0 alpha:1.0];
        [view addSubview:lineView];
        
        UILabel *totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalDurationLength + 80 + 5, 7, 70, 15)];
        totalTimeLabel.backgroundColor = [UIColor clearColor];
        _totalTimeLabel = totalTimeLabel;
        totalTimeLabel.textColor = [UIColor whiteColor];
        totalTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        [view addSubview:totalTimeLabel];
        
        UILabel *totalTimeLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(30, 7, 70, 15)];
        totalTimeLabel1.backgroundColor = [UIColor clearColor];
        _currentTimeLabel = totalTimeLabel1;
        totalTimeLabel1.textColor = [UIColor whiteColor];
        totalTimeLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
        [view addSubview:totalTimeLabel1];
        
//        UIView *availableProgress = [[UIView alloc] initWithFrame: CGRectMake(50, 12, 0, 3)];
//        availableProgress.backgroundColor = [UIColor yellowColor];
//        [view addSubview:availableProgress];
        
        UIView *playingProgress = [[UIView alloc] initWithFrame: CGRectMake(80, 12, 0, 2)];
        playingProgress.backgroundColor = [UIColor whiteColor];
        [view addSubview:playingProgress];
        _playingProgress = playingProgress;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:NSLocalizedString(@"Quit", nil) forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.frame = CGRectMake(0, 15, 90, 55);
        [view addSubview:cancelButton];
        
        UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [forwardButton setImage:[UIImage imageNamed:@"videoForward.png"] forState:UIControlStateNormal];
        [forwardButton addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
        forwardButton.frame = CGRectMake(winSize.height * 3 / 4.0, 20, 60, 40);
        [view addSubview:forwardButton];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"videoBackward.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backward) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(winSize.height * 1 / 4.0, 20, 60, 40);
        [view addSubview:backButton];
        
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"videoPause.png"] forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
        _pauseButton.frame = CGRectMake(winSize.height * 2 / 4.0, 20, 60, 40);
        [view addSubview:_pauseButton];
        _hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:kVideoHideControls target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
        [player.view addSubview:view];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [player.view addGestureRecognizer:tap];
        _controlON = YES;
        tap.delegate = self;
        
        _movieView = [player view];
        [self.view addSubview: [player view]];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (!_controlON) {
        [self showControls];
    }
    else {
        [self hideControls];
        [_hideControlsTimer invalidate];
    }
}

- (void)hideControls
{
    [UIView animateWithDuration:0.5 animations:^{
        _controls.alpha = 0.0;
    } completion:^(BOOL finished) {
        _controlON = NO;
    }];
}

- (void)showControls
{
    [UIView animateWithDuration:0.3 animations:^{
        _controls.alpha = 1.0;
    } completion:^(BOOL finished) {
        [_hideControlsTimer invalidate];
        _hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:kVideoHideControls target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
        _controlON = YES;
    }];
}

- (void)resetControlTimer
{
    [_hideControlsTimer invalidate];
    _hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:kVideoHideControls target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
}

- (void)forwardFromRemote:(float)currentTime
{
    float total = _moviePlayerController.duration;
//    float time = _moviePlayerController.currentPlaybackTime;
    float time = currentTime;
    if (time + 10 < total) {
        [_moviePlayerController setCurrentPlaybackTime:time + 10];
    }
    else{
        [_moviePlayerController setCurrentPlaybackTime:total];
    }
    [self resetControlTimer];
}

- (void)forward
{
    float time = _moviePlayerController.currentPlaybackTime;
    [self forwardFromRemote:time];
    if (kIsCallingQianLiRobot) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: NSLocalizedString(@"QianLiRobotForwardBackVideo", nil),((int)_moviePlayerController.currentPlaybackTime) / 60, ((int)_moviePlayerController.currentPlaybackTime) % 60]];
    }
    NSString *message = [NSString stringWithFormat:@"%@%@%f", kVideoForward, kSeparator, time];
    [[SipStackUtils sharedInstance].messageService sendMessage: message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

- (void)backwardFromRemote:(float)currentTime
{
//    float time = _moviePlayerController.currentPlaybackTime;
    float time = currentTime;
    if (time - 10 > 0) {
        [_moviePlayerController setCurrentPlaybackTime:time - 10];
    }
    else{
        [_moviePlayerController setCurrentPlaybackTime:0];
    }
    [self resetControlTimer];
}

- (void)backward
{
    float time = _moviePlayerController.currentPlaybackTime;
    [self backwardFromRemote:time];
    if (kIsCallingQianLiRobot) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: NSLocalizedString(@"QianLiRobotForwardBackVideo", nil),((int)_moviePlayerController.currentPlaybackTime) / 60, ((int)_moviePlayerController.currentPlaybackTime) % 60]];
    }

    NSString *message = [NSString stringWithFormat:@"%@%@%f", kVideoBackward, kSeparator, time];
    [[SipStackUtils sharedInstance].messageService sendMessage: message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

- (void)pauseFromRemote:(BOOL)paused
{
    _paused = paused;
    if (_paused) {
        [_moviePlayerController pause];
        // Change the outlooking
        [_pauseButton setImage:[UIImage imageNamed:@"videoPlay.png"] forState:UIControlStateNormal];
    }
    else{
        [_moviePlayerController play];
        // Change the outlooking
        [_pauseButton setImage:[UIImage imageNamed:@"videoPause.png"] forState:UIControlStateNormal];
    }
    [self resetControlTimer];
}

- (void)pause
{
    if (kIsCallingQianLiRobot && !_paused) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QianLiRobotPauseVideo", nil)];
    }
    _paused = !_paused;
    [self pauseFromRemote:_paused];
    // 0 - play
    // 1 - pause
    NSString *message = [NSString stringWithFormat:@"%@%@%d", kVideoPaused, kSeparator, _paused];
    [[SipStackUtils sharedInstance].messageService sendMessage: message toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
    /* Play the movie! */
    [self.moviePlayerController play];
}

-(void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    /* If we have a streaming url then specify the movie source type. */
    if ([[movieFileURL pathExtension] compare:@"m3u8" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        movieSourceType = MPMovieSourceTypeStreaming;
    }
    [self createAndPlayMovieForURL:movieFileURL sourceType:movieSourceType];
}

-(void)cancel
{
    [self cancelMoviePlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[SipStackUtils sharedInstance].messageService sendMessage:kVideoPlayerCancel toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
}

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)cancelMoviePlayer
{
    [_moviePlayerController pause];
    [_moviePlayerController stop];
    [_progressTimer invalidate];
}

@end
