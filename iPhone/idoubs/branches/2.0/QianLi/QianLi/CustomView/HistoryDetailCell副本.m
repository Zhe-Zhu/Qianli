//
//  HistoryDetailCell.m
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryDetailCell.h"

#define kCellTopHeight		 20.f
#define kCellBottomHeight	 20.f
#define kCellDateHeight		 20.f
#define kCellContentFontSize 17.f

#define kBalloonOutSideMargin 20.f
#define kBalloonInSideMargin 4.f
#define kContentMarginLeft 10.f
#define kContentMarginRight 10.f
#define kCellEditMargin		 20.f

@interface HistoryDetailCell ()
{
    
}

@property(nonatomic, weak) UILabel *contentLabel;
@property(nonatomic, weak) UIImageView *avatar;
@property(nonatomic, weak) UIImageView *sharedImage;
@property(nonatomic, weak) UIImageView *textBackImage;

@end

@implementation HistoryDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (self.frame.size.height- 46)/2.0 + 6, 46, 46)];
        _avatar = imageView;
        _avatar.layer.cornerRadius = 23;
        _avatar.clipsToBounds = YES;
        [self addSubview:_avatar];
        
        //        UIImageView *backImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"balloon_out.png"] stretchableImageWithLeftCapWidth: 21 topCapHeight: 14]];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"balloon_out.png"]];
        UIEdgeInsets insets = UIEdgeInsetsMake(12, 21, 18, 21);
        backgroundImageView.image = [backgroundImageView.image resizableImageWithCapInsets:insets];
        _textBackImage = backgroundImageView;
        [self addSubview:backgroundImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 0, 0)];
        label.backgroundColor = [UIColor clearColor];
        _contentLabel = label;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
		_contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (CGFloat)setHeigtofCellWithString:(NSString *)string constrainedWidth:(CGFloat)width
{
    if ([string isEqualToString:@""]) {
        return 0.0;
    }
    else{
		CGSize constraintSize;
		constraintSize.width = width;
		constraintSize.height = MAXFLOAT;
		CGSize contentSize = [string sizeWithFont:[UIFont fontWithName:@"Arial" size:kCellContentFontSize] constrainedToSize:constraintSize lineBreakMode: NSLineBreakByWordWrapping];
        if ((kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height) > 50) {
            return  kCellTopHeight + kCellBottomHeight + kCellDateHeight + contentSize.height;
        }
        else{
            return 50;
        }
    }
}

- (void)setString:(NSString *)string avatar:(UIImage *)avatarImage SharedImage:(UIImage *)sharedImage
 forTableView:(UITableView *)tableView
{
    self.contentLabel.text = string;
    CGSize constraintSize;
    constraintSize.width = tableView.frame.size.width - kBalloonOutSideMargin /* right */ - (kBalloonOutSideMargin * 4) /* left */;
    constraintSize.height = MAXFLOAT;
    CGSize contentSize = [self.contentLabel.text sizeWithFont:self.contentLabel.font constrainedToSize:constraintSize lineBreakMode: NSLineBreakByWordWrapping];
    contentSize.width += kContentMarginLeft + kContentMarginRight - 20;
    
    self.contentLabel.frame = CGRectMake(60 + kBalloonOutSideMargin + (tableView.editing ? + kCellEditMargin : 0.f),
                                         self.contentLabel.frame.origin.y,
                                         contentSize.width,
                                         contentSize.height);
    
    _textBackImage.frame = CGRectMake(self.contentLabel.frame.origin.x - kBalloonInSideMargin - 15,
                                      self.contentLabel.frame.origin.y - kBalloonInSideMargin + 1,
                                      self.contentLabel.frame.size.width + kBalloonInSideMargin + 30,
                                      self.contentLabel.frame.size.height + 2 * kBalloonInSideMargin);
    //set profile
    _avatar.image = avatarImage;
}

@end
