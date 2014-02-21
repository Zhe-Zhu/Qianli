//
//  WaitingViewController.m
//  QianLi
//
//  Created by LG on 2/17/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "WaitingViewController.h"

@interface WaitingViewController (){
    
}

@property (weak, nonatomic) IBOutlet UILabel *beforeLabel;
@property (weak, nonatomic) IBOutlet UILabel *beforeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *behindTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *behindNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *addPartnerButton;
@property (weak, nonatomic) IBOutlet UILabel *partnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *partnerNumberLabel;

@property (strong, nonatomic) WaitedViewController *waitedVC;
- (IBAction)addPartner:(id)sender;
@end

@implementation WaitingViewController

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
    _beforeLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    _behindTextLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    _behindNumberLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    _partnerLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    _beforeNumberLabel.textColor = [UIColor colorWithRed:72 / 255.0 green:188 / 255.0 blue:205 / 255.0 alpha:1.0];
    _partnerNumberLabel.textColor = [UIColor colorWithRed:185 / 255.0 green:185 / 255.0 blue:185 / 255.0 alpha:1.0];
    
    self.navigationController.navigationBarHidden = YES;
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    _beforeNumberLabel.text = [NSString stringWithFormat:@"%d", [userData integerForKey:@"before"]];
    _behindNumberLabel.text = [NSString stringWithFormat:@"%d", [userData integerForKey:@"behind"]];
    if (_isPartner) {
        _addPartnerButton.hidden = YES;
    }
    if (_succeed) {
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWaitingStatus:) name:kCheckStatusNotification object:nil];
    [[WaitingListUtils sharedInstance] getWaitingStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // added by Xiangwen
    // localize beforeLabel and behindTextLabel
    _beforeLabel.text = NSLocalizedString(@"beforeText", nil);
    _behindTextLabel.text = NSLocalizedString(@"behindTextLabel", nil);
    _partnerLabel.text = NSLocalizedString(@"partnerNumber", nil);
    
    self.navigationController.navigationBarHidden = YES;
    NSString *partnerNumber = [UserDataAccessor getUserPartnerNumber];
    _partnerNumberLabel.text = partnerNumber;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!IS_OS_7_OR_LATER) {
        for (UIView *view in self.view.subviews) {
            CGRect frame = view.frame;
            frame =CGRectMake(frame.origin.x, frame.origin.y - 20, frame.size.width, frame.size.height);
            view.frame = frame;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideWaitingViews
{
    _beforeNumberLabel.hidden = YES;
    _beforeLabel.hidden = YES;
}

- (void)checkWaitingStatus:(NSNotification *)notif
{
    NSDictionary *jsonDict = notif.userInfo;
    NSInteger result = [[jsonDict valueForKey:@"result"] integerValue];
    if (result == 0) {
        // have to wait longer
        NSInteger numOfBeforeUser = [[jsonDict valueForKey:@"before"] integerValue];
        NSInteger numOfBehindUser = [[jsonDict valueForKey:@"behind"] integerValue];
        _beforeNumberLabel.text = [NSString stringWithFormat:@"%d", numOfBeforeUser];
        _behindNumberLabel.text = [NSString stringWithFormat:@"%d", numOfBehindUser];
        NSString *partnerNumber = [jsonDict valueForKey:@"partner"];
        if ((![partnerNumber isEqualToString:[UserDataAccessor getUserPartnerNumber]]) && (![partnerNumber isEqualToString:@""])) {
            [UserDataAccessor setUserPartnerNumber:partnerNumber];
            _partnerNumberLabel.text = partnerNumber;
        }
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        BOOL partner_verified = [[jsonDict valueForKey:@"verified"] boolValue];
        if (partner_verified != [userData boolForKey:@"partner_verified"]) {
            [userData setBool:partner_verified forKey:@"partner_verified"];
        }
        [userData setInteger:numOfBeforeUser forKey:@"before"];
        [userData setInteger:numOfBehindUser forKey:@"behind"];
        [userData synchronize];
    }
    else if (result == 1){
        // successfully joined the qianli system
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSingUpKey];
        NSString *number = [UserDataAccessor getUserWaitingNumber];
        [UserDataAccessor setUserRemoteParty:number];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        WaitedViewController *waitedVC = [storyboard instantiateViewControllerWithIdentifier:@"WaitedViewController"];
        _waitedVC = waitedVC;
        NSInteger numOfBehindUser = [[jsonDict valueForKey:@"behind"] integerValue];
        waitedVC.totalWaitingPeople = numOfBehindUser;
        waitedVC.view.alpha = 0.0;
        [self.view addSubview:waitedVC.view];
        [UIView animateWithDuration:1.0 animations:^{
            _waitedVC.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (IBAction)addPartner:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddPartnerViewController *addPartnerVC = [storyboard instantiateViewControllerWithIdentifier:@"AddPartnerViewController"];
    [self.navigationController pushViewController:addPartnerVC animated:YES];
}
@end
