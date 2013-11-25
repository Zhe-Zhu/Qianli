//
//  AssetGroupPickerController.h
//  QianLi
//
//  Created by lutan on 8/26/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImagePickerViewController.h"
#import "ImageDisplayController.h"

@interface AssetGroupPickerController : UIViewController

@property(weak,nonatomic) id<SelectImageDelegate> delegate;

@end


