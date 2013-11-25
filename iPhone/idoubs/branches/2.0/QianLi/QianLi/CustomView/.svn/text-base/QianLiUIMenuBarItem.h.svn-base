//
//  QianLiUIMenuBarItem.h
//  QianLi
//
//  Created by Tomoya on 13-8-27.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QianLiUIMenuBarItem : NSObject
{
//    UILabel *_itemName; // Bar Item的名字
//    UIImageView *_icon; // Bar Item的图标
    id _target;
    SEL _action;
//    UIControl *_containView;
    CGSize _itemSize;
}

@property (nonatomic, retain) UIControl *containView;
@property (nonatomic, weak) UILabel *itemName; // Bar Item的名字
@property (nonatomic, weak) UIImageView *icon; // Bar Item的图标

- (id)initWithTitle:(NSString *)title target:(id)target image:(UIImage *)image action:(SEL)action size:(CGSize)itemSize;

- (void)layoutSubviews;

@end
