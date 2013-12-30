//
//  SettingViewController.m
//  QianLi
//
//  Created by Tomoya on 13-8-16.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "SettingViewController.h"
#import "PictureManager.h"
#import "UserDataAccessor.h"
#import "UserDataTransUtils.h"
#import "MainHistoryDataAccessor.h"
#import "SipStackUtils.h"
#import "SignUpViewController.h"
#import "SettingProfileViewController.h"
#import "Utils.h"
#import "UserDataTransUtils.h"
#import "UMFeedback.h"

@interface SettingViewController (){
    int repliesCountNumber;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UITableViewCell *sendEmailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sendMessageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *deleteAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *feedback;
@property (weak, nonatomic) IBOutlet UILabel *repliesCount;
@property (weak, nonatomic) IBOutlet UIImageView *repliesCountBackground;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutQianli;

@property (weak, nonatomic) IBOutlet UILabel *labelProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSMS;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedback;
@property (weak, nonatomic) IBOutlet UILabel *labelSignout;
@property (weak, nonatomic) IBOutlet UILabel *labelAbout;


@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) SettingProfileViewController *settingProfileVC;
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator = activityIndicator;
    _activityIndicator.frame = CGRectMake(160-CGRectGetWidth(_activityIndicator.frame)/2.0, 100, CGRectGetWidth(_activityIndicator.frame), CGRectGetHeight(_activityIndicator.frame));
    [self.view addSubview:_activityIndicator];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    _labelProfile.text = NSLocalizedString(@"labelProfile", nil);
    _labelSMS.text = NSLocalizedString(@"labelSMS", nil);
    _labelEmail.text = NSLocalizedString(@"labelEmail", nil);
    _labelFeedback.text = NSLocalizedString(@"labelFeedback", nil);
    _labelSignout.text = NSLocalizedString(@"labelSignout", nil);
    _labelAbout.text = NSLocalizedString(@"labelAbout", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 读取用户的照片
    [self getNameAndAvatar];
    self.profilePhoto.clipsToBounds = YES;
    self.profilePhoto.layer.cornerRadius = CGRectGetWidth(self.profilePhoto.bounds)/2.0;
    self.profilePhoto.image = [UserDataAccessor getUserProfile];
    
    repliesCountNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"RepliesCount"];
    if (repliesCountNumber) {
        _repliesCount.text = [NSString stringWithFormat:@"%d",repliesCountNumber];
        [_repliesCount setHidden:NO];
        [_repliesCountBackground setHidden:NO];
    }
    else {
        [_repliesCount setHidden:YES];
        [_repliesCountBackground setHidden:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self navigationController] tabBarItem].badgeValue = Nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNameAndAvatar
{
    if ([Utils checkInternetAndDispWarning:NO]) {
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        if (![userData boolForKey:@"FirstInSetting"])
        /*if (![userData boolForKey:@"FirstInstall"] && ![userData boolForKey:@"FirstInSetting"])*/ {
            [UserDataTransUtils getUserData:[UserDataAccessor getUserRemoteParty] Completion:^(NSString *name, NSString *avatarURL) {
                [userData setBool:YES forKey:@"FirstInSetting"];
                [userData synchronize];
                if (avatarURL) {
                    UIImage *image = [UserDataTransUtils getImageAtPath:avatarURL];
                    [UserDataAccessor setUserProfile:image];
                    [UserDataAccessor setUserName:name];
                    [self.profilePhoto performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                }
            }];
        }
    }
}

- (void)clearImages
{
    self.profilePhoto.image = nil;
    if (_settingProfileVC) {
        [_settingProfileVC clearImages];
    }
}

- (void)restoreImages
{
    self.profilePhoto.image = [UserDataAccessor getUserProfile];
    if (_settingProfileVC) {
        [_settingProfileVC restoreImage];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForCell: _sendEmailCell]]) {
        // 发邮件邀请好友
        // 反馈
        _activityIndicator.frame = CGRectMake(268-CGRectGetWidth(_activityIndicator.frame)/2.0, CGRectGetMinY(_sendEmailCell.frame)+12, CGRectGetWidth(_activityIndicator.frame), CGRectGetHeight(_activityIndicator.frame));
        [_activityIndicator startAnimating];
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            [vc setSubject:NSLocalizedString(@"emailSubject", nil)];
            [vc setMessageBody:NSLocalizedString(@"emailBody", nil) isHTML:NO];
//            [vc setToRecipients:[NSArray arrayWithObjects:@"theashstudio@gmail.com",nil]];
            vc.mailComposeDelegate = self;
            if (vc) {
                [self presentViewController:vc animated:YES completion:^{
                    [_activityIndicator stopAnimating];
                }];
            }
        }
        else
        {
            UIAlertView * warningView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"emailWarningTitle", nil) message:NSLocalizedString(@"emailWarningMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"emailWarningOK", nil) otherButtonTitles:nil, nil];
            [warningView show];
            [_activityIndicator stopAnimating];
        }
    }
    else if ([indexPath isEqual:[tableView indexPathForCell:_sendMessageCell]]) {
        _activityIndicator.frame = CGRectMake(268-CGRectGetWidth(_activityIndicator.frame)/2.0, CGRectGetMinY(_sendMessageCell.frame)+12, CGRectGetWidth(_activityIndicator.frame), CGRectGetHeight(_activityIndicator.frame));
        [_activityIndicator startAnimating];
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *messageComposer =
            [[MFMessageComposeViewController alloc] init];
            NSString *message = NSLocalizedString(@"emailBody", nil);
            [messageComposer setBody:message];
            if (IS_OS_7_OR_LATER) {
                if ([MFMessageComposeViewController canSendSubject]) {
                    messageComposer.subject = NSLocalizedString(@"emailSubject", nil);
                }
            }
            messageComposer.messageComposeDelegate = self;
            [self presentViewController:messageComposer animated:YES completion:^{
                [_activityIndicator stopAnimating];
            }];
        }
        else {
            [_activityIndicator stopAnimating];
        }
    }
    else if ([indexPath isEqual:[tableView indexPathForCell:_deleteAccount]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"signOutTitle", nil) message:NSLocalizedString(@"signOutBody", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"signOutConfirm", nil), nil];
        alertView.delegate = self;
        [alertView show];
    }
    else if ([indexPath isEqual:[tableView indexPathForCell:_feedback]]){
        [UMFeedback showFeedback:self withAppkey:kUmengSDKKey];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"RepliesCount"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 非常重要
    // 因为该push操作是通过storyboard进行的,所以必须在这里设置hidesBottomBarWhenPushed属性
    // 不能在被push的viewcontroller的viewdidload中self.hidesBottomBarWhenPushed
    // 否则会无效
    _settingProfileVC = segue.destinationViewController;
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

#pragma mark  -- UIAlertViewDelegate--
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex){
        [self removeAccount];
    }
}

- (void)removeAccount
{
    //TODO:
//    [UserDataTransUtils deleteAccount:[UserDataAccessor getUserRemoteParty] Completion:^(BOOL updateTime) {
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults setBool:NO forKey:@"SignedUp"];
//        [userDefaults synchronize];
//        [[MainHistoryDataAccessor sharedInstance] deleteAllObjects];
//        [[SipStackUtils sharedInstance].historyService deleteAllObjects];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Successfully deleted account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertView show];
//    }];
    
    // 返回到注册界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *signUpEditProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterNavigationController"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = signUpEditProfileViewController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:kSingUpKey];
    [userDefaults synchronize];
}

# pragma mark -- Umeng Feedback

- (void)newReplies:(int)count
{
    int oldNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"RepliesCount"];
    if (oldNumber) {
        oldNumber = oldNumber + count;
        count = oldNumber;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"RepliesCount"];
    [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", count];
}

@end
