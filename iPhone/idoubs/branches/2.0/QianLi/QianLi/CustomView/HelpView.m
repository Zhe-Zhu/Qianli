//
//  HelpView.m
//  QianLi
//
//  Created by LG on 1/4/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "HelpView.h"

#define PageWidth 340

@interface HelpView ()
{
    BOOL didShowGoonText;
    BOOL didShowReleaseText;
}

@property(weak, nonatomic) UIScrollView *scrollView;
@property(weak, nonatomic) UIImageView *imageView;
@property(weak, nonatomic) UIImageView *fingerView;
@end

@implementation HelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect scrollViewFrame;
        scrollViewFrame = CGRectMake(0, 0, PageWidth, [UIScreen mainScreen].bounds.size.height);
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        _scrollView = scrollView;
        _scrollView.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        //add button
        UIImage *cancelImage = [UIImage imageNamed:@"help_quit.png"];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:cancelImage forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(286, 15, cancelImage.size.width, cancelImage.size.height);
        [self addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        
        //add finger
        UIImage *fingerImage = [UIImage imageNamed:@"help_1_drag_right.png"];
        UIImageView *fingerView = [[UIImageView alloc] initWithImage:fingerImage];
        fingerView.frame = CGRectMake(27, 319, fingerImage.size.width, fingerImage.size.height);
        [self addSubview:fingerView];
        _fingerView = fingerView;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveFinger:) userInfo:nil repeats:NO];
        
        didShowGoonText = NO;
        didShowReleaseText = NO;
        //
        [self setFirstView];
    }
    return self;
}

- (void)setFirstView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_1_background_words.png"]];
    _imageView = imageView;
    imageView.frame = CGRectMake(0, 0, 320, self.frame.size.height);
    [_scrollView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    
    static NSString *CellIdentifier = @"HelpHistoryMainCell";
    HistoryMainCell* historyCell = [[HistoryMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    historyCell.historyMainCelldelegate = self;
    historyCell.delegate = self;
    UIImage *avatar = [UIImage imageNamed:@"arwen_avatar.png"];
    NSString *name = @"Arwen Undomiel";
    
    NSDate *date = [NSDate date];
    [historyCell setHistoryMainCell:@"lg" avatar:avatar Name:name Time:[Utils readableTimeFromSecondsSince1970LikeWeixin:[date timeIntervalSince1970]] Content:@"拨出千里电话"];
    historyCell.frame = CGRectMake(0, 223, historyCell.frame.size.width, historyCell.frame.size.height);
    historyCell.shouldAnimateCellReset = YES;
    [imageView addSubview:historyCell];
    //[historyCell activateRequestStatus];
}

#pragma mark --RMSwipeTableViewDelegate--
- (void)swipeTableViewCellDidStartSwiping:(RMSwipeTableViewCell*)swipeTableViewCell
{
    [_fingerView removeFromSuperview];
}

- (void)swipeTableViewCell:(RMSwipeTableViewCell*)swipeTableViewCell didSwipeToPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    NSLog(@"x:%f", point.x);
    if (!didShowGoonText && point.x > 70) {
        didShowGoonText = YES;
        _imageView.image = [UIImage imageNamed:@"help_1_dragging_background_words.png"];
    }
    else if (!didShowReleaseText &&  point.x > 130){
        didShowReleaseText = YES;
        _imageView.image = [UIImage imageNamed:@"help_1_draged_background_words.png"];
    }
}

-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell*)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity
{
    didShowGoonText = NO;
    didShowReleaseText = NO;
    _imageView.image = [UIImage imageNamed:@"help_1_done_background_words.png"];
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(changeBackground) userInfo:nil repeats:NO];
}

- (void)swipeTableViewCellDidResetState:(RMSwipeTableViewCell*)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity
{
//    didShowGoonText = NO;
//    didShowReleaseText = NO;
//    _imageView.image = [UIImage imageNamed:@"help_1_done_background_words.png"];
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeBackground) userInfo:nil repeats:NO];
}

- (void)changeBackground
{
    _imageView.image = [UIImage imageNamed:@"help_1_background_words.png"];
}

- (void)moveFinger:(NSTimer *)timer
{
    CGPoint center = _fingerView.center;
    [UIView animateWithDuration:1.0 animations:^{
        _fingerView.center = CGPointMake(center.x + 160, center.y);
        _fingerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _fingerView.center = center;
        _fingerView.alpha = 1.0;
        if (_fingerView) {
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveFinger:) userInfo:nil repeats:NO];
        }
    }];
}

- (void)quit
{
    [self removeFromSuperview];
}

@end
