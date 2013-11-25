//
//  QianLiContactsItem.h
//  QianLi
//
//  Created by lutan on 9/28/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QianLiContactsItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) UIImage *thumbnail;
@property NSInteger sectionNumber;

@end
