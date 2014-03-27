//
//  HistoryMainCell.m
//  QianLi
//
//  Created by lutan on 8/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//
//  这个cell可以左右滑动
//  当左滑或者右滑超过触发距离时,会触发预约或者拨打电话的操作
//  当有用户预约时,这个cell的外观会改变: 往左偏移一定数值
//
//  Tips:
//  当滑动cell时,其实是滑动cell的contentView,所以应该将想要被滑动的内容(如名字,头像等)加入contentview中
//  当完成一个滑动后会自动调用cleanupBackview,其中默认会将所有的backview中的subview清除,因此需要自己写构造函数在所读取变量为空时,重新生成.并且在cleanupBackview函数中手动将其赋值为nil
//  当用户 滑动cell 时,会调用animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity函数,可以在里面对移动到某点会产生的行为进行操作
//  当用户 松手 时会调用resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity函数



#import "HistoryMainCell.h"
#import "QBAnimationGroup.h"
#import "QBAnimationItem.h"
#import "QBAnimationSequence.h"
#import "Global.h"

@interface HistoryMainCell (){
    BOOL animating;
    CGFloat offsetInAnimation;
}

@property (weak, nonatomic) QBAnimationSequence *leftRightSequence;

@property (weak, nonatomic) NSString *id;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *missedCallIcon;
@property (weak, nonatomic) IBOutlet UIImageView *line;

@property (nonatomic, assign) BOOL isRequesting; // 记录该条记录是否发出请求中
@property (nonatomic, assign) BOOL isCrossTriggerLengthLeft; // 记录图标是否进行过动画(是否拉过了距离)
@property (nonatomic, assign) BOOL isCrossTriggerLengthRight; // 记录图标是否进行过动画(是否拉过了距离)

@property (strong, nonatomic) UIImageView *requestIconImageView;
@property (strong, nonatomic) UIImageView *requestIconImageViewWhite;
@property (strong, nonatomic) UIImageView *requestLoading;
@property (strong, nonatomic) UIImageView *arrowLeft;
@property (strong, nonatomic) UILabel *phoneText;
@property (strong, nonatomic) UILabel *requestText;

@property (strong, nonatomic) UIImageView *phoneIconImageView;
@property (strong, nonatomic) UIImageView *phoneIconImageViewWhite;

@property (nonatomic, assign) BOOL isRequested; // 记录该条记录是否处在被预约的状态
@property (nonatomic, assign) BOOL isAnimated;

@end

@implementation HistoryMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addContentsToCell];
    }
    return self;
}

- (void)addContentsToCell
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _avatar = imageView;
    [self.contentView addSubview:_avatar];
    
    UILabel *labelName = [[UILabel alloc] init];
    labelName.font = [UIFont fontWithName:@"Arial-BoldMT" size:19.0f];
    _nameLabel = labelName;
    [self.contentView addSubview:_nameLabel];
    
    UILabel *timeName = [[UILabel alloc] init];
    _timeLabel = timeName;
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    if (IS_OS_7_OR_LATER) {
        _timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    [self.contentView addSubview:_timeLabel];
    _timeLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *contentName = [[UILabel alloc] init];
    _contentLabel = contentName;
    _contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
    _contentLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_contentLabel];
    
    UIImageView *missedCallIcon = [[UIImageView alloc] init];
    _missedCallIcon = missedCallIcon;
    _missedCallIcon.image = [UIImage imageNamed:@"missedCallIcon.png"];
    [self.contentView addSubview:_missedCallIcon];
    _missedCallIcon.hidden = YES;
    
    // Set seperator line
    //        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 79, 320, 1)];
    UIImageView *line = [[UIImageView alloc] init];
    _line = line;
    _line.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
    [self addSubview:_line];
    
    self.panElasticity = YES;
    self.panElasticityStartingPoint = 200;
    
    _line.frame = CGRectMake(0, 79, 320, 1);
    _avatar.frame = CGRectMake(12, 80/2.0-25, 50, 50);
    //_avatar.layer.cornerRadius = _avatar.frame.size.height / 2.0;
    _avatar.clipsToBounds = YES;
    _nameLabel.frame = CGRectMake(75, -1, 180, 50);
    CGFloat timeNameWidth = 100;
    CGFloat timeNameHeight = 40;
    _timeLabel.frame = CGRectMake(320 - timeNameWidth - 15, 2, timeNameWidth, timeNameHeight);
    _contentLabel.frame = CGRectMake(75, 80 - 40, 200, 36);
    _missedCallIcon.frame = CGRectMake(293, 43, 13, 13);
    
    // 手动设置self及其subview的frame, 否则background view无法正确显示
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), 80);
    self.contentView.frame = self.frame;
    self.backView.frame = self.frame;
    self.backgroundView.frame = self.frame;
    
    UIImageView *rightLineView = [[UIImageView alloc] initWithFrame:CGRectMake(320, 0, 1, 80)]; // 右边的分割线,用于和backgroundView进行视觉上的分割
    rightLineView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.contentView addSubview:rightLineView];
    
    UIImageView *leftLineView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, 0, 1, 80)]; // 左边的分割线,用于和backgroundView进行视觉上的分割
    leftLineView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    [self.contentView addSubview:leftLineView];

}

- (void)stopAllAnimation
{
    [_leftRightSequence stop];
    [self.contentView.layer removeAllAnimations]; //不停止的话会无法在animateContentView中对其正确地移动
    if (self.isAnimated) {
        offsetInAnimation = CGRectGetMinX(self.contentView.bounds) - CGRectGetMinX(self.contentView.frame);
    }
    self.isAnimated = NO;
}

- (UILabel *)phoneText
{
    if (!_phoneText) {
        _phoneText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.contentView.frame))];
        _phoneText.text = NSLocalizedString(@"QianliCall", nil);
        _phoneText.textColor = [UIColor whiteColor];
        _phoneText.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
        _phoneText.textAlignment = NSTextAlignmentLeft;
        _phoneText.backgroundColor = [UIColor clearColor];
        [self.backView addSubview:_phoneText];
    }
    return _phoneText;
}

- (UILabel *)requestText
{
    if (!_requestText) {
        _requestText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, CGRectGetHeight(self.contentView.frame))];
        _requestText.text = NSLocalizedString(@"Appointment", nil);//@"预约通话";
        _requestText.textColor = [UIColor whiteColor];
        _requestText.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
        _requestText.textAlignment = NSTextAlignmentRight;
        _requestText.backgroundColor = [UIColor clearColor];
        [self.backView addSubview:_requestText];
    }
    return _requestText;
}

- (UIImageView *)arrowLeftImageView
{
    if (!_arrowLeft) {
        _arrowLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, CGRectGetHeight(self.frame))];
        [_arrowLeft setImage:[UIImage imageNamed:@"arrowLeft.png"]];
        [_arrowLeft setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_arrowLeft];
    }
    return _arrowLeft;
}

- (UIImageView *)requestIconImageView
{
    if (!_requestIconImageView) {
        _requestIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, CGRectGetHeight(self.frame))];
        [_requestIconImageView setImage:[UIImage imageNamed:@"arrowRight.png"]];
        [_requestIconImageView setContentMode:UIViewContentModeCenter];
        _requestIconImageView.layer.anchorPoint = CGPointMake(1.0, 0.5); // 需要改变锚点,否则scale时会发送错位
        [self.backView addSubview:_requestIconImageView];
    }
    return _requestIconImageView;
}

