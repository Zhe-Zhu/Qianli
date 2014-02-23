//
//  SettingProfileViewController.m
//  QianLi
//
//  Created by Tomoya on 13-9-10.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "SettingProfileViewController.h"
#import "UserDataTransUtils.h"
#import "UIImageExtras.h"
#import "Utils.h"

@interface SettingProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *bigProfilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellAvatar;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBigPhoto;
@property (weak, nonatomic) QianLiImagePickerViewController *imagePicker;
@property (weak, nonatomic) IBOutlet UILabel *labelAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelBigPhoto;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;

@property (nonatomic) BOOL isBigPhoto; // 用于判断是截取圆型的头像还是方形的大头像

@end

@implementation SettingProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

   // [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.avatar.clipsToBounds = YES;
    self.avatar.layer.cornerRadius = CGRectGetWidth(self.avatar.frame)/2.0;
    
    NSString *name = [UserDataAccessor getUserName];
    if (!name || [name isEqualToString:@""]) {
        name = NSLocalizedString(@"unset", nil);
    }
    self.name.text = name;
    self.phoneNumber.text = [UserDataAccessor getUserRemoteParty];
    
    self.hidesBottomBarWhenPushed = YES;
    
    _labelAvatar.text = NSLocalizedString(@"labelAvatar", nil);
    _labelBigPhoto.text = NSLocalizedString(@"labelBigPhoto", nil);
    _labelName.text = NSLocalizedString(@"labelName", nil);
    _labelPhoneNumber.text = NSLocalizedString(@"labelPhoneNumber", nil);
    
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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getBigAvatar];
    [self restoreImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getBigAvatar
{
    if ([Utils checkInternetAndDispWarning:NO]) {
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        if (![userData boolForKey:@"FirstInProfile"])
        /*if (![userData boolForKey:@"FirstInstall"] && ![userData boolForKey:@"FirstInProfile"]) */{
            [UserDataTransUtils getUserBigAvatar:[UserDataAccessor getUserRemoteParty] Completion:^(NSString *bigAvatarURL) {
                [userData setBool:YES forKey:@"FirstInProfile"];
                [userData synchronize];
                if (bigAvatarURL) {
                    UIImage *image = [UserDataTransUtils getImageAtPath:bigAvatarURL];
                    [UserDataAccessor setUserPhoneDispImage:image];
                    [_bigProfilePhoto performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                }
            }];
        }
    }
}

- (void)clearImages
{
    _avatar.image = nil;
    _bigProfilePhoto.image = nil;
}

- (void)restoreImage
{
    UIImage *profile = [UserDataAccessor getUserProfile];
    if (!profile) {
        profile = [UIImage imageNamed:@"defaultAvatar.png"];
    }
    profile = [self reSizeImage:profile toSize:CGSizeMake(88, 88)];
    self.avatar.image = profile;
    
    UIImage *bigPhoto = [UserDataAccessor getUserPhoneDispImage];
    if (!bigPhoto) {
        bigPhoto = [UIImage imageNamed:@"defaultBigPhoto.png"];
    }
    bigPhoto = [self reSizeImage:bigPhoto toSize:CGSizeMake(76, 104)];
    self.bigProfilePhoto.image = bigPhoto;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForCell:_cellAvatar]]) {
        UIActionSheet *chooesPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Camera", nil), nil];
        [chooesPhoto showInView:self.view];
        _isBigPhoto = NO;
    }
    else if ([indexPath isEqual:[tableView indexPathForCell:_cellBigPhoto]]) {
        UIActionSheet *chooesPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Camera", nil), nil];
        [chooesPhoto showInView:self.view];
        _isBigPhoto = YES;
    }
}

#pragma mark  --ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self openPhotoSourceWithIndex:buttonIndex];
    }
    else{
        [_cellAvatar setSelected:NO animated:YES];
        [_cellBigPhoto setSelected:NO animated:YES];
    }
}

- (void)openPhotoSourceWithIndex:(NSInteger)indicator
{
    if (indicator == 0) {
        if ([QianLiImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO){
            return;
        }
        
        QianLiImagePickerViewController *mediaUI = [[QianLiImagePickerViewController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker = mediaUI;
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.  UIImagePickerControllerSourceTypeSavedPhotosAlbum
        mediaUI.mediaTypes = [QianLiImagePickerViewController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        [self presentViewController: mediaUI animated: YES completion:nil];
    }
    else if (indicator == 1){
        if ([QianLiImagePickerViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
            return;
        }
        
        QianLiImagePickerViewController *mediaUI = [[QianLiImagePickerViewController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker = mediaUI;
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        mediaUI.mediaTypes = [QianLiImagePickerViewController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        [self presentViewController: mediaUI animated: YES completion:nil];
    }
}

#pragma mark -- UIImagePickerViewControllerDelegate --
- (void)imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissViewControllerAnimated: YES completion:nil];
}

// For responding to the user accepting a newly-captured picture
- (void)imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    if (_isBigPhoto) {
        BigPhotoEditViewController *bigPhotoEditVC = [storyboard instantiateViewControllerWithIdentifier:@"BigPhotoEditViewController"];
        bigPhotoEditVC.profile = image;
        bigPhotoEditVC.delegate = self;
        [_imagePicker presentViewController:bigPhotoEditVC animated:YES completion:nil];
    }
    else {
        ProfileEditViewController *proEditVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileEditViewController"];
        proEditVC.profile = image;
        proEditVC.delegate = self;
        [_imagePicker presentViewController:proEditVC animated:YES completion:nil];
    }
}

- (void)didFinishEditing:(UIImage *)profile
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (![Utils checkInternetAndDispWarning:YES]) {
        return;
    }
    if (_isBigPhoto) {
        UIImage *smallProfile = [self reSizeImage:profile toSize:CGSizeMake(76, 104)];
        [UserDataTransUtils patchUserPhoneDispImage:profile number:[UserDataAccessor getUserRemoteParty] Completion:^(BOOL success) {
            [UserDataAccessor setUserPhoneDispImage:profile];
            [_bigProfilePhoto performSelectorOnMainThread:@selector(setImage:) withObject:smallProfile waitUntilDone:NO];
        }];
    }
    else {
        UIImage *image = [self reSizeImage:profile toSize:CGSizeMake(88, 88)];
        [UserDataTransUtils patchUserProfile:image number:[UserDataAccessor getUserRemoteParty] Completion:^(BOOL success) {
            [UserDataAccessor setUserProfile:image];
            [_avatar performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"changeName"])
	{
		SettingChangeNameViewController *settingChangeNameViewController = segue.destinationViewController;
		settingChangeNameViewController.delegate = self;
	}
}

- (void)nameChanged:(NSString *)newName
{
    [UserDataAccessor setUserName:newName];
    self.name.text = [UserDataAccessor getUserName];
}

@end
