//
//  HandDrawingView.h
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface HandDrawingView : UIView

-(void)changePaintingMode;
- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing;


@end