- (UIImageView *)requestIconImageViewWhite
{
    if (!_requestIconImageViewWhite) {
        _requestIconImageViewWhite = [[UIImageView alloc] initWithFrame:self.requestIconImageView.bounds];
        [_requestIconImageViewWhite setImage:[UIImage imageNamed:@"requestTalkWhite.png"]];
        [_requestIconImageViewWhite setContentMode:UIViewContentModeCenter];
        [self.requestIconImageView addSubview:_requestIconImageViewWhite];
    }
    return _requestIconImageViewWhite;
}

- (UIImageView *)requestLoading
{
    if (!_requestLoading) {
        _requestLoading = [[UIImageView alloc] initWithFrame:self.requestIconImageView.bounds];
        [_requestLoading setImage:[UIImage imageNamed:@"requestLoading.png"]];
        [_requestLoading setContentMode:UIViewContentModeCenter];
        [self.requestIconImageView addSubview:_requestLoading];
    }
    return _requestLoading;
}

- (UIImageView*)phoneIconImageView {
    if (!_phoneIconImageView) {
        _phoneIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, 25, CGRectGetHeight(self.frame))];
        [_phoneIconImageView setImage:[UIImage imageNamed:@"arrowLeft.png"]];
        [_phoneIconImageView setContentMode:UIViewContentModeCenter];
        _phoneIconImageView.layer.anchorPoint = CGPointMake(0, 0.5);
        [self.backView addSubview:_phoneIconImageView];
    }
    return _phoneIconImageView;
}

- (UIImageView*)phoneIconImageViewWhite {
    if (!_phoneIconImageViewWhite) {
        _phoneIconImageViewWhite = [[UIImageView alloc] initWithFrame:self.phoneIconImageView.bounds];
        [_phoneIconImageViewWhite setImage:[UIImage imageNamed:@"phoneWhite.png"]];
        [_phoneIconImageViewWhite setContentMode:UIViewContentModeCenter];
        [self.phoneIconImageView addSubview:_phoneIconImageViewWhite];
    }
    return _phoneIconImageViewWhite;
}

