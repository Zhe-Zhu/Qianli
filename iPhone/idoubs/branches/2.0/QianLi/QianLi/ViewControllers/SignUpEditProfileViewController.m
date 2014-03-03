//
//  SignUpEditProfileViewController.m
//  QianLi
//
//  Created by Tomoya on 13-9-4.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "SignUpEditProfileViewController.h"
#import "QianLiAppDelegate.h"

@interface SignUpEditProfileViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputName;
@property (weak, nonatomic) IBOutlet UIButton *editNameButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfilePhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;
@property (weak, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation SignUpEditProfileViewController

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
    [_editProfilePhotoButton addTarget:self action:@selector(editProfilePhotoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _editProfilePhotoButton.layer.cornerRadius = 53.5;//_editProfilePhotoButton.frame.size.width / 2.0;
    _editProfilePhotoButton.clipsToBounds = YES;
    
    [_editNameButton addTarget:self action:@selector(editNameButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _finishButton.target = self;
    _finishButton.action = @selector(finishButtonPressed);
    
    _inputName.delegate = self;
    [_inputName becomeFirstResponder];
    
    self.navigationItem.title = NSLocalizedString(@"signUpEditProfileTitle", nil);

    [self.navigationItem setHidesBackButton:YES];
    _inputName.placeholder = NSLocalizedString(@"inputName", nil);
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"done", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _inputName.text = [UserDataAccessor getUserName];
    UIImage *avatar = [UserDataAccessor getUserProfile];
    if (avatar) {
        [_editProfilePhotoButton setImage:avatar forState:UIControlStateNormal];
    }
}

- (void)editNameButtonPressed
{
    [_inputName becomeFirstResponder];
}

- (void)editProfilePhotoButtonPressed
{
    UIActionSheet *chooesPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Album", nil), NSLocalizedString(@"Camera", nil), nil];
    [chooesPhoto showInView:self.view];
}

- (void)finishButtonPressed
{
    QianLiAppDelegate *qianliAppDelegate = (QianLiAppDelegate*)[UIApplication sharedApplication].delegate;
    [qianliAppDelegate resetRootViewController];
}

- (void)continueButtonPressed
{
    QianLiAppDelegate *qianliAppDelegate = (QianLiAppDelegate*)[UIApplication sharedApplication].delegate;
    [qianliAppDelegate resetRootViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  --ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self openPhotoSourceWithIndex:buttonIndex];
    }
}

- (void)openPhotoSourceWithIndex:(NSInteger)indicator
{
    if (indicator == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO){
            return;
        }
        
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker = mediaUI;
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.  UIImagePickerControllerSourceTypeSavedPhotosAlbum
        mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        [self presentViewController: mediaUI animated: YES completion:nil];
    }
    else if (indicator == 1){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
            return;
        }
        
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker = mediaUI;
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        mediaUI.allowsEditing = NO;
        mediaUI.delegate = self;
        [self presentViewController: mediaUI animated: YES completion:nil];
    }
}

#pragma mark -- UIImagePickerViewControllerDelegate --
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissViewControllerAnimated: YES completion:nil];
}

// For responding to the user accepting a newly-captured picture
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        image = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
     }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ProfileEditViewController *proEditVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileEditViewController"];
    proEditVC.profile = image;
    proEditVC.delegate = self;
    [_imagePicker presentViewController:proEditVC animated:YES completion:nil];
}

- (void)didFinishEditing:(UIImage *)profile
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_editProfilePhotoButton setImage:profile forState:UIControlStateNormal];
    UIImage *image = [profile imageByResizing:CGSizeMake(120, 120)];
    BOOL success = [UserDataAccessor setUserProfile:image];
    if (!success) {
        NSLog(@"save profile error!");
    }
    [UserDataTransUtils patchUserProfile:image number:[UserDataAccessor getUserRemoteParty] Completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_inputName resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UserDataAccessor setUserName:_inputName.text];
    [UserDataTransUtils patchUserName:_inputName.text number:[UserDataAccessor getUserRemoteParty] Completion:nil];
}

@end
