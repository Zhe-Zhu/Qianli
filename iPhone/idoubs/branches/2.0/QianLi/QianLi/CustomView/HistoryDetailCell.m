//
//  HistoryDetailCell.m
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryDetailCell.h"
#import "Global.h"

@interface HistoryDetailCell ()
{
    UIImageView __weak *_lineView;
}

@property(nonatomic, weak) UILabel *contentLabel;
@property(nonatomic, weak) UILabel *timeLabel;
@property(nonatomic, weak) UILabel *footnoteLabel;
@property(nonatomic, weak) UIImageView *indicatorSymbol;

// 如果有照片
@property(nonatomic, strong) NSMutableArray *imageArray;
@property(nonatomic, weak) UILabel *imageFootnote;

@property(nonatomic, weak) UIImageView *avatar;
@property(nonatomic, weak) UIImageView *sharedImage;
@property(nonatomic, weak) UIImageView *textBackImage;

// 组织化地显示图片

@end

@implementation HistoryDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (self.frame.size.height- 46)/2.0 + 6, 46, 46)];
//        _avatar = imageView;
//        _avatar.layer.cornerRadius = 23;
//        _avatar.clipsToBounds = YES;
//        [self addSubview:_avatar];
//        
//        //        UIImageView *backImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"balloon_out.png"] stretchableImageWithLeftCapWidth: 21 topCapHeight: 14]];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 0, 0)];
//        label.backgroundColor = [UIColor clearColor];
//        _contentLabel = label;
//        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
//		_contentLabel.numberOfLines = 0;
//        [self addSubview:_contentLabel];
        
        // 加入label和指示符号
        UILabel *contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 7.5, 180, 19)];
        contentlabel.backgroundColor = [UIColor clearColor];
        contentlabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentlabel.numberOfLines = 1;
        contentlabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16.0f];
        contentlabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel = contentlabel;
        [self.contentView addSubview:_contentLabel];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) - 60-10, 7, 60, 18)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.numberOfLines = 1;
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor colorWithRed:121/255.0 green:162/255.0 blue:210/255.0 alpha:1.0f];
        timeLabel.font =[UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f];
        _timeLabel = timeLabel;
        [self.contentView addSubview:_timeLabel];
        
        UILabel *footnoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_contentLabel.frame)+3, 27, 180, 20)];
        footnoteLabel.backgroundColor = [UIColor clearColor];
        footnoteLabel.textColor = tertiaryColor;
        footnoteLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:11.0f];
        footnoteLabel.textAlignment = NSTextAlignmentLeft;
        
        _footnoteLabel = footnoteLabel;
        [self.contentView addSubview:_footnoteLabel];
        
        UIImageView *indicatorSymbol = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 20, 20)];
        _indicatorSymbol = indicatorSymbol;
        [self.contentView addSubview:_indicatorSymbol];
        
        // 默认没有照片传递
        _imageArray = [[NSMutableArray alloc] init];
        _imageFootnote = Nil;
    }
    return self;
}

- (void)layoutSubviews
{
    // 加入分割线
    [_lineView removeFromSuperview];
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds)-1, [[UIScreen mainScreen] currentMode].size.width, 1)];
    _lineView = line;
    _lineView.backgroundColor = [UIColor colorWithRed:219/255.0 green:210/255.0 blue:210/255.0 alpha:1.0f];
    [self.contentView addSubview:_lineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)setHeightofCellWithString:(NSString *)string constrainedWidth:(CGFloat)width
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

+ (CGFloat)setHeightofCellWithPicturesCount:(NSInteger)picturesCount
{
    if (picturesCount <= 2) {
        return 160;
    }
    else {
        int row = (picturesCount-  1) / 3 + 1;
        return 110*row;
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

- (void)setCallRecord:(NSUInteger)callRecordType timeLabel:(NSString *)timeLabel footnote:(NSString *)footnote
{
    // call record type
    // 1: 呼出通话
    // 2: 呼入通话
    // 3: 未接来电
    // 4: 通话请求
    _timeLabel.text = timeLabel;
    _footnoteLabel.text = footnote;
    if (callRecordType == 1) {
        [self callRecordCallout];
    } else if (callRecordType == 2) {
        [self callRecordIncomingCall];
    } else if (callRecordType == 3) {
        [self callRecordMissedCall];
    } else if (callRecordType == 4) {
        [self callRecordCallRequest];
    }
    self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 48);
}

- (void)setCallRecord:(NSUInteger)callRecordType timeLabel:(NSString *)timeLabel footnote:(NSString *)footnote images:(NSArray *)imageArray
{
    // call record type
    // 这里目前应该只可能有两种type(未来有可能会让用户在未接来电也可能传输图片)
    // 1: 呼出通话
    // 2: 呼入通话
    _timeLabel.text = timeLabel;
    _footnoteLabel.text = footnote;
    if (callRecordType == 1) {
        [self callRecordCallout];
    } else if (callRecordType == 2) {
        [self callRecordIncomingCall];
    }
    
    // 重新计算cell高度
    // 图片大小为40*40, 每行最多放6张图片
    CGFloat insetVertical = 5;
    CGFloat insetHorizontal = 5;
    CGFloat imageFootNoteHeight = 25;
    CGFloat imageWidth = HistoryImageSize;
    CGFloat imageHeight = imageWidth;
    int imageCount = [imageArray count];
    int row = (imageCount-1)/6 + 1;
    CGFloat picturesHeight = imageWidth * row + insetVertical * (row - 1);
    if (imageCount != 0) {
        self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 48+picturesHeight+imageFootNoteHeight);
    } else {
        self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 48);
    }
    
    // 加入图片
    // 清理所有之前添加的图片
    for (UIImageView *view in _imageArray) {
        [view removeFromSuperview];
    }
    
    [_imageArray removeAllObjects];
    for (int i=0; i<imageCount; i++) {
        UIImage *picture = [imageArray objectAtIndex:i];
        CGFloat x = (i%6)*imageWidth + (i%6)*insetHorizontal + CGRectGetMinX(_contentLabel.frame);
        CGFloat y = (i/6)*(imageHeight+insetVertical) + 48;
        UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imageWidth, imageHeight)];
        pictureView.image = picture;
        [_imageArray addObject:pictureView];
        [self.contentView addSubview:pictureView];
    }
    
    // 加入照片脚注
    NSString *imageFootnoteString = [NSString stringWithFormat:NSLocalizedString(@"photoCount", nil), imageCount];
    [_imageFootnote removeFromSuperview];
    UILabel *imageFootnoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_contentLabel.frame)+4, picturesHeight + 48, 80, 20)];
    imageFootnoteLabel.numberOfLines = 1;
    imageFootnoteLabel.backgroundColor = [UIColor clearColor];
    imageFootnoteLabel.textColor = tertiaryColor;
    imageFootnoteLabel.text = imageFootnoteString;
    imageFootnoteLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:10.0f];
    imageFootnoteLabel.textAlignment = NSTextAlignmentLeft;
    _imageFootnote = imageFootnoteLabel;
    [self.contentView addSubview:_imageFootnote];
}

