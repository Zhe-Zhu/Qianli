//
//  SignUpViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SignUpViewController.h"
#import "PictureManager.h"
#import "Utils.h"
#import "UserDataAccessor.h"
#import "Reachability.h"
#import "Global.h"

@interface SignUpViewController ()
{
    NSString *oldPhoneNumber; // 存储旧号码,如果用户未更改过号码则不弹出确认AlertView
}

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UILabel *countryCode;

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (IBAction)registerNumber:(id)sender;

@end

@implementation SignUpViewController

@synthesize phoneNumber = _phoneNumber;
@synthesize buttonContinue = _buttonContinue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_phoneNumber becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_indicator stopAnimating];
    [self activateButtonContinue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _phoneNumber.delegate = self;
    [self deactivateButtonContinue];
    UITapGestureRecognizer *countryCodeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countryCodePressed)];
    [_countryCode addGestureRecognizer:countryCodeTap];
    _countryCode.userInteractionEnabled = YES;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.frame = CGRectMake(160-CGRectGetWidth(_indicator.frame)/2.0, 200, CGRectGetWidth(_indicator.frame), CGRectGetHeight(_indicator.frame));
    [self.view addSubview:_indicator];
    
    if (!IS_OS_7_OR_LATER) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6SignUpNavigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, 320, 44)];
    }
    
    _phoneNumber.placeholder = NSLocalizedString(@"signUpPhoneNumber", nil);
    _countryCode.text = NSLocalizedString(@"signUpCountryCode", nil);
    self.navigationItem.title = NSLocalizedString(@"welcome", nil);
    [_buttonContinue setTitle:NSLocalizedString(@"continue", nil) forState:UIControlStateNormal];
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"back", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 通过字符改变位置和所改变字符来判定当前输入号码是否到达11位
    NSInteger lengthLimit = 11; // 11位电话号码 TODO
    if ((range.location == lengthLimit-1 && ![string isEqual:@""]) || (range.location == lengthLimit && [string isEqual:@""])) {
        [self activateButtonContinue];
    }
    else
    {
        [self deactivateButtonContinue];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // 清空后电话号码肯定为空, 因此要禁止继续
    [self deactivateButtonContinue];
    return YES;
}

#pragma mark Change View Looking
- (void)activateButtonContinue
{
    [_buttonContinue setEnabled:YES];
    [_buttonContinue setAlpha:1.0f];
}

- (void)deactivateButtonContinue
{
    [_buttonContinue setEnabled:NO];
    [_buttonContinue setAlpha:0.4f];
}

- (IBAction)registerNumber:(id)sender
{
    [self showConfirmation];
//    [self tryToRegisterTheNumber];
}

- (void)showConfirmation
{
    [self stripCountryName];
    NSString *confirmationMessage = [NSString stringWithFormat:NSLocalizedString(@"numberConfirmation", nil), [self stripCountryName], _phoneNumber.text];
    UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"numberConfirmationTitle", nil) message:confirmationMessage delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    if ([_phoneNumber.text isEqualToString:oldPhoneNumber]) {
        [self tryToRegisterTheNumber];
    }
    else {
        oldPhoneNumber = _phoneNumber.text;
        [confirmation show];
    }
}

- (NSString *)stripCountryName
{
    NSRange range = [_countryCode.text rangeOfString:@"("];
    return [_countryCode.text substringFromIndex:range.location];
}


- (void)tryToRegisterTheNumber
{
    // Show The UIActivity Indicator
    [_phoneNumber resignFirstResponder];
    [_indicator startAnimating];
    [self deactivateButtonContinue];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        // Show the Alert View
        UIAlertView *noNetworkConnection = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noNetworkTitle", nil) message:NSLocalizedString(@"noNetworkMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles: nil];
        [noNetworkConnection show];
        
        [_phoneNumber becomeFirstResponder];
        [_indicator stopAnimating];
        [self activateButtonContinue];
        return;
    }
    
    NSString *udid = [Utils getDeviceUDID];
    NSString *number = [NSString stringWithFormat:@"%@%@", @"0086", _phoneNumber.text];
    [PictureManager registerWithUDID:udid Password:number Name:number PhoneNumber:number Email:@"" OS:@"i" Avatar:nil Success:^(int status) {
        if (status == 1) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SignUpVerificationCodeViewController *verifyCV = [storyboard instantiateViewControllerWithIdentifier:@"SignUpVerificationCodeViewController"];
            verifyCV.number = number;
            verifyCV.readableNumber = [NSString stringWithFormat:@"%@ %@", [self stripCountryName], _phoneNumber.text];
            [self performSelectorOnMainThread:@selector(showVerifyingVC:) withObject:verifyCV waitUntilDone:NO];
        }
        else if (status == 2){
            [UserDataAccessor setUserRemoteParty:number];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kSingUpKey];
            [userDefaults synchronize];
            QianLiAppDelegate *qianliAppDelegate = (QianLiAppDelegate*)[UIApplication sharedApplication].delegate;
            [qianliAppDelegate performSelectorOnMainThread:@selector(resetRootViewController) withObject:nil waitUntilDone:YES];
        }
        else if (status < 0) {
            // Show the Alert View
            UIAlertView *registerError = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"registerErrorTitle", nil) message:NSLocalizedString(@"registerErrorMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles: nil];
            [registerError performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            
            [_phoneNumber becomeFirstResponder];
            [_indicator stopAnimating];
            [self activateButtonContinue];
        }
    }];
}

- (void)showVerifyingVC:(SignUpVerificationCodeViewController *)verifyCV
{
    [self performSelector:@selector(showVerifyingController:) withObject:verifyCV afterDelay:1];
}

- (void)showVerifyingController:(SignUpVerificationCodeViewController *)verifyCV
{
    [self.navigationController pushViewController:verifyCV animated:YES];
}

- (void)countryCodePressed
{
    UITableViewController *tableView = [[UITableViewController alloc] init];
    tableView.title = NSLocalizedString(@"countryCode", nil);
    [self.navigationController pushViewController:tableView  animated:YES];
}

# pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"user pressed Cancel");
    }
    else {
        [self tryToRegisterTheNumber];
    }
}

@end

