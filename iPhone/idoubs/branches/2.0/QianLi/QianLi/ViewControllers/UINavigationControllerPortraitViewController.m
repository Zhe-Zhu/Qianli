//
//  UINavigationControllerPortraitViewController.m
//  QianLi
//
//  Created by lutan on 9/23/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "UINavigationControllerPortraitViewController.h"

@interface UINavigationControllerPortraitViewController ()

@end

@implementation UINavigationControllerPortraitViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