- (void)callRecordCallout
{
    _contentLabel.text = NSLocalizedString(@"call", nil);
    _contentLabel.textColor = tertiaryColor;
    _indicatorSymbol.image = [UIImage imageNamed:@"indicatorSymbolCallout.png"];
}

- (void)callRecordIncomingCall
{
    _contentLabel.text = NSLocalizedString(@"call", nil);
    _contentLabel.textColor = tertiaryColor;
    _indicatorSymbol.image = [UIImage imageNamed:@"indicatorSymbolCallin.png"];
}

- (void)callRecordMissedCall
{
    _contentLabel.text = NSLocalizedString(@"call", nil);
    _contentLabel.textColor = primaryColor;
    _indicatorSymbol.image = [UIImage imageNamed:@"indicatorSymbolMissedCall.png"];
}

- (void)callRecordCallRequest
{
    _contentLabel.text = NSLocalizedString(@"request", nil);
    _contentLabel.textColor = secondaryColor;
    _indicatorSymbol.image = [UIImage imageNamed:@"indicatorSymbolCallRequest.png"];
}

- (void)setCallRecord:(NSNumber *)callRecordType avatarMyFriend:(UIImage *)avatarMyFriend avatarMyself:(UIImage *)avatarMyself
{
    // call record type
    // 1: 朋友打给我, 我接了
    // 2: 我打给朋友, 朋友接了
    // 3: 朋友打给我, 我没接, 未接来电
    // 4: 我打给朋友, 朋友没接
    
    // 清理所有之前添加的图片
    for (UIView *subview in [self.contentView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    UIImageView *leftAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(60, 30-23, 46, 46)];
    leftAvatar.layer.cornerRadius = 23;
    leftAvatar.clipsToBounds = YES;
    leftAvatar.image = avatarMyFriend;
    [self.contentView addSubview:leftAvatar];
    
    UIImageView *rightAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(220, 7, 46, 46)];
    rightAvatar.layer.cornerRadius = 23;
    rightAvatar.clipsToBounds = YES;
    rightAvatar.image = avatarMyself;
    [self.contentView addSubview:rightAvatar];
    
    UIImageView *callIcon = [[UIImageView alloc] initWithFrame:CGRectMake(160-15, 15, 30, 30)];
    [self.contentView addSubview:callIcon];
    
    if ([callRecordType integerValue] == 1) {
        callIcon.image = [UIImage imageNamed:@"phoneCall.png"];
    }
    else if ([callRecordType integerValue] == 2) {
        callIcon.image = [UIImage imageNamed:@"phoneCallReverse.png"];
    }
    else if ([callRecordType integerValue] == 3) {
        rightAvatar.image = [self toGrayscale:rightAvatar.image];
        callIcon.image = [UIImage imageNamed:@"phoneCall.png"];
    }
    else if ([callRecordType integerValue] == 4) {
        leftAvatar.image = [self toGrayscale:leftAvatar.image];
        callIcon.image = [UIImage imageNamed:@"phoneCall.png"];
    }
}

- (void)showPictures:(NSArray *)pictures
{
    // 清理所有之前添加的图片
    for (UIView *subview in [self.contentView subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    int pictureWidth;
    CGFloat offset = 6;
    // 根据图片数目计算cell的高度,图片的大小,需要多少行多少列呈现
    // 分两种情况, 如果图片只有两张,则用大图展示,只用一列
    // 否则多列展示, 固定每行3列
    int count = [pictures count];
    if (count <= 2) {
        pictureWidth = 151;
    }
    else {
        pictureWidth = 99;
    }
    CGFloat heightOffset = offset + pictureWidth;
    
    for (int i=0; i<count; i++) {
        UIImage *picture = [pictures objectAtIndex:i];
        CGFloat x = (i%3)*pictureWidth + (i%3+1)*offset;
        int row = i/3;
        CGFloat y = heightOffset*row;
        UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, pictureWidth, pictureWidth)];
        pictureView.image = picture;
        [self.contentView addSubview:pictureView];
    }
}

- (UIImage *) toGrayscale:(UIImage *)inputImage
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width * inputImage.scale, inputImage.size.height * inputImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint8_t gray = (uint8_t) ((30 * rgbaPixel[RED] + 59 * rgbaPixel[GREEN] + 11 * rgbaPixel[BLUE]) / 100);
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:inputImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
