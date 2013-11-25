//
//  SettingProfileViewController.h
//  QianLi
//
//  Created by Tomoya on 13-9-10.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileEditViewController.h"
#import "UserDataAccessor.h"
#import "SettingChangeNameViewController.h"
#import "BigPhotoEditViewController.h"

@interface SettingProfileViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditProfileDelegate, SettingChangeNameDelegate, PhotoEditProfileDelegate>

- (void)clearImages;
- (void)restoreImage;
@end
