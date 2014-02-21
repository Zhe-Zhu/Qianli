//
//  SignUpVerificationCodeViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SignUpVerificationCodeViewController.h"
#import "SignUpEditProfileViewController.h"
#import "Utils.h"
#import "Global.h"

@interface SignUpVerificationCodeViewController ()
{
    BOOL isFirstTap; // 记录是否第一次点击[无代码]按钮
}
// 用于接受验证码的输入然后根据输入在UILabel中显示
@property (weak, nonatomic) IBOutlet UITextField *captchaInput;

// 分别显示验证码的4位数字
@property (weak, nonatomic) IBOutlet UILabel *captchaLabel1;
@property (weak, nonatomic) IBOutlet UILabel *captchaLabel2;
@property (weak, nonatomic) IBOutlet UILabel *captchaLabel3;
@property (weak, nonatomic) IBOutlet UILabel *captchaLabel4;

// 用以指示哪个验证码还未输入
@property (weak, nonatomic) IBOutlet UIImageView *captchaCover1;
@property (weak, nonatomic) IBOutlet UIImageView *captchaCover2;
@property (weak, nonatomic) IBOutlet UIImageView *captchaCover3;
@property (weak, nonatomic) IBOutlet UIImageView *captchaCover4;

@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UILabel *hintText;

- (IBAction)verifyCode:(id)sender;
@end

@implementation SignUpVerificationCodeViewController
@synthesize captchaInput;
@synthesize captchaLabel1, captchaLabel2, captchaLabel3, captchaLabel4;
@synthesize captchaCover1, captchaCover2, captchaCover3, captchaCover4;
@synthesize buttonContinue;
@synthesize number = _number;
@synthesize readableNumber = _readableNumber;
@synthesize hintText;

// 当验证码未输入时, captchaCover的透明度
const float kCaptchaNonInputCoverAlpha = 0.2f;

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
    [captchaInput becomeFirstResponder];
    captchaInput.delegate = self;
    [self deactivateCaptchaCover:captchaCover1];
    [self deactivateCaptchaCover:captchaCover2];
    [self deactivateCaptchaCover:captchaCover3];
    [self deactivateCaptchaCover:captchaCover4];
    [self deactivateButtonContinue];
    
    UIBarButtonItem *noCaptcha = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"noCaptcha", nil) style:UIBarButtonItemStylePlain target:self action:@selector(noCaptcha)];
    self.navigationItem.rightBarButtonItem = noCaptcha;
    
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
    }
    
    isFirstTap = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"FirstInstall"];
    
    [buttonContinue setTitle:NSLocalizedString(@"continue", nil) forState:UIControlStateNormal];
    hintText.text = NSLocalizedString(@"hintText", nil);
    self.navigationItem.title = NSLocalizedString(@"captchaTitle", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (range.location) {
        case 0:
            captchaLabel1.text = string;
            if ([string isEqualToString:@""])
            {
                [self deactivateCaptchaCover:captchaCover1];
                // 还要将之后的所有CaptchaCover都deactivate否则在用户摇动手机undo的时候会显示错误
                [self deactivateCaptchaCover:captchaCover2];
                [self deactivateCaptchaCover:captchaCover3];
                [self deactivateCaptchaCover:captchaCover4];
                captchaLabel2.text = @"";
                captchaLabel3.text = @"";
                captchaLabel4.text = @"";
            }
            else
            {
                [self activateCaptchaCover:captchaCover1];
            }
            break;
        case 1:
            captchaLabel2.text = string;
            if ([string isEqualToString:@""])
            {
                [self deactivateCaptchaCover:captchaCover2];
            }
            else
            {
                [self activateCaptchaCover:captchaCover2];
            }
            break;
        case 2:
            captchaLabel3.text = string;
            if ([string isEqualToString:@""])
            {
                [self deactivateCaptchaCover:captchaCover3];
            }
            else
            {
                [self activateCaptchaCover:captchaCover3];
            }
            break;
        case 3:
            captchaLabel4.text = string;
            if ([string isEqualToString:@""])
            {
                [self deactivateCaptchaCover:captchaCover4];
                [self deactivateButtonContinue];
            }
            else
            {
                [self activateCaptchaCover:captchaCover4];
                [self activateButtonContinue];
            }
            break;
        default:
            return NO;
            break;
    }
    return YES;
}

#pragma mark Change The View Looking

// 验证码未输入或者删除
- (void)deactivateCaptchaCover:(UIImageView *)captchaCover
{
    [captchaCover setAlpha:kCaptchaNonInputCoverAlpha];
}

- (void)activateCaptchaCover:(UIImageView *)captchaCover
{
    [captchaCover setAlpha:1.0f];
}

