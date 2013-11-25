//
//  HistoryDetailCell.h
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HistoryDetailCell : UITableViewCell

+ (CGFloat)setHeightofCellWithString:(NSString *)string constrainedWidth:(CGFloat)width;
+ (CGFloat)setHeightofCellWithPicturesCount:(NSInteger)picturesCount;

- (void)setCallRecord:(NSNumber *)callRecordType avatarMyFriend:(UIImage *)avatarMyFriend avatarMyself:(UIImage *)avatarMyself;

- (void)setString:(NSString *)string avatar:(UIImage *)avatarImage SharedImage:(UIImage *)sharedImage
     forTableView:(UITableView *)tableView;

- (void)showPictures:(NSArray *)pictures; // 显示图片的cell

// callRecordType目前有四种, (1)呼出通话, (2)呼入通话, (3)未接来电, (4)通话请求
- (void)setCallRecord:(NSUInteger)callRecordType timeLabel:(NSString *)timeLabel footnote:(NSString *)footnote;

// 如果有照片传递
- (void)setCallRecord:(NSUInteger)callRecordType timeLabel:(NSString *)timeLabel footnote:(NSString *)footnote images:(NSArray *)imageArray;

@end
