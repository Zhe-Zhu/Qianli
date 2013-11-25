//
//  HistoryMainCell.h
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RMSwipeTableViewCell.h"

@protocol HistoryMainCellDelegate;

@interface HistoryMainCell : RMSwipeTableViewCell

- (void)setHistoryMainCell:(NSString *)id avatar:(UIImage *)avatar Name:(NSString *)name Time:(NSString *)time Content:(NSString *)content;

- (void)isMissedCall:(BOOL)yesOrNo; // 未接来电和其他消息显示方式不同, 如果该消息是未接来电, 应该在创建Cell之后调用该函数

- (void) startSpin;
- (void) stopSpin;

- (void) resetContentView;

- (void) activateRequestStatus; // 被预约时调用,激活预约状态

- (void) stopAllAnimation;

- (void) addContentsToCell; // 专门写个函数,避免每次都需要remove subviews

@property (nonatomic, assign) id<HistoryMainCellDelegate> historyMainCelldelegate;

@end

@protocol HistoryMainCellDelegate <NSObject>
@optional
- (void)sendRequest:(HistoryMainCell *)historyMainCell;

- (void)cancelRequest:(HistoryMainCell *)historyMainCell;

- (void)makeACall:(HistoryMainCell *)historyMainCell;
@end