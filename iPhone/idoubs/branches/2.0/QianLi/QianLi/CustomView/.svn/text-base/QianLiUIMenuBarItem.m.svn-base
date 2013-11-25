//
//  QianLiUIMenuBarItem.m
//  QianLi
//
//  Created by Tomoya on 13-8-27.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "QianLiUIMenuBarItem.h"

@implementation QianLiUIMenuBarItem

- (id)initWithTitle:(NSString *)title target:(id)target image:(UIImage *)image action:(SEL)action size:(CGSize)itemSize
{
    if (self = [super init]) {
        // 添加contain view,用以接受点击操作
        _itemSize = itemSize;
        
        UIControl *containView = [[UIControl alloc] initWithFrame:CGRectZero];
        _containView = containView;
        [_containView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemName =itemName;
        _itemName.textAlignment = NSTextAlignmentCenter;
        _itemName.backgroundColor = [UIColor clearColor];
        _itemName.textColor = [UIColor colorWithWhite:43/255.0 alpha:1.0f];
        _itemName.lineBreakMode = NSLineBreakByTruncatingTail;
        _itemName.numberOfLines = 1;
        _itemName.font = [UIFont boldSystemFontOfSize:13.0f];
        _itemName.text = title;
        [_containView addSubview:_itemName];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:image];
        _icon = icon;
        [_containView addSubview:_icon];
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    // 调整名字和图片位置和大小
    _containView.frame = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
    
    _icon.center = CGPointMake(_containView.center.x, _containView.center.y-5.f);
    _itemName.frame = CGRectMake(0, _containView.bounds.size.height-35.0f, _containView.bounds.size.width, 20.f);
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
