//
//  HistoryRecordsMainViewController.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryMainCell.h"
#import "HistroyRecordDetailsViewController.h"
#import "MainHistoryDataAccessor.h"
#import "MainHistoryEntry.h"
#import "ImagePickerViewController.h"
#import "AssetGroupPickerController.h"
#import "Utils.h"
#import <AudioToolbox/AudioToolbox.h>
#import "QianLiContactsAccessor.h"
#import "HistoryTransUtils.h"

// this class displays the history calls in a table view.

@interface HistoryRecordsMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, HistoryMainCellDelegate>

- (void)restoreHistory;
- (void)clearHistory;
@end
