//
//  AboutQianLiViewController.m
//  QianLi
//
//  Created by Tomoya on 13-11-20.
//  Copyright (c) 2013年 Ash Studio. All rights reserved.
//

#import "AboutQianLiViewController.h"
#import "Global.h"
#import "Utils.h"

@interface AboutQianLiViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionNumber;

@end

@implementation AboutQianLiViewController

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
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    _labelVersion.text = NSLocalizedString(@"version", nil);
    _labelVersionNumber.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (!IS_OS_7_OR_LATER) {
        [Utils changeNavigationBarButtonLookingForiOS6];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
