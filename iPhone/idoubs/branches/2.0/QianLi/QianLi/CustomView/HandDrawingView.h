//
//  HandDrawingView.h
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Global.h"

@protocol HandDrawingDelegate <NSObject>

@optional

- (void)handDrawingDidDraw;
@end

@interface HandDrawingView : UIView

@property(weak, nonatomic) id<HandDrawingDelegate>delegate;

- (void)changeToDrawMode;
- (void)changeToEraseMode;
- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing lineWidth:(CGFloat)width strokeColorIndex:(NSInteger)index touchEnd:(BOOL) touchEnd;
- (void)clearAll;
- (void)clearAllFromRemote;
- (void)revoke;
- (void)revokeFromRemoteParty;
- (UIImage*)screenshot;
- (BOOL)getDrawingMode;
- (void)changeDrawLineWidthTo:(CGFloat)lWidth;
- (void)changeDrawLineColorTo:(NSInteger)index;

@end
