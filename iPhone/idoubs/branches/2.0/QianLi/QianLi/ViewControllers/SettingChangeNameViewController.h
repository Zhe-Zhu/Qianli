//
//  SettingChangeNameViewController.h
//  QianLi
//
//  Created by Tomoya on 13-10-3.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingChangeNameDelegate;

@interface SettingChangeNameViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (assign, nonatomic) id<SettingChangeNameDelegate> delegate;

@end

@protocol SettingChangeNameDelegate <NSObject>

- (void)nameChanged: (NSString *)newName;

@end