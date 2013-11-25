//
//  SignUpVerificationCodeViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "SignUpVerificationCodeViewControllerSimpleVersion.h"

@interface SignUpVerificationCodeViewControllerSimperVersion ()

@end

@implementation SignUpVerificationCodeViewControllerSimperVersion
@synthesize captcha;
@synthesize buttonContinue;

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
    [captcha becomeFirstResponder];
    captcha.delegate = self;
    [self deactivateButtonContinue];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [captcha resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 通过字符改变位置和所改变字符来判定当前验证码是否位数正确
    NSInteger lengthLimit = 4; // 4位验证码
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
    [buttonContinue setEnabled:YES];
    [buttonContinue setAlpha:1.0f];
}

- (void)deactivateButtonContinue
{
    [buttonContinue setEnabled:NO];
    [buttonContinue setAlpha:0.4f];
}

@end
