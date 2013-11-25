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

@end

@implementation ContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, 43, 43)];
        _profileImageView = imageView;
        imageView.layer.cornerRadius = 21.5;
        imageView.clipsToBounds = YES;
        [self addSubview:_profileImageView];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 71, 43)];
        _nameLabel = labelName;
        [self addSubview:_nameLabel];
        
    }
    return self;
}

- (void)setContactProfile:(QianLiAddressBookItem *)contact NeedIcon:(BOOL)needIcon
{
    _profileImageView.image = contact.thumbnail;
    _nameLabel.text = contact.name;
    _numberLabel.text = [NSString stringWithFormat:@"Mobile:%@",contact.tel];
    if (needIcon) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(260, 0, 43, 43)];
        _icon = icon;
        [self addSubview:icon];
        _icon.image = [UIImage imageNamed:@"icon.png"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
