//
//  NotificationHeader.m
//  QianLi
//
//  Created by Chen Xiangwen on 27/3/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "NotificationHeader.h"
#import "Global.h"

@interface NotificationHeader()
{
    UIImageView * _shownIconView;
    UILabel * _shownLabel;
}
@property(nonatomic, strong) UILabel * shownLabel;
@property(nonatomic, strong) UIImageView * shownIconView;


@end

@implementation NotificationHeader

@synthesize shownIconView = _shownIconView;
@synthesize shownLabel = _shownLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)dealloc
{
    [_shownLabel removeFromSuperview];
    [_shownIconView removeFromSuperview];
    _shownIconView = nil;
    _shownLabel = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
+ (NotificationHeader *)presentNotificationHeader:(UIView *)inView inPosition:(CGPoint)position withIcon:(UIImage *)icon andText:(NSString *)text
{
    // set the front used in the notification header;
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15];
    // the default label.
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 200, 0)];
    // setting of the label to enable adjusting the label frame based on the text.
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    
    //calculate the needed size based on the text.
    CGSize size = CGSizeMake(200, MAXFLOAT);
    CGSize  actualsize;
    if (IS_OS_7_OR_LATER) {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
        actualsize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    }
    else
    {
        actualsize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    }
    // adjust the label frame
    label.frame = CGRectMake(0, 0, actualsize.width, actualsize.height);
    label.text = text;

    // create the notification header
    CGFloat height = actualsize.height > icon.size.height ? actualsize.height : icon.size.height;
    
    // 固定height
    height = 44;
    
    NotificationHeader * header = [[NotificationHeader alloc] initWithFrame:CGRectMake(position.x,position.y , 320, height)];
    
    header.shownIconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, height/2.0-icon.size.height/2.0, icon.size.width, icon.size.height)];
    header.shownIconView.image = icon;
    header.shownLabel = label;
    
    [header addSubview:header.shownIconView];
    [header addSubview:header.shownLabel];
    header.shownLabel.center = CGPointMake(header.frame.size.width / 2, header.frame.size.height /2);
    
    // setting of the notification header
    header.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    header.clipsToBounds = YES;
    
    //do animation to present the notification header.
    CGRect beginFrame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.size.width, 0);
    CGRect originalFrame = header.frame;
    header.frame = beginFrame;
    [inView addSubview:header];
    
    [UIView animateWithDuration:0.5 animations:^{
        header.frame = originalFrame;
    }];
    return header;
}

+ (void)dismissNotificationHeader:(NotificationHeader *)header
{
    CGRect afterFrame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.size.width, 0);
    
    [UIView animateWithDuration:0.5
        animations:^{ header.frame = afterFrame; }
        completion:^(BOOL finished){
            [header removeFromSuperview];
        }
    ];
}

@end