- (void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    [self stopAllAnimation];
    if (self.isRequested == YES) {
//        point.x = point.x - kRequestOffset;
        point.x = point.x - offsetInAnimation;
        // 根据当前动画所进行的位置来拉动cell
        if (point.x > 0) {
            point.x = MIN(point.x, 10);
        }
    }
    if (self.isRequested) {
    }
    
    [super animateContentViewForPoint:point velocity:velocity];
    // 被请求状态下
    if (point.x > 0) {
        // set the request icon's frame to match the contentView
        [self.requestIconImageView setFrame:CGRectMake(CGRectGetMinX(self.contentView.frame)-CGRectGetWidth(self.requestIconImageView.frame)-10, CGRectGetMinY(self.requestIconImageView.frame), CGRectGetWidth(self.requestIconImageView.frame), CGRectGetHeight(self.requestIconImageView.frame))];
        [self.requestText setFrame:CGRectMake(CGRectGetMinX(self.contentView.frame)-CGRectGetWidth(self.requestText.frame)-45, CGRectGetMinY(self.requestText.frame), CGRectGetWidth(self.requestText.frame), CGRectGetHeight(self.requestText.frame))];
        self.backView.backgroundColor = [UIColor colorWithRed:255/255.0 green:222/255.0 blue:71/255.0 alpha:1.0f];
        
        if (point.x > kTriggerLength && self.isRequesting == NO)
        {
            // 变换backview背景并加入图标变化动画
            
            [self.requestIconImageViewWhite setAlpha:1];
            self.requestIconImageView.image = nil;
            if (self.isCrossTriggerLengthLeft == NO)
            {
                self.isCrossTriggerLengthLeft = YES;
                [UIView animateWithDuration:0.1f animations: ^{
                    self.requestIconImageView.transform = CGAffineTransformScale(self.requestIconImageView.transform, 1.2, 1.2);
                 } completion:^(BOOL finished){
                     [UIView animateWithDuration:0.05f animations:^{
                         self.requestIconImageView.transform = CGAffineTransformScale(self.requestIconImageView.transform, 1.0/1.2, 1.0/1.2);
                     }];
                 }];
            }
        } else if (point.x > kTriggerLength && self.isRequesting == YES) {
            // 解除request 状态

        } else if (point.x <= kTriggerLength ) {
            self.isCrossTriggerLengthLeft = NO;
            [self.requestIconImageViewWhite setAlpha:0];
            [self.requestIconImageView.layer removeAllAnimations];
//            self.backView.backgroundColor = self.backViewbackgroundColor;
            self.requestIconImageView.image = [UIImage imageNamed:@"arrowRight.png"];
        }

    }
    else if (point.x < 0) {
        
        self.backView.backgroundColor = [UIColor colorWithRed:98/255.0 green:217/255.0 blue:98/255.0 alpha:1.0];
        [self.phoneIconImageView setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame)+10, CGRectGetMinY(self.phoneIconImageView.frame), CGRectGetWidth(self.phoneIconImageView.frame), CGRectGetHeight(self.phoneIconImageView.frame))];
        [self.phoneText setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame)+45, CGRectGetMinY(self.phoneText.frame), CGRectGetWidth(self.phoneText.frame), CGRectGetHeight(self.phoneText.frame))];
        if (point.x < -kTriggerLength) {
            self.backView.backgroundColor = [UIColor colorWithRed:98/255.0 green:217/255.0 blue:98/255.0 alpha:1.0];
            self.phoneIconImageView.image = nil;
            [self.phoneIconImageViewWhite setAlpha:1];
            if (self.isCrossTriggerLengthRight == NO) {
                self.isCrossTriggerLengthRight = YES;
                [UIView animateWithDuration:0.1f animations: ^{
                    self.phoneIconImageView.transform = CGAffineTransformScale(self.phoneIconImageView.transform, 1.2, 1.2);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.05f animations:^{
                        self.phoneIconImageView.transform = CGAffineTransformScale(self.phoneIconImageView.transform, 1.0/1.2, 1.0/1.2);
                    }];
                }];
            }
        }
        else if (point.x >= -kTriggerLength) {
            self.isCrossTriggerLengthRight = NO;
            self.phoneIconImageView.image = [UIImage imageNamed:@"arrowLeft.png"];
//            self.backView.backgroundColor = self.backViewbackgroundColor;
            [self.phoneIconImageViewWhite setAlpha:0];
            [self.phoneIconImageView.layer removeAllAnimations];
        }
    }
}

