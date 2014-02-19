//
//  SignUpViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpVerificationCodeViewController.h"
#import "QianLiAppDelegate.h"
#import "WaitingViewController.h"
#import "AddPartnerViewController.h"

// this is a view controller used for user signing up. It appear before user signs up
// and disappear after user signs up.

// the corresponding view is for entering phone number.

@interface SignUpViewController : UIViewController <UITextFieldDelegate>


@end

