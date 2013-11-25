//
//  QianLiContactsViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "QianLiAddressBookItem.h"
#import "ContactTableViewCell.h"
#import "InviteFriendsViewController.h"
#import <RestKit/RestKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreData/CoreData.h>
#import "Reachability.h"
#import "QianLiAudioCallViewController.h"
#import "Utils.h"
#import "QianLiContactsAccessor.h"
#import "UINavigationControllerPortraitViewController.h"
#import "QianLiContactsItem.h"
#import "UserDataTransUtils.h"
#import "APNsTransUtils.h"
#import "UserDataAccessor.h"
#import "Global.h"

//this class is for managing QianLi contacts, each time the view is active  (on top of the view stack).
//the app creates a secondary thread and sends a contact updating request to the server in the thread,
//then updates the UI when receiving the response in main thread.

@interface QianLiContactsViewController : UIViewController<NSURLConnectionDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

// 从后台重新启动时, 用于重新读取用户的通讯录, 因为进入后台时, 需将原先存的号码释放
- (void)restoreContacts;

// 进入后台时, 将所存号码释放
- (void)clearContacts;

@end
