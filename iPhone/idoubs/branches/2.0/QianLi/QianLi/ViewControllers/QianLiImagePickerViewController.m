//
//  QianLiImagePickerViewController.m
//  QianLi
//
//  Created by LG on 12/13/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import "QianLiImagePickerViewController.h"

@interface QianLiImagePickerViewController ()

@end

@implementation QianLiImagePickerViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        else {
            
        }
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
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        return YES;
    }
    else {
        return NO;
    }
}

-(UIViewController *) childViewControllerForStatusBarHidden
{
    return nil;
}

@end
