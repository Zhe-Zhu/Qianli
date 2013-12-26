//
//  DrawingViewController.h
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandDrawingView.h"

@interface DrawingViewController : UIViewController<HandDrawingDelegate>

@property (nonatomic, assign) BOOL isIncoming;;
@property(weak, nonatomic) HandDrawingView *drawingView;
- (void)cancelFromRemoteParty;

@end
