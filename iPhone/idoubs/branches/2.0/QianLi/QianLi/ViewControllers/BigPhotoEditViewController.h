//
//  BigPhotoEditViewController.h
//  QianLi
//
//  Created by Tomoya on 13-10-10.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@protocol PhotoEditProfileDelegate <NSObject>

- (void)didFinishEditing:(UIImage *)profile;

@end

@interface BigPhotoEditViewController : UIViewController<UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIImage *profile;
@property(nonatomic, weak) id<PhotoEditProfileDelegate>delegate;

@end
