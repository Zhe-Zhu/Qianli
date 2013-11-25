//
//  Asset.m
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "AssetCell.h"

@interface AssetCell ()

@end

@implementation AssetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _imageView = image;
        [self addSubview:_imageView];
        
        UIImageView *uncheckBox = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-25, self.bounds.size.height-25, 25, 25)];
        uncheckBox.image = [UIImage imageNamed:@"uncheckBox.png"];
        [self addSubview:uncheckBox];

    }
    return self;
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
