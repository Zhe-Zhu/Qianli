//
//  DoodleBackView.h
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoodleView.h"
#import "ImageDisplayController.h"

@interface DoodleBackView : UIView

@property(weak, nonatomic) id delegate;
@property(strong, nonatomic) UIImage *image;
- (void)setImageView:(CGRect)frame;

@end
