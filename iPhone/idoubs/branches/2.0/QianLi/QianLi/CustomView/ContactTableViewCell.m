//
//  ContactTableViewCell.m
//  AddressBook
//
//  Created by lutan on 7/9/13.
//  Copyright (c) 2013 Ashstudio. All rights reserved.
//

#import "ContactTableViewCell.h"

@interface ContactTableViewCell () {
    
}

@property (weak, nonatomic)  UIImageView *profileImageView;
@property (weak, nonatomic)  UILabel *nameLabel;
@property (weak, nonatomic)  UILabel *numberLabel;
@property (weak, nonatomic)  UIImageView *icon;
@property (weak, nonatomic)  UILabel *qianLiLabel;

@end

@implementation ContactTableViewCell

CGFloat cellHeight = 44;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCheckBox:(BOOL)hasCheckBox
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         self.selectionStyle = UITableViewCellSelectionStyleGray;
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, cellHeight/2.0 - avatarDiameter/2.0, avatarDiameter, avatarDiameter)];
        _profileImageView = imageView;
        [self addSubview:_profileImageView];
        
        UIImage *circleConver = [UIImage imageNamed:@"circle_cover_30.png"];
        UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(20, cellHeight/2.0 - avatarDiameter/2.0, avatarDiameter, avatarDiameter)];
        coverView.image = circleConver;
        [self addSubview:coverView];
        if (IS_OS_7_OR_LATER) {
            [coverView setHighlightedImage:[UIImage imageNamed:@"circle_cover_30_grey.png"]];
        }
        else{
            [coverView setHighlightedImage:[UIImage imageNamed:@"circle_cover_30_grey_ios6.png"]];
        }
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 200, 44)];
        labelName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        _nameLabel = labelName;
        [self addSubview:_nameLabel];
        
        //        // Set seperator line
        //        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, 325, 1)];
        //        line.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
        //        [self addSubview:line];
        
        // Add uncheck Box
        if (hasCheckBox) {
            UIImageView *uncheckBox = [[UIImageView alloc] initWithFrame:CGRectMake(275.5-28/2, 22.5-28/2, 28, 28)];
            _uncheckBox = uncheckBox;
            _uncheckBox.image = [UIImage imageNamed:@"uncheckBox.png"];
            [_uncheckBox setHidden:YES];
            [self addSubview:_uncheckBox];
            
            // Add check Box
            UIImageView *checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(275.5, 22.5, 0, 0)];
            _checkBox = checkBox;
            _checkBox.image = [UIImage imageNamed:@"checkBox.png"];
            [_checkBox setHidden:YES];
            [self addSubview:_checkBox];
        }
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(290, cellHeight/2.0 - 20.8/2.0, 20.5, 20.5)];
        _icon = icon;
        [self addSubview:icon];
    }
    return self;
}

- (void)setContactProfile:(QianLiAddressBookItem *)contact NeedIcon:(BOOL)needIcon
{
    _profileImageView.image = contact.thumbnail;
    _nameLabel.text = contact.name;
    _numberLabel.text = [NSString stringWithFormat:@"Mobile:%@",contact.tel];
    if (needIcon) {
        _icon.image = [UIImage imageNamed:@"contactsPhoneIcon.png"];
        _icon.alpha = 1.0;
        //        UILabel *qianLiLabel = [[UILabel alloc] initWithFrame:CGRectMake(285, cellHeight/2.0 - 20, 40, 40)];
        //        _qianLiLabel = qianLiLabel;
        //        _qianLiLabel.text = @"千里";
        //        _qianLiLabel.textColor = [UIColor colorWithRed:80/255.0 green:177/255.0 blue:182/255.0 alpha:1.0f];
        //        _qianLiLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f];
        //        [self addSubview:_qianLiLabel];
    }
    else{
        _icon.image = nil;
        _icon.alpha = 0.0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