- (void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    if (self.isRequested) {
        point.x = MIN(point.x, 15);// 放在前面, 否则会令contentview不回弹
    }
    
    // 必须放在前面 否则会先触发super的动画
    if (point.x > 0 && point.x > kTriggerLength)
    {
        self.shouldAnimateCellReset = NO;
    }
    
    [super resetCellFromPoint:point velocity:velocity];
    
    if (point.x > 0 && point.x <= kTriggerLength) {
        // 用户未拉动足够距离所以未超过触发距离
        // 需要将显示的icon与content view以动画的形式同步退回
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.requestIconImageView setFrame:CGRectMake(-CGRectGetWidth(self.requestIconImageView.frame)-10, CGRectGetMinY(self.requestIconImageView.frame), CGRectGetWidth(self.requestIconImageView.frame), CGRectGetHeight(self.requestIconImageView.frame))];
            [self.requestText setFrame:CGRectMake(CGRectGetMinX(self.contentView.bounds)-CGRectGetWidth(self.requestText.frame)-45, CGRectGetMinY(self.requestText.frame), CGRectGetWidth(self.requestText.frame), CGRectGetHeight(self.requestText.frame))];
        }];
    } else if (point.x > 0 && point.x > kTriggerLength) {
        // 记录下用户已发送请求,并根据这个在cell回退到正常位置时调出请求动画
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 35, 0);
            [self.requestIconImageView setFrame:CGRectMake(5, 0, 25, 80)];
            [self.requestText setFrame:CGRectMake(CGRectGetMinX(self.contentView.frame)-CGRectGetWidth(self.requestText.frame)-45, CGRectGetMinY(self.requestText.frame), CGRectGetWidth(self.requestText.frame), CGRectGetHeight(self.requestText.frame))];
        } completion:^(BOOL finished){
            // 开始发出请求 并将图标转动
            [self.requestIconImageViewWhite setAlpha:0];
            self.requestIconImageView.image = nil;
            self.userInteractionEnabled = NO;
            [self startSpin];
            [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(stopSpin) userInfo:nil repeats:NO];
            if ([self.historyMainCelldelegate respondsToSelector:@selector(sendRequest:)]) {
                [self.historyMainCelldelegate sendRequest:self];
            }
        }];

    } else if (point.x < 0) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.phoneIconImageView setFrame:CGRectMake(CGRectGetMaxX(self.frame)+10, CGRectGetMinY(self.phoneIconImageView.frame), CGRectGetWidth(self.phoneIconImageView.frame), CGRectGetHeight(self.phoneIconImageView.frame))];
            [self.phoneText setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame)+45, CGRectGetMinY(self.phoneText.frame), CGRectGetWidth(self.phoneText.frame), CGRectGetHeight(self.phoneText.frame))];
        } completion:^(BOOL finished) {
            if (point.x < -kTriggerLength) {
                if ([self.historyMainCelldelegate respondsToSelector:@selector(makeACall:)]) {
                    [self.historyMainCelldelegate makeACall:self];
                }
            }
        }];
        
//        if (point.x < -kTriggerLength) {
//            if ([self.historyMainCelldelegate respondsToSelector:@selector(makeACall:)]) {
//                [self.historyMainCelldelegate makeACall:self];
//            }
//        }
    }
    // 调用取消该预约的函数
    if (self.isRequested == YES) {
        if ([self.historyMainCelldelegate respondsToSelector:@selector(cancelRequest:)]) {
            [self.historyMainCelldelegate cancelRequest:self];
        }
        self.isRequested = NO;
    }
}

-(void)resetContentView {
    [UIView animateWithDuration:0.15f
                     animations:^{
                         self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         self.shouldAnimateCellReset = YES;
                         [self cleanupBackView];
                         self.userInteractionEnabled = YES;
                     }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self cleanupBackView];
}

// super类中会自动执行该函数,并且会将backview remove
// 所以必须要将添加到backview上的所有view手动赋值为nil
// 否则进行第二次拉动cell出现新的backview时,无法显示原先加入的view
- (void)cleanupBackView
{
    [super cleanupBackView];
    [_requestIconImageView removeFromSuperview];
    _requestIconImageView = nil;
    [_requestIconImageViewWhite removeFromSuperview];
    _requestIconImageViewWhite = nil;
    [_requestLoading removeFromSuperview];
    _requestLoading = nil;
    [_phoneIconImageView removeFromSuperview];
    _phoneIconImageView = nil;
    [_phoneIconImageViewWhite removeFromSuperview];
    _phoneIconImageViewWhite = nil;
    [_phoneText removeFromSuperview];
    _phoneText = nil;
    [_requestText removeFromSuperview];
    _requestText = nil;
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

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.requestLoading.transform = CGAffineTransformRotate(self.requestLoading.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void)startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void)stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
    self.shouldAnimateCellReset = YES;
    [self.requestLoading setAlpha:0];
    self.requestIconImageView.image = [UIImage imageNamed:@"requestOK.png"];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(resetContentView) userInfo:nil repeats:NO];
}

- (void)layoutSubviews
{
    // contentView在预约被激活后有个偏移的效果,默认的layoutSubviews会将其重置为contentview.bounds,所以需要在进行super layoutSubviews后将其变为重置前的frame
    CGRect frame = self.contentView.frame;
    [super layoutSubviews];
    self.contentView.frame = frame;
}


