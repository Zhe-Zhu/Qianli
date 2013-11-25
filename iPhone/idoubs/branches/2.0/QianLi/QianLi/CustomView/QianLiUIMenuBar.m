//
//  QianLiUIMenuBar.m
//  QianLi
//
//  Created by Tomoya on 13-8-26.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import "QianLiUIMenuBar.h"
#import "Global.h"
#import <Accelerate/Accelerate.h>
#import "DRNRealTimeBlurView.h"
#import "QianLiUIMenuBarItem.h"

@interface QianLiUIMenuBar ()
@end

@implementation QianLiUIMenuBar

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _items = [[NSMutableArray alloc] initWithArray:items];
        [self initCommonUI];
        [self resetMenuBarItems];
    }
    return self;
}

- (void)initCommonUI
{
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    CGRect of = self.frame;
    // 加入分割线
    UIImageView *horizonalLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, of.size.height/2.0, of.size.width, 1)];
    horizonalLine.backgroundColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0f];
    
    UIImageView *verticalLine = [[UIImageView alloc] initWithFrame:CGRectMake(of.size.width/3.0, 0, 1, of.size.height)];
    verticalLine.backgroundColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0f];
    
    UIImageView *verticalLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(of.size.width/3.0*2, 0, 1, of.size.height)];
    verticalLine2.backgroundColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0f];
    
    [self addSubview:horizonalLine];
    [self addSubview:verticalLine2];
    [self addSubview:verticalLine];
}

- (void)resetMenuBarItems
{
    // 目前阶段items数量只能支持6个
    assert(_items.count<=6);
    int itemIndex = -1;
    for (QianLiUIMenuBarItem *item in _items) {
        itemIndex++;
        int row = itemIndex/3 + 1;
        int column = 0;
        if (row == 1) {
            column = itemIndex;
        }
        else {
            column = itemIndex - 3;
        }
        // 调节item位置
        CGFloat itemWidth = self.frame.size.width/3.0;
        CGFloat itemHeight = self.frame.size.height/2.0;
        item.containView.frame = CGRectMake(column*itemWidth, (row-1)*itemHeight, itemWidth, itemHeight);
        [self addSubview:item.containView];
    }
}

- (void)show
{
    _isShow = YES;
    [self presentModelView];
}

- (void)dismiss
{
    _isShow = NO;
    [self dismissModelView];
}

- (void)dismissModelView
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow]; // 读取当前设备屏幕参数
    // 计算frame
    CGRect sf = self.frame;
    CGRect vf = keywindow.frame;
    CGRect returnFrame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
    
    if ([self.delegate respondsToSelector:@selector(menuBarWillDismiss)]) {
        [self.delegate menuBarWillDismiss];
    }
    if (_dismissButton) {
        [_dismissButton removeFromSuperview];
    }
    
    // Dismiss Menu Bar animatedly
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        self.frame = returnFrame;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

- (void)presentModelView
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow]; // 读取当前设备屏幕参数
    if (![keywindow.subviews containsObject:self]) {
        // 计算frame
        CGRect sf = self.frame;
        CGRect vf = keywindow.frame;
        CGRect showFrame = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        
        UIControl *dismissButton = [[UIControl alloc] initWithFrame:CGRectMake(0, 44+20, keywindow.frame.size.width, keywindow.frame.size.height-64-229-44)];
        _dismissButton = dismissButton;
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _dismissButton.backgroundColor = [UIColor clearColor];
        
        [keywindow addSubview:_dismissButton];
        
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
