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
#import "DetailHistoryAccessor.h"
#import "WebHistoryDataAccessor.h"

@interface SettingViewController (){
    int repliesCountNumber;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UITableViewCell *sendToSocialMediaCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *deleteAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *feedback;
@property (weak, nonatomic) IBOutlet UILabel *repliesCount;
@property (weak, nonatomic) IBOutlet UIImageView *repliesCountBackground;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutQianli;
@property (weak, nonatomic) IBOutlet UITableViewCell *rateUs;
@property (weak, nonatomic) IBOutlet UITableViewCell *share;

@property (weak, nonatomic) IBOutlet UILabel *labelProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSMS;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelFeedback;
@property (weak, nonatomic) IBOutlet UILabel *labelSignout;
@property (weak, nonatomic) IBOutlet UILabel *labelAbout;
@property (weak, nonatomic) IBOutlet UILabel *rateUsLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;


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
    _rateUsLabel.text = NSLocalizedString(@"RateUs", nil);
    _shareLabel.text = NSLocalizedString(@"share", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 读取用户的照片
    [self getNameAndAvatar];
    self.profilePhoto.clipsToBounds = YES;
    CGFloat radius = 19;//CGRectGetWidth(self.profilePhoto.bounds) / 2.0;
    self.profilePhoto.layer.cornerRadius = radius;
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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
                    [UserDataTransUtils getImageAtPath:avatarURL completion:^(UIImage *image) {
                        if (image) {
                            [UserDataAccessor setUserProfile:image];
                            [self.profilePhoto performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                        }
                        [UserDataAccessor setUserName:name];
                    }];
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

    if ([indexPath isEqual:[tableView indexPathForCell:_sendToSocialMediaCell]]) {
        // send to social media
        [Utils shareThingsToSocialMedia:self text:NSLocalizedString(@"emailBody", nil) Image:nil delegate:nil];
        [_sendToSocialMediaCell setSelected:NO animated:YES];
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
    else if ([indexPath isEqual:[tableView indexPathForCell:_rateUs]]) {
        // rate us
        // add here
        int appId = 830277724;//830277724; //595247165
        // user should press the store button to go to the apple store in IOS7. Thus we directly open the apple store url in IOS7.
        if (!IS_OS_7_OR_LATER) {
            [_rateUs setSelected:NO animated:YES];
            SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
            NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier:[NSNumber numberWithInteger: appId]};
            [storeViewController loadProductWithParameters:parameters completionBlock:nil];
            storeViewController.delegate = self;
            [self presentViewController:storeViewController animated:YES completion:nil];
        }
        else
        {
            [_rateUs setSelected:NO animated:YES];
            NSString *str = [NSString stringWithFormat:
                             @"itms-apps://itunes.apple.com/app/id%d",appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        
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
    else if (buttonIndex == alertView.cancelButtonIndex){
        [_deleteAccount setSelected:NO animated:YES];
    }
}

- (void)removeAccount
{
    [UserDataTransUtils deleteAccount:[UserDataAccessor getUserRemoteParty] Completion:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:kSingUpKey];
    [userDefaults synchronize];
    [UserDataAccessor setUserName:@""];
    [UserDataAccessor setUserPartnerNumber:@""];
    [UserDataAccessor deleteUserImages];
    [[MainHistoryDataAccessor sharedInstance] deleteAllObjects];
    [[DetailHistoryAccessor sharedInstance] deleteAllHistory];
    [[WebHistoryDataAccessor sharedInstance] deleteObjectForType:@"HISTORY"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"partner_verified"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *signUpEditProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterNavigationController"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = signUpEditProfileViewController;
}

#pragma mark  --SKStoreProductViewControllerDelegate Method--
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    //
    [viewController dismissViewControllerAnimated:YES completion:nil];
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
