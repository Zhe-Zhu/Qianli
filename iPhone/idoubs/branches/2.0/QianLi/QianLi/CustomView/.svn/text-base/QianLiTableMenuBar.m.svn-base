//
//  QianLiTableMenuBar.m
//  QianLi
//
//  Created by Tomoya on 13-9-9.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "QianLiTableMenuBar.h"

@implementation QianLiTableMenuBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initCommonUI
{
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    CGRect of = self.frame;
    
    // 加入分割线
    int itemIndex = 1;
    int itemCount = [self.items count];
    for (UIView *item in self.items) {
        if (itemIndex == itemCount) {
            continue;
        }
        UIImageView *horizonalLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, of.size.height/itemCount*itemIndex-1, of.size.width, 1)];
        horizonalLine.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0f];
        UIImageView *horizonalLineBright = [[UIImageView alloc] initWithFrame:CGRectMake(0, of.size.height/itemCount*itemIndex, of.size.width, 1)];
        horizonalLineBright.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0f];
        [self addSubview:horizonalLine];
        [self addSubview:horizonalLineBright];
        itemIndex++;
    }

    
    UIImageView *horizonalLineTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, of.size.width, 1)];
    horizonalLineTop.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f];
    
    UIImageView *horizonalLineHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, -4, of.size.width, 4)];
    horizonalLineHeader.backgroundColor = [UIColor colorWithRed:72/255.0 green:176/255.0 blue:191/255.0 alpha:1.0f];
    

    [self addSubview:horizonalLineTop];
    [self addSubview:horizonalLineHeader];
}

- (void)resetMenuBarItems
{
    int itemIndex = 0;
    for (QianLiTableMenuBarItem *item in self.items) {
        itemIndex++;
        // 调节item位置
        CGFloat itemWidth = self.frame.size.width;
        CGFloat itemHeight = self.frame.size.height/[self.items count];
        item.containView.frame = CGRectMake(0, (itemIndex-1)*itemHeight, itemWidth, itemHeight);
        [self addSubview:item.containView];
    }
}

- (void)presentModelView
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow]; // 读取当前设备屏幕参数
    if (![keywindow.subviews containsObject:self]) {
        // 计算frame
        CGRect sf = self.frame;
        CGRect vf = keywindow.frame;
        CGRect showFrame = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        
        if ([self.delegate respondsToSelector:@selector(menuBarWillPresent)]) {
            [self.delegate menuBarWillPresent];
        }
        // Present view animatedly
        self.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [keywindow addSubview:self];
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            self.frame = showFrame;
        }];
    }
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
