//
//  HistoryMainCell.m
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryMainCell.h"

@interface HistoryMainCell (){
    
}

@property (weak, nonatomic) NSString *id;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIcon;
@property (weak, nonatomic) IBOutlet UIImageView *line;

@end

@implementation HistoryMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 50, 50)];
        _avatar = imageView;
        _avatar.layer.cornerRadius = _avatar.frame.size.height / 2.0;
        _avatar.clipsToBounds = YES;
        [self addSubview:_avatar];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(75, -1, 120, 50)];
        labelName.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0f];
        _nameLabel = labelName;
        [self addSubview:_nameLabel];
        
        CGFloat timeNameWidth = 100;
        CGFloat timeNameHeight = 40;
        UILabel *timeName = [[UILabel alloc] initWithFrame:CGRectMake(320 - timeNameWidth - 15, 2, timeNameWidth, timeNameHeight)];
        _timeLabel = timeName;
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self addSubview:_timeLabel];
        
        UILabel *contentName = [[UILabel alloc] initWithFrame:CGRectMake(75, 32, 200, 36)];
        _contentLabel = contentName;
        _contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
        _contentLabel.textColor = [UIColor grayColor];
        [self addSubview:_contentLabel];
        
        UIImageView *missedCallIcon = [[UIImageView alloc] initWithFrame:CGRectMake(293, 43, 13, 13)];
        _missedCallIcon = missedCallIcon;
        _missedCallIcon.image = [UIImage imageNamed:@"missedCallIcon.png"];
        [self addSubview:_missedCallIcon];
        _missedCallIcon.hidden = YES;
        
        // Set seperator line
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 320, 1)];
        _line = line;
        _line.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
        [self addSubview:_line];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHistoryMainCell:(NSString *)id avatar:(UIImage *)avatar Name:(NSString *)name Time:(NSString *)time Content:(NSString *)content
{
    _id = id;
    _timeLabel.text = time;
    _nameLabel.text = name;
    _contentLabel.text = content;
    _avatar.image = avatar;
}

- (void)isMissedCall:(BOOL)yesOrNo
{
    if (yesOrNo) {
        _missedCallIcon.hidden = NO;
        _contentLabel.textColor = [UIColor colorWithRed:222/255.0 green:32/255.0 blue:33/255.0 alpha:1.0f];
    }
}

@end
