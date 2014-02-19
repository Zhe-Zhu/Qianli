//
//  AddPartnerViewController.m
//  QianLi
//
//  Created by LG on 2/17/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "AddPartnerViewController.h"

@interface AddPartnerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *partnerLabel;
@property (strong, nonatomic) NSString *partnerNumber;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) UILabel *buttonLabel;

- (IBAction)done:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)sendEmail:(id)sender;

@end

@implementation AddPartnerViewController

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
    _partnerLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    _numberField.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1.0];
    
    self.navigationController.navigationBarHidden = NO;
    NSString *str = @"输入一个亲友号码，当你获得千里使用资格后，我们会同时激活该号码";
    CGSize constraintSize;
    constraintSize.width = 240;
    constraintSize.height = MAXFLOAT;
    CGSize contentSize = [str sizeWithFont:[UIFont fontWithName:@"ArialHebrew" size:17] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((320 - contentSize.width) / 2.0, 81, contentSize.width, contentSize.height)];
    label.text = str;
    label.font = [UIFont fontWithName:@"ArialHebrew" size:16];
    label.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    NSString *partnerNumber = [UserDataAccessor getUserPartnerNumber];
    if (!partnerNumber) {
        _messageButton.alpha = 0.0;
        _emailButton.alpha = 0.0;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"partner_verified"]) {
        _partnerLabel.alpha = 0.0;
        _numberField.alpha = 0.0;
        _doneButton.alpha = 0.0;
        label.text = [NSString stringWithFormat:@"你的亲友号码是:%@。你可以短信或邮件告诉你的好友。", partnerNumber];
    }
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _doneButton.frame.size.width, _doneButton.frame.size.height)];
    _buttonLabel = buttonLabel;
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textColor = [UIColor whiteColor];
    buttonLabel.text = @"确定";
    buttonLabel.font = [UIFont fontWithName:@"ArialHebrew" size:25];
    [_doneButton addSubview:buttonLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPartner:) name:kAddPartnerNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_numberField.alpha > 0.1 && ([UserDataAccessor getUserPartnerNumber] == nil)) {
        if ([_numberField canBecomeFirstResponder]) {
            [_numberField becomeFirstResponder];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        [_numberField resignFirstResponder];
    }
}

- (void)addPartner:(NSNotification *)notif
{
    NSDictionary *jsonDict = notif.userInfo;
    NSInteger result = [[jsonDict valueForKey:@"result"] integerValue];
    if (result == 0) {
       // partner number has already been in our system
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，你想要绑定的号码已经在千里系统中，请选择其他号码" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alertView show];
    }
    else if (result == 1){
        // first time add partner successfully
        _buttonLabel.text = @"绑定成功";
        [UserDataAccessor setUserPartnerNumber:_partnerNumber];
        [UIView animateWithDuration:1.0 animations:^{
            _emailButton.alpha = 1.0;
            _messageButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
    else if (result == 2){
        // changed partner successfully
        _buttonLabel.text = @"绑定成功";
        [UserDataAccessor setUserPartnerNumber:_partnerNumber];
    }
    else if (result == 3){
        //can not changed partner
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲，你已近绑定了一个号码，不能再绑定其他号码了" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alertView show];
    }
    else if (result == -1){
        //internal error, didn't not find the user in waitinglist
        
    }
    else{
        //error
    }
}

- (IBAction)done:(id)sender
{
    NSString *numStr = _numberField.text;
    NSCharacterSet* phoneChars = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
    NSArray* words = [numStr componentsSeparatedByCharactersInSet :[phoneChars invertedSet]];
    
    NSString* strippedNumber = [words componentsJoinedByString:@""];
    if ([strippedNumber length] < 11 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"号码有误，请重新填写" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if (![[strippedNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"]) {
        if (![[strippedNumber substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) {
            strippedNumber = [NSString stringWithFormat:@"00%@%@",@"86",strippedNumber];
        }
    }
    else{
        // Change + to 00
        strippedNumber = [strippedNumber substringFromIndex:1];
        strippedNumber = [NSString stringWithFormat:@"00%@",strippedNumber];
    }
    _partnerNumber = strippedNumber;
    [[WaitingListUtils sharedInstance] addPartner:strippedNumber];
}

- (IBAction)sendMessage:(id)sender {
}

- (IBAction)sendEmail:(id)sender {
}

#pragma mark --UITextFieldDelegate--
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_numberField resignFirstResponder];
    return YES;
}

@end
