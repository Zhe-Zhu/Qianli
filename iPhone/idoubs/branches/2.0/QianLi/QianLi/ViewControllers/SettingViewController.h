//
//  SettingViewController.h
//  QianLi
//
//  Created by Tomoya on 13-8-16.
//  Copyright (c) 2013年 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WaitingListUtils.h"
#import <StoreKit/StoreKit.h>

@interface SettingViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, SKStoreProductViewControllerDelegate>

- (void)clearImages;
- (void)restoreImages;

- (void)newReplies:(int)count;

@end
