//
//  HelpViewController.m
//  QianLi
//
//  Created by lutan on 9/28/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HelpViewController.h"
#import "Global.h"

#define  pageWidth 320

@interface HelpViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *startButton;

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // a page is the width of the scroll view
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat iPhone5Offset = 0;
    if (abs(screenHeight-568)<=0.1) {
        iPhone5Offset = 14;
    }
    
    self.scrollView = [[UIScrollView alloc]init];
    if (IS_OS_7_OR_LATER) {
        self.scrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 117/2.0);
    }
    else {
        if (IS_IPHONE5) {
            self.scrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 117/2.0 - 44);
        }
        else{
            self.scrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 117/2.0);
        }
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(pageWidth * 4, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1.0f];
    [self.view addSubview:self.scrollView];
    
    if (IS_OS_7_OR_LATER) {
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenWidth/2.0-20, CGRectGetMaxY(self.scrollView.frame) - 20, 40, 20)];
    }
    else{
        if (IS_IPHONE5) {
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenWidth/2.0-20, CGRectGetMaxY(self.scrollView.frame) - 20, 40, 20)];
        }
        else{
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenWidth/2.0-20, CGRectGetMaxY(self.scrollView.frame) - 15, 40, 20)];
        }
    }
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self.view addSubview:self.pageControl];
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    
    // 加入[开始使用]按钮
    CGFloat startButtonWidth = 374/2.0;
    CGFloat startButtonHeight = 85/2.0;
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2.0 - startButtonWidth/2.0, screenHeight/2.0 + CGRectGetMaxY(self.scrollView.frame)/2.0 - startButtonHeight/2.0, startButtonWidth, startButtonHeight)];
    [self.startButton setImage:[UIImage imageNamed:@"helpButton.png"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, startButtonWidth, startButtonHeight)];
    startLabel.text = NSLocalizedString(@"beginToUse", nil);
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f];
    startLabel.textColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    startLabel.backgroundColor = [UIColor clearColor];
    [self.startButton addSubview:startLabel];
    
    UILabel *startLabelShadow = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, startButtonWidth, startButtonHeight)];
    startLabelShadow.text = NSLocalizedString(@"beginToUse", nil);
    startLabelShadow.textAlignment = NSTextAlignmentCenter;
    startLabelShadow.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:14.0f];
    startLabelShadow.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    startLabelShadow.backgroundColor = [UIColor clearColor];
    [self.startButton insertSubview:startLabelShadow belowSubview:startLabel];
    
    // 加入分割scrollview和底层view的分割线
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), pageWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    
    for (int i = 0; i < 4; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * pageWidth, 0, pageWidth , 295.5)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"helpImage%d.png", i+1]];
        [self.scrollView addSubview:imageView];
        
        // 加入文案标题栏
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * pageWidth, CGRectGetHeight(imageView.frame) + 4 + iPhone5Offset, pageWidth, 40)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:18.0f];
        [self.scrollView addSubview:titleLabel];
        
        // 加入文案副标题栏
        UILabel *quoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * pageWidth, CGRectGetMaxY(titleLabel.frame) - 6 + iPhone5Offset, pageWidth, 20)];
        quoteLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
        quoteLabel.font = [UIFont fontWithName:@"STHeitiSC-Light" size:11.0f];
        quoteLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:quoteLabel];
        
        // 加入文案描述栏
        UITextView *descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(i * pageWidth + 25, CGRectGetMaxY(titleLabel.frame) + iPhone5Offset*2, pageWidth - 50, 60)];
        descriptionText.textAlignment = NSTextAlignmentCenter;
        descriptionText.textColor = [UIColor colorWithRed:119/255. green:119/255.0 blue:119/255.0 alpha:1.0];
        descriptionText.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:13.0f];
        [self.scrollView addSubview: descriptionText];
        
        switch (i+1) {
            case 1:
                titleLabel.text = NSLocalizedString(@"helpViewOneTitle", nil);
                quoteLabel.text = @"";
                descriptionText.text = NSLocalizedString(@"helpViewOneDescription", nil);
                break;
            case 2:
                titleLabel.text = NSLocalizedString(@"helpViewTwoTitle", nil);
                quoteLabel.text = NSLocalizedString(@"helpViewTwoQuote", nil);
                descriptionText.frame = CGRectMake(i * pageWidth + 25, CGRectGetMaxY(titleLabel.frame)+12+iPhone5Offset*2, pageWidth - 50, 60);
                descriptionText.text = NSLocalizedString(@"helpViewTwoDescription", nil);
                break;
            case 3:
                titleLabel.text = NSLocalizedString(@"helpViewThreeTitle", nil);
                quoteLabel.text = NSLocalizedString(@"helpViewThreeQuote", nil);
                descriptionText.frame = CGRectMake(i * pageWidth + 25, CGRectGetMaxY(titleLabel.frame)+12+iPhone5Offset*2, pageWidth - 50, 60);
                descriptionText.text = NSLocalizedString(@"helpViewThreeDescription", nil);
                break;
            case 4:
                titleLabel.text = NSLocalizedString(@"helpViewFourTitle", nil);
                quoteLabel.text = @"";
                descriptionText.text = NSLocalizedString(@"helpViewFourDescription", nil);
                break;
            default:
                break;
        }
    }
    [self.view bringSubviewToFront:self.pageControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)startButtonPressed
{
    // 返回到注册界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *signUpEditProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterNavigationController"];
    [[UIApplication sharedApplication] delegate].window.rootViewController = signUpEditProfileViewController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"noHelp"];
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

@end
