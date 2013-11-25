//
//  DoodleBackView.m
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "DoodleBackView.h"

@interface DoodleBackView ()

@property(nonatomic) BOOL isDrawing;

@end

@implementation DoodleBackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer: tapGesture];
    }
    return self;
}

- (void)setImageView:(CGRect)frame
{
    UIImageView *backGroundView = [[UIImageView alloc] initWithFrame:frame];
    backGroundView.image = _image;
    [self addSubview:backGroundView];
}


-(void)handleTap:(UITapGestureRecognizer *)tap
{
    [_delegate didTipOnView];
}

@end
