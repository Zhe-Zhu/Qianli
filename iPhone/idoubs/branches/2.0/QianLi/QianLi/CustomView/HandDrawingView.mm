//
//  HandDrawingView.m
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HandDrawingView.h"
#import "SipStackUtils.h"

@interface HandDrawingView (){
    UIBezierPath *_path;
    UIBezierPath *_remotePath;
    NSMutableArray *_pathPoints;
    
    UIImage *_pathFormedImage;
    BOOL firstTouch;
    BOOL firstTime;
    BOOL isDrawing;
    BOOL fromRemoteParty;
    BOOL remoteDrawing;
    BOOL isClearAll;
    NSInteger drawPointsNumber;
    
    CGPoint previousPoint;
    CGPoint thirdLastPoint;
}

@property(strong, nonatomic) UIColor *strokeColor;
@property(strong, nonatomic) NSString *pointsMessage;
@property(strong, nonatomic) UIImage *pathFormedImage;

@end

@implementation HandDrawingView

@synthesize pathFormedImage = _pathFormedImage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setMultipleTouchEnabled:NO];
        _path = [UIBezierPath bezierPath];
        _remotePath = [UIBezierPath bezierPath];
        [_path setLineWidth:2.0];
        [_remotePath setLineWidth:2.0];
        _path.lineCapStyle = kCGLineCapRound;
        _remotePath.lineCapStyle = kCGLineCapRound;
        //_pathsArray = [[NSMutableArray alloc] initWithCapacity:1];
        firstTime = YES;
        isDrawing = YES;
        fromRemoteParty = NO;
        isClearAll = NO;
        _pathPoints = [[NSMutableArray alloc] initWithCapacity:2];
        _strokeColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setMultipleTouchEnabled:NO];
        _path = [UIBezierPath bezierPath];
        _remotePath = [UIBezierPath bezierPath];
        [_path setLineWidth:2.0];
        [_remotePath setLineWidth:2.0];
        _path.lineCapStyle = kCGLineCapRound;
        _remotePath.lineCapStyle = kCGLineCapRound;
        firstTime = YES;
        isDrawing = YES;
        fromRemoteParty = NO;
        _pathPoints = [[NSMutableArray alloc] initWithCapacity:2];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (isClearAll) {
        isClearAll = NO;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        return;
    }
    [_pathFormedImage drawInRect:rect];
    [_strokeColor setStroke];
    
    if (fromRemoteParty) {
        fromRemoteParty = NO;
        if (remoteDrawing) {
            [_remotePath stroke];
        }
        else{
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextClearRect(context, rect);
        }
    }
    else{
        if (!isDrawing) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextClearRect(context, rect);
        }
        else{
            [_path stroke];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!isDrawing) {
        _pointsMessage = @"";
        drawPointsNumber = 0;
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    NSValue *val = [NSValue valueWithCGPoint:[touch locationInView:self]];
    [_pathPoints addObject: val];
    [_path moveToPoint:p];
    firstTouch = YES;
    
    //
    CGSize winSize = self.frame.size;
    _pointsMessage = [NSString stringWithFormat:@"%f:%f", p.x /winSize.width, p.y / winSize.height];
    drawPointsNumber = 1;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    firstTouch = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    NSValue *val = [NSValue valueWithCGPoint:point];
    [_pathPoints addObject: val];
    NSArray *points = [self calculateSmoothLinePoints:_pathPoints];
    for (int i = 0; i < [points count]; ++i) {
        CGPoint p = [[points objectAtIndex:i] CGPointValue];
        if (!isDrawing) {
            [self setNeedsDisplayInRect:CGRectMake(p.x - 6, p.y - 6, 12, 12)];
        }
        else{
            [_path addLineToPoint: p];
        }
    }
    
    // Prepare the drawing points
    CGSize winSize = self.bounds.size;
    if (drawPointsNumber < MaxDrawPoints) {
        if ([_pointsMessage isEqualToString:@""]) {
            _pointsMessage = [NSString stringWithFormat:@"%f:%f", point.x / winSize.width, point.y / winSize.height];
        }
        else{
            _pointsMessage = [NSString stringWithFormat:@"%@:%f:%f", _pointsMessage, point.x / winSize.width, point.y / winSize.height];
        }
        drawPointsNumber ++;
    }
    else{
        if (isDrawing) {
            [self sendDoodleMessage:@"DRAW"];
        }
        else{
            [self sendDoodleMessage:@"ERASE"];
        }
        drawPointsNumber = 3;
        _pointsMessage = [NSString stringWithFormat:@"%f:%f:%f:%f:%f:%f", thirdLastPoint.x / winSize.width, thirdLastPoint.y / winSize.height, previousPoint.x / winSize.width, previousPoint.y / winSize.height, point.x / winSize.width, point.y / winSize.height];
    }
    
    thirdLastPoint = previousPoint;
    previousPoint = point;
    
    if (!isDrawing) {
        return;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!isDrawing) {
        [_path removeAllPoints];
        [_pathPoints removeAllObjects];
        [self sendDoodleMessage:@"ERASE"];
        _pathFormedImage = [self screenshot];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    if (drawPointsNumber < MaxDrawPoints) {
        CGSize winSize = self.bounds.size;
        _pointsMessage = [NSString stringWithFormat:@"%@:%f:%f",_pointsMessage, pos.x / winSize.width, pos.y / winSize.height];
    }
    
    [self sendDoodleMessage:@"DRAW"];
    if (firstTouch) {
        [_path addLineToPoint:pos];
    }
    else{
        NSValue *val = [NSValue valueWithCGPoint:pos];
        [_pathPoints addObject: val];
        NSArray *points = [self calculateSmoothLinePoints:_pathPoints];
        for (int i = 0; i < [points count]; ++i) {
            CGPoint p = [[points objectAtIndex:i] CGPointValue];
            [_path addLineToPoint:p];
        }
    }
    [self writeToImageWithPath:_path Color:_strokeColor];
    [_path removeAllPoints];
    [_pathPoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)sendDoodleMessage:(NSString *)drawing{
    //Send message to remotrparty
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@",kDrawingPoints,kSeparator,drawing,kSeparator,_pointsMessage];
    [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
}

- (void)writeToImageWithPath:(UIBezierPath*)path Color:(UIColor *)color
{
    CGSize size= self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (firstTime) {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
        firstTime = NO;
    }
    else{
        [_pathFormedImage drawAtPoint:CGPointZero];
    }
    [color setStroke];
    [path stroke];
    _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing
{
    //firstTime = NO;
    remoteDrawing = drawing;
    [_remotePath removeAllPoints];
    NSArray *array = [self calculateSmoothLinePoints:points];
    if (drawing) {
        for (int i = 0; i < [array count]; ++i) {
            if (i == 0) {
                CGPoint p = [[array objectAtIndex:i] CGPointValue];
                [_remotePath moveToPoint:p];
            }
            else{
                CGPoint p = [[array objectAtIndex:i] CGPointValue];
                [_remotePath addLineToPoint:p];
            }
        }
        fromRemoteParty = YES;
        [self setNeedsDisplay];
        [self writeToImageWithPath:_remotePath Color:_strokeColor];
    }
    else{
        CGSize imageSize = self.bounds.size;
        if (NULL != UIGraphicsBeginImageContextWithOptions){
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        }
        else{
            UIGraphicsBeginImageContext(imageSize);
        }
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[self layer] renderInContext:context];

        for (int i = 0; i < [array count]; ++i) {
            CGPoint p = [[array objectAtIndex:i] CGPointValue];
            CGContextClearRect(context, CGRectMake(p.x - 6, p.y - 6, 12, 12));
        }
        //_pathFormedImage = [self screenshot];
        _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        fromRemoteParty = YES;
        [self setNeedsDisplay];
    }
}

- (NSMutableArray *)calculateSmoothLinePoints:(NSMutableArray *)points
{
    if ([points count] > 2) {
        NSMutableArray *smoothedPoints = [[NSMutableArray alloc] initWithCapacity:2];
        for (unsigned int i = 2; i < [points count]; ++i) {
            CGPoint prev2 = [[points objectAtIndex:i - 2] CGPointValue];
            CGPoint prev1 = [[points objectAtIndex:i - 1] CGPointValue];
            CGPoint cur = [[points objectAtIndex:i] CGPointValue];
            
            CGPoint midPoint1 = CGPointMake((prev1.x + prev2.x) / 2.0, (prev1.y + prev2.y) / 2.0);
            CGPoint midPoint2 = CGPointMake((prev1.x + cur.x) / 2.0, (prev1.y + cur.y) / 2.0);
            int segmentDistance = 2;
            float distance = sqrtf((midPoint1.x - midPoint2.x) * (midPoint1.x - midPoint2.x) + (midPoint1.y - midPoint2.y) * (midPoint1.y - midPoint2.y));
            int numberOfSegments = MIN(4, MAX(floorf(distance / segmentDistance), 2));
            
            float t = 0.0f;
            float step = 1.0f / numberOfSegments;
            for (NSUInteger j = 0; j < numberOfSegments; j++) {
                CGPoint newPoint, p1, p2 ,p3;
                p1 = CGPointMake(midPoint1.x * powf(1 - t, 2), midPoint1.y * powf(1 - t, 2));
                p2 = CGPointMake(prev1.x * 2 * (1 - t) * t, prev1.y * 2 * (1 - t) * t);
                p3 = CGPointMake(midPoint2.x * powf(t, 2), midPoint2.y * powf(t, 2));
                newPoint = CGPointMake(p1.x + p2.x + p3.x, p1.y + p2.y + p3.y);
                NSValue *val = [NSValue valueWithCGPoint:newPoint];
                [smoothedPoints addObject:val];
                t += step;
            }
            NSValue *val=[NSValue valueWithCGPoint:midPoint2];
            [smoothedPoints addObject:val];
        }
        // We need to leave last 2 points for next draw
        [points removeObjectsInRange:NSMakeRange(0, [points count] - 2)];
        return smoothedPoints;
    } else {
        return nil;
    }
}

- (void)clearAll
{
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    [[SipStackUtils sharedInstance].messageService sendMessage:kClearAllHandWriting toRemoteParty:remotePartyNumber];
    [self clearAllFromRemote];
}

- (void)clearAllFromRemote
{
    isClearAll = YES;
    [self setNeedsDisplayInRect:self.frame];
    [self initPathImage];
}

- (void)initPathImage
{
    CGSize size= self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    [[UIColor whiteColor] setFill];
    [rectpath fill];
    _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)changePaintingMode
{
    isDrawing = !isDrawing;
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = self.bounds.size;
    if (NULL != UIGraphicsBeginImageContextWithOptions){
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    }
    else{
        UIGraphicsBeginImageContext(imageSize);
    }
    UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    [[UIColor whiteColor] setFill];
    [rectpath fill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[self layer] renderInContext:context];
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
