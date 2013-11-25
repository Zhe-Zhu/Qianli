//
//  ProfileEditViewController.h
//  QianLi
//
//  Created by lutan on 9/5/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@protocol EditProfileDelegate <NSObject>

- (void)didFinishEditing:(UIImage *)profile;

@end

@interface ProfileEditViewController : UIViewController<UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIImage *profile;
@property(nonatomic, weak) id<EditProfileDelegate>delegate;

@end


