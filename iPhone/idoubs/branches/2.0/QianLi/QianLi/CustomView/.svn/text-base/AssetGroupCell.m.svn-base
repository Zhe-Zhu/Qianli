//
//  AssetGroupCell.m
//  QianLi
//
//  Created by lutan on 8/26/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "AssetGroupCell.h"
#import "Global.h"

@interface AssetGroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *posterImageview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation AssetGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithImage:(UIImage *)image Name:(NSString *)name Number:(NSString *)number
{
    _posterImageview.image = image;
//    _posterImageview.frame = CGRectMake(0, 0, 20, 20);
    _nameLabel.text = name;
//    CGSize constraintSize;
//    constraintSize.width = 250;
//    constraintSize.height = MAXFLOAT;
//    CGSize contentSize = [name sizeWithFont:[UIFont fontWithName:@"Arial" size:17] constrainedToSize:constraintSize lineBreakMode: NSLineBreakByWordWrapping];
//    CGRect frame = _nameLabel.frame;
////    _nameLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, contentSize.width, frame.size.height);
//    
//    contentSize = [number sizeWithFont:[UIFont fontWithName:@"Arial" size:17] constrainedToSize:constraintSize lineBreakMode: NSLineBreakByWordWrapping];
//    frame = _numberLabel.frame;
    
    _numberLabel.text = [NSString stringWithFormat:@"%@张照片", number];
//    _numberLabel.textColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
    _numberLabel.textColor = [UIColor grayColor];
    if (IS_OS_7_OR_LATER) {
        _numberLabel.textAlignment = NSTextAlignmentNatural;
    }
//    _numberLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f];
    //TODO: 本地化
    
//    _numberLabel.frame = CGRectMake(_nameLabel.frame.origin.x + 5 + _nameLabel.frame.size.width, frame.origin.y, contentSize.width, frame.size.height);
}

@end
