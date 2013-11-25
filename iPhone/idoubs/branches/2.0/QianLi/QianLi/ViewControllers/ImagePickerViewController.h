//
//  ImagePickerViewController.h
//  QianLi
//
//  Created by lutan on 8/26/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetCell.h"
#import "UIImageExtras.h"

@protocol SelectImageDelegate <NSObject>

- (void)didFinishSelectingImage:(NSArray *)images;

@end

@interface ImagePickerViewController : UIViewController

@property(strong,nonatomic) ALAssetsGroup *assetsGroup;
@property(weak,nonatomic) id<SelectImageDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *pickerCollectionView;

@end


