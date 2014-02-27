//
//  AddPartnerViewController.m
//  QianLi
//
//  Created by LG on 2/17/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "AddPartnerViewController.h"

@interface AddPartnerViewController ()
{
    BOOL isFirstEnter;
}

@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *partnerLabel;
@property (strong, nonatomic) NSString *partnerNumber;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) UILabel *buttonLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteEmailLabel;
@property (weak, nonatomic) UILabel *noteLabel;

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
    NSString *str = NSLocalizedString(@"addPartnerIntro", nil);
    CGSize constraintSize;
    constraintSize.width = 260;
    constraintSize.height = MAXFLOAT;
    CGSize contentSize = [str sizeWithFont:[UIFont fontWithName:@"ArialHebrew" size:17] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((320 - contentSize.width) / 2.0, 81, contentSize.width, contentSize.height)];
    label.text = str;
    label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:137 / 255.0 green:137 / 255.0 blue:137 / 255.0 alpha:1.0];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    _noteLabel = label;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    NSString *partnerNumber = [UserDataAccessor getUserPartnerNumber];
    if (!partnerNumber) {
        _messageButton.alpha = 0.0;
        _emailButton.alpha = 0.0;
        _inviteMessageLabel.alpha = 0.0;
        _inviteEmailLabel.alpha = 0.0;
    }
    else {
        if ([[partnerNumber substringToIndex:4]isEqualToString:@"0086"]) {
            _numberField.text = [partnerNumber substringFromIndex:4];
        }
        else {
            _numberField.text = partnerNumber;
        }
        _numberField.enabled = NO;
        _doneButton.enabled = NO;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"partner_verified"]) {
        _partnerLabel.alpha = 0.0;
        _numberField.alpha = 0.0;
        _doneButton.alpha = 0.0;
        label.text = [NSString stringWithFormat:NSLocalizedString(@"partnerVerifiedText", nil), partnerNumber];
    }
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _doneButton.frame.size.width, _doneButton.frame.size.height)];
    _buttonLabel = buttonLabel;
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textColor = [UIColor whiteColor];
    if (!partnerNumber) {
        buttonLabel.text = NSLocalizedString(@"addPartnerOK", nil);
    }
    else {
        buttonLabel.text = NSLocalizedString(@"bindPartnerSuccessfully", nil);
    }
    
    buttonLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:18];
    [_doneButton addSubview:buttonLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPartner:) name:kAddPartnerNotification object:nil];
    
    _inviteMessageLabel.text = NSLocalizedString(@"inviteMessage", nil);
    _inviteEmailLabel.text = NSLocalizedString(@"inviteEmail", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_numberField.alpha > 0.1 && ([UserDataAccessor getUserPartnerNumber] == nil)) {
        if ([_numberField canBecomeFirstResponder]) {
            [_numberField becomeFirstResponder];
        }
    }
    //added by Xiangwen
    //localized partnerLabel;
    _partnerLabel.text = NSLocalizedString(@"partnerNumber", nil);
    
    isFirstEnter = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!IS_OS_7_OR_LATER) {
        for (UIView *view in self.view.subviews) {
            if (view == _noteLabel && !isFirstEnter) {
                continue;
                // 为了防止ios6中便签不停上移
            }
            CGRect frame = view.frame;
            frame =CGRectMake(frame.origin.x, frame.origin.y - 40, frame.size.width, frame.size.height);
            view.frame = frame;
        }
        isFirstEnter = NO;
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alreadyHavePartnerTitle", nil) message:NSLocalizedString(@"alreadyHavePartnerText", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alreadyHavePartnerOK", nil) otherButtonTitles: nil];
        [alertView show];
    }
    else if (result == 1){
        // first time add partner successfully
        _buttonLabel.text = NSLocalizedString(@"bindPartnerSuccessfully", nil);
        [UserDataAccessor setUserPartnerNumber:_partnerNumber];
        _doneButton.enabled = NO;
        _numberField.enabled = NO;
        [UIView animateWithDuration:1.0 animations:^{
            _emailButton.alpha = 1.0;
            _messageButton.alpha = 1.0;
            _inviteMessageLabel.alpha = 1.0;
            _inviteEmailLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else if (result == 2){
        // changed partner successfully
        _buttonLabel.text = NSLocalizedString(@"bindPartnerSuccessfully", nil);
        [UserDataAccessor setUserPartnerNumber:_partnerNumber];
    }
    else if (result == 3){
        //can not changed partner
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"notChangePartnerTitle", nil) message: NSLocalizedString(@"notChangePartnerText", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"notChangePartnerOK", nil) otherButtonTitles: nil];
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addPartnerErrorTitle", nil) message:NSLocalizedString(@"addPartnerErrorText", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"addPartnerErrorOK", nil) otherButtonTitles: nil];
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

- (IBAction)sendMessage:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        messageComposer.recipients = @[[UserDataAccessor getUserPartnerNumber]];
        NSString *message = NSLocalizedString(@"emailBody", nil);
        [messageComposer setBody:message];
        if (IS_OS_7_OR_LATER) {
            if ([MFMessageComposeViewController canSendSubject]) {
                messageComposer.subject = NSLocalizedString(@"emailSubject", nil);
            }
        }
        messageComposer.messageComposeDelegate = self;
        [self presentViewController:messageComposer animated:YES completion:nil];
    }
}

- (IBAction)sendEmail:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setSubject:NSLocalizedString(@"emailSubject", nil)];
        [vc setMessageBody:NSLocalizedString(@"emailBody", nil) isHTML:NO];
        vc.mailComposeDelegate = self;
        if (vc) {
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  ---MFMessageComposeViewControllerDelegate---
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultCancelled) {
        //Message cancelled
    } else if(result == MessageComposeResultSent) {
        //Message sent
    }
    else if (result == MessageComposeResultFailed){
        //
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --UITextFieldDelegate--
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_numberField resignFirstResponder];
    return YES;
}

@end
