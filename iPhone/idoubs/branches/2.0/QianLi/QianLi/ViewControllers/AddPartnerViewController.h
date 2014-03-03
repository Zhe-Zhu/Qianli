//
//  AddPartnerViewController.h
//  QianLi
//
//  Created by LG on 2/17/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "WaitingListUtils.h"
#import "UserDataAccessor.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AddPartnerViewController : UIViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@end