- (void)activateRequestStatus
{
    // 激活被请求通话的显示状态
    self.isRequested = YES;
    self.isAnimated = YES;
//    self.shouldAnimateCellReset = NO;
    // 将cell左移露出拨号界面, 诱使用户拨号
    
    if (self.isRequested == YES) {
//        self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset-10, 0);
        [self.phoneIconImageView setFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame) + 10 -kRequestOffset, CGRectGetMinY(self.phoneIconImageView.frame), CGRectGetWidth(self.phoneIconImageView.frame), CGRectGetHeight(self.phoneIconImageView.frame))];
        self.backView.backgroundColor = [UIColor colorWithRed:98/255.0 green:217/255.0 blue:98/255.0 alpha:1.0];
        // 加入前后抖动动画
        if (self.isAnimated) {
            CGFloat leftOffset = 10;
            QBAnimationItem *toLeft = [QBAnimationItem itemWithDuration:0.8f
                                                                  delay:0
                                                                options:UIViewAnimationOptionAllowUserInteraction
                                                             animations:^{
                                                                        self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset-leftOffset, 0);
                                                                        self.phoneIconImageView.frame = CGRectOffset(self.phoneIconImageView.frame, -leftOffset, 0);
                                                                    }];
            QBAnimationItem *toRightBounce = [QBAnimationItem itemWithDuration:0.2
                                                                         delay:0
                                                                       options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction
                                                                    animations:^{
                                                                        self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset + (leftOffset * 0.2), 0);
                                                                        [self.phoneIconImageView setFrame:CGRectOffset(self.phoneIconImageView.frame, leftOffset + (leftOffset * 0.2), 0)];
                                                                    }];
            QBAnimationItem *toRightBounce1 = [QBAnimationItem itemWithDuration:0.1
                                                                          delay:0
                                                                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction
                                                                     animations:^{
                                                                         self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset - (leftOffset * 0.1), 0);
                                                                         [self.phoneIconImageView setFrame:CGRectOffset(self.phoneIconImageView.frame, -leftOffset*0.2 - (leftOffset * 0.1), 0)];
                                                                     }];
            QBAnimationItem *toRightBounce2 = [QBAnimationItem itemWithDuration:0.05
                                                                          delay:0
                                                                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                                                                     animations:^{
                                                                         self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset, 0);
                                                                         [self.phoneIconImageView setFrame:CGRectOffset(self.phoneIconImageView.frame, (leftOffset * 0.1), 0)];
                                                                     }];
            QBAnimationItem *forDelay = [QBAnimationItem itemWithDuration:2.0
                                                                          delay:0
                                                                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                                                                     animations:^{
                                                                         self.contentView.frame = CGRectOffset(self.contentView.bounds, -kRequestOffset-0.001, 0);
                                                                     }]; // 不会产生任何动作,仅仅为了将其他动画序列延迟播放
            
            QBAnimationGroup *leftGroup = [QBAnimationGroup groupWithItem:toLeft];
            QBAnimationGroup *rightGroupBounce = [QBAnimationGroup groupWithItems:@[toRightBounce]];
            QBAnimationGroup *rightGroupBounce1 = [QBAnimationGroup groupWithItems:@[toRightBounce1]];
            QBAnimationGroup *rightGroupBounce2 = [QBAnimationGroup groupWithItems:@[toRightBounce2]];
            QBAnimationGroup *delayGroup = [QBAnimationGroup groupWithItem:forDelay];
            QBAnimationSequence *leftRightSequence = [[QBAnimationSequence alloc] initWithAnimationGroups:@[leftGroup, rightGroupBounce, rightGroupBounce1, rightGroupBounce2 ,delayGroup] repeat:YES];
            _leftRightSequence = leftRightSequence;
            [_leftRightSequence start];
        }
    }
}

@end
