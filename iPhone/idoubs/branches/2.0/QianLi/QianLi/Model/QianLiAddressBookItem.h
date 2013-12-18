//
//  MainViewController.h
//  TKContactsMultiPicker
//
//  Created by tan lu on 13. 8. 06..
//  Copyright (c) 2013 lutan Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QianLiContactsItem.h"

@interface QianLiAddressBookItem : QianLiContactsItem

@property BOOL rowSelected;
@property (nonatomic, strong) NSMutableArray *telAarry;

@end