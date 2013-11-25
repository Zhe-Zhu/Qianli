//
//  InviteFriendsViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "QianLiAddressBookItem.h"
#import <MessageUI/MessageUI.h>

// the inviting friends view
// you can invites friends through email or sms in this view.

@interface InviteFriendsViewController : UIViewController<MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) NSMutableArray *contacts;

- (void)clearAddressItems;
-(void)getAddressBookPermission;
@end
