//
//  DoodleView.h
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@protocol DoodleTapDelegate <NSObject>

-(void)didTipOnView;

@end

@interface DoodleView : UIView

@property(weak, nonatomic) id delegate;
@property(assign, nonatomic, readonly) BOOL isDrawing;
@property(strong, nonatomic) UIImage *image;
-(void)changePaintingMode;
- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing;
- (UIImage*)screenshot;
- (void)clearAll;
- (void)clearAllFromRemote;

@end
