//
//  HistroyRecordDetailsViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryDetailCell.h"
#import "QianLiAudioCallViewController.h"
#import "QianLiTableMenuBarItem.h"
#import "QianLiTableMenuBar.h"
#import "MainHistoryDataAccessor.h"
#import "Utils.h"

// this class displays the history events associated with a history call.

@interface HistroyRecordDetailsViewController : UIViewController <QianLiUIMenuBarDelegate>
// the phone number of remote one associated with selected history call.
@property(nonatomic, strong)NSString * remotePartyPhoneNumber;
// indicate whether there is an apointment
@property(nonatomic,assign)BOOL hasAnAppointment;

- (void)loadDetailHistory;
- (void)clearDetailHistory;
//- (void)displayHistoryWithEntryNumber;
@end
