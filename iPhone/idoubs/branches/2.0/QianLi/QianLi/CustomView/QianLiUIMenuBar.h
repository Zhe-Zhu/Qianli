//
//  QianLiUIMenuBar.h
//  QianLi
//
//  Created by Tomoya on 13-8-26.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QianLiUIMenuBar;

@protocol QianLiUIMenuBarDelegate <NSObject>
@optional
- (void)menuBar:(QianLiUIMenuBar *)menuBar didSelectAtIndex:(int)index;
- (void)menuBarWillDismiss;
- (void)menuBarWillPresent;
- (UIImage*)menuBarBlurimageSource;

@end

@interface QianLiUIMenuBar : UIView

@property (nonatomic, assign) id<QianLiUIMenuBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) BOOL isShow; // 用于判断menubar是否处在展示状态
@property (nonatomic, retain) UIControl *dismissButton; // 用于接收点击来dismiss menubar

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

- (void)show; // 展示MenuBar
- (void)dismiss; // 将MenuBar缩回
@end