- (void)activateButtonContinue
{
    [buttonContinue setEnabled:YES];
    [buttonContinue setAlpha:1.0f];
}

- (void)deactivateButtonContinue
{
    [buttonContinue setEnabled:NO];
    [buttonContinue setAlpha:0.4f];
}

- (IBAction)verifyCode:(id)sender
{
    NSString *verifyCode = [NSString stringWithFormat:@"%@%@%@%@", captchaLabel1.text, captchaLabel2.text, captchaLabel3.text, captchaLabel4.text];
    NSString *udid = [Utils getDeviceUDID];
    [PictureManager verifyWithUDID:udid Password:_number Name:_number PhoneNumber:_number Email:@"" OS:@"i" Avatar:nil Verification:verifyCode Success:^(int status) {
        if (status == 1) {
            [captchaInput resignFirstResponder];
            [self deactivateButtonContinue];
            if ([UserDataAccessor getUserRemoteParty] != nil) {
                [UserDataAccessor deleteUserImages];
            }
            [UserDataAccessor setUserRemoteParty:_number];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kSingUpKey];
            [userDefaults synchronize];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SignUpEditProfileViewController *editProfileCV = [storyboard instantiateViewControllerWithIdentifier:@"SignUpEditProfileViewController"];
            [self performSelectorOnMainThread:@selector(showViewController:) withObject:editProfileCV waitUntilDone:NO];
        }
        else if (status == 2){
            //waitinglist primary number
            [captchaInput resignFirstResponder];
            [self deactivateButtonContinue];
            [UserDataAccessor setUserWaitingNumber:_number];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kWaitingKey];
            [userDefaults synchronize];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            WaitingViewController *waitingVC = [storyboard instantiateViewControllerWithIdentifier:@"WaitingViewController"];
            waitingVC.succeed = NO;
            waitingVC.isPartner = NO;
            [self performSelectorOnMainThread:@selector(presentWaitingVC:) withObject:waitingVC waitUntilDone:NO];
        }
        else if (status == 3){
            //waitedlist
            [captchaInput resignFirstResponder];
            [self deactivateButtonContinue];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kSingUpKey];
            [userDefaults synchronize];
            [UserDataAccessor setUserRemoteParty:_number];
            [UserDataAccessor setUserWaitingNumber:_number];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            WaitingViewController *waitingVC = [storyboard instantiateViewControllerWithIdentifier:@"WaitingViewController"];
            waitingVC.succeed = YES;
            [self performSelectorOnMainThread:@selector(presentWaitingVC:) withObject:waitingVC waitUntilDone:NO];
        }
        else if (status == 4){
            //waitinglist partner number
            [captchaInput resignFirstResponder];
            [self deactivateButtonContinue];
            [UserDataAccessor setUserWaitingNumber:_number];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:kWaitingKey];
            [userDefaults setBool:YES forKey:@"isPartner"];
            [userDefaults synchronize];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            WaitingViewController *waitingVC = [storyboard instantiateViewControllerWithIdentifier:@"WaitingViewController"];
            waitingVC.succeed = NO;
            waitingVC.isPartner = YES;
            [self performSelectorOnMainThread:@selector(presentWaitingVC:) withObject:waitingVC waitUntilDone:NO];
        }
        else if (status == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"captchaErrorTitle", nil) message:NSLocalizedString(@"captchaErrorMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"captchaErrorButton", nil) otherButtonTitles:nil];
            [alertView show];
        }

    }];
}

- (void)presentWaitingVC:(UIViewController *)viewController
{
    UINavigationController *naviVC = [[UINavigationController alloc] init];
    naviVC.viewControllers = @[viewController];
    [self presentViewController:naviVC animated:YES completion:nil];
}

- (void)showViewController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)noCaptcha
{
    NSString *str = NSLocalizedString(@"voiceCaptchaIntro", nil);
    UIAlertView *noCaptchaSecondTap = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"voiceCaptchaTitle", nil) message:str delegate:self cancelButtonTitle:NSLocalizedString(@"message", nil) otherButtonTitles:NSLocalizedString(@"phoneCall", nil),nil];
    [noCaptchaSecondTap show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // send the verification code again
        NSString *udid = [Utils getDeviceUDID];
        [PictureManager registerWithUDID:udid Password:_number Name:_number PhoneNumber:_number Email:@"" OS:@"i" Avatar:nil Success:nil];
    }
    else {
        //make auido call to tell user the verification code
        [PictureManager getVerificationCodeByAudio:_number Success:^(int status) {
            if (status == 1) {
                // the right
            }
            else{
                //error
            }
        }];
    }
}

@end
