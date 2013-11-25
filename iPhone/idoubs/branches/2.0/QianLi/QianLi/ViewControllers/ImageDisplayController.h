//
//  ImageDisplayController.h
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoodleView.h"
#import "DoodleBackView.h"
#import "AssetGroupPickerController.h"
#import "PictureManager.h"
#import "MainHistoryDataAccessor.h"
#import "Global.h"
#import "CameraViewController.h"

@interface ImageDisplayController : UIViewController <UIScrollViewDelegate, SelectImageDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, DoodleTapDelegate>

@property(strong, nonatomic) NSMutableArray *images;
@property(strong, nonatomic) NSMutableArray *indexs;
@property(nonatomic) NSInteger totalNumber;
@property (weak, nonatomic) DoodleView *doodleView;
@property(nonatomic) BOOL isIncoming;

- (void)displayImages;
- (void)scrollTO:(CGFloat)xoffset;
- (void)doodleWithImageIndex:(NSInteger)index;
- (void)cancelFromRemoteyParty;
- (void)cancelDoodleFromRemoteyParty;
- (void)displaySelectingState;
- (void)showLongPressIndicator:(CGPoint) locationRatio;

@end
