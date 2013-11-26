//
//  DrawingViewController.m
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "DrawingViewController.h"
#import "SipStackUtils.h"
#import "MobClick.h"

@interface DrawingViewController (){
    BOOL _isDrawing;
}

@property(nonatomic) double starTime;
@property (weak, nonatomic) IBOutlet UIButton *ereaser;

- (IBAction)changeWidth:(id)sender;
- (IBAction)draw:(id)sender;
- (IBAction)changColor:(id)sender;
@end

@implementation DrawingViewController

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
    //_drawingView = (HandDrawingView *) self.view;
    HandDrawingView *view = [[HandDrawingView alloc] initWithFrame:self.view.frame];
    _drawingView = view;
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [cancelButton setImage:[UIImage imageNamed:@"arrowLeft.png"]];
    self.navigationItem.leftBarButtonItem = cancelButton;
    _isDrawing = YES;
    
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
        
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginEvent:@"handWriting"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endEvent:@"handWriting"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeWidth:(id)sender {
}

- (IBAction)draw:(id)sender {
    _isDrawing = !_isDrawing;
    if (_isDrawing) {
        [sender setImage:[UIImage imageNamed:@"doodleDraw.png"] forState:UIControlStateNormal];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"doodleEraser.png"] forState:UIControlStateNormal];
    }
    [_drawingView changePaintingMode];
}

- (IBAction)changColor:(id)sender {
}

- (void)cancel
{
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelDrawing toRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
    [self cancelFromRemoteParty];
}

- (void)cancelFromRemoteParty
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
