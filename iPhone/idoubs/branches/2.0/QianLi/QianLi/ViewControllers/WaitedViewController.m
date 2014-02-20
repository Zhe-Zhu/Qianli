//
//  WaitedViewController.m
//  QianLi
//
//  Created by LG on 2/19/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "WaitedViewController.h"

@interface WaitedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *queueLabel;

- (IBAction)startQianLi:(id)sender;
@end

@implementation WaitedViewController

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
    self.view.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1.0];
    _numberLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    _queueLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    
    _numberLabel.text = [NSString stringWithFormat:@"%d", _totalWaitingPeople];
    NSString *str = NSLocalizedString(@"canUseQianli", nil);
    CGSize constraintSize;
    constraintSize.width = 240;
    constraintSize.height = MAXFLOAT;
    CGSize contentSize = [str sizeWithFont:[UIFont fontWithName:@"ArialHebrew" size:25] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((320 - contentSize.width) / 2.0, 120, contentSize.width, contentSize.height)];
    label.text = str;
    label.font = [UIFont fontWithName:@"ArialHebrew" size:24];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    label.textColor = [UIColor colorWithRed:72 / 255.0 green:188 / 255.0 blue:205 / 255.0 alpha:1.0];
    
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _startButton.frame.size.width, _startButton.frame.size.height)];
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textColor = [UIColor whiteColor];
    buttonLabel.text = NSLocalizedString(@"BeginQianli", nil);
    buttonLabel.font = [UIFont fontWithName:@"ArialHebrew" size:25];
    [_startButton addSubview:buttonLabel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //added by Xiangwen
    //localized queueLabel;
    _queueLabel.text = NSLocalizedString(@"stillInQueue", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startQianLi:(id)sender
{
    QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate resetRootViewController];
}
@end
