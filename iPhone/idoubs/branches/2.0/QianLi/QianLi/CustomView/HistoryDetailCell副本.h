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

+ (CGFloat)setHeigtofCellWithString:(NSString *)string constrainedWidth:(CGFloat)width;
- (void)setString:(NSString *)string avatar:(UIImage *)avatarImage SharedImage:(UIImage *)sharedImage
     forTableView:(UITableView *)tableView;

@end
