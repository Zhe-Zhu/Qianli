//
//  QianLiTableMenuBarItem.m
//  QianLi
//
//  Created by Tomoya on 13-9-9.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "QianLiTableMenuBarItem.h"

@implementation QianLiTableMenuBarItem

- (id)initWithTitle:(NSString *)title target:(id)target image:(UIImage *)image action:(SEL)action size:(CGSize)itemSize
{
    self = [super initWithTitle:title target:target image:image action:action size:itemSize];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    // 调整名字和图片位置和大小
    self.containView.frame = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
    
    self.icon.frame = CGRectMake(25, _itemSize.height/2.0-25/2.0-1, 25, 25);
    self.itemName.frame = CGRectMake(70, self.containView.bounds.size.height/2.0 - 10, 200, 20);
    self.itemName.textAlignment = NSTextAlignmentLeft;
    self.itemName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:17.0f];
}

- (void)highlight
{
    // 将该item高亮
    self.itemName.textColor = [UIColor colorWithRed:195/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
