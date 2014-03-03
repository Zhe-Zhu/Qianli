//
//  SignUpVerificationCodeViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureManager.h"
#import "WaitingViewController.h"

@interface SignUpVerificationCodeViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) NSString *number;
@property(nonatomic, strong) NSString *readableNumber; // 用于在无代码的UIAlert界面内显示

@end
