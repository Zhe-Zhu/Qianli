//
//  SettingChangeNameViewController.m
//  QianLi
//
//  Created by Tomoya on 13-10-3.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "SettingChangeNameViewController.h"
#import "UserDataTransUtils.h"
#import "UserDataAccessor.h"

@interface SettingChangeNameViewController ()

@end

@implementation SettingChangeNameViewController

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
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonPressed)];
    self.navigationItem.rightBarButtonItem = finishButton;
    [self.nameTextField becomeFirstResponder];
    self.nameTextField.delegate = self;
    NSString *name = [UserDataAccessor getUserName];
    if (!name) {
        self.nameTextField.placeholder = NSLocalizedString(@"inputName", nil);
    }
    else{
        self.nameTextField.text = name;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(nameChanged:)]) {
        [self.delegate nameChanged:self.nameTextField.text];
    }
    [UserDataTransUtils patchUserName:self.nameTextField.text number:[UserDataAccessor getUserRemoteParty] Completion:^(BOOL success) {
        if (success) {
            [UserDataAccessor setUserName:self.nameTextField.text];
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self finishButtonPressed];
    return YES;
}

@end
