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
    BOOL remotePathHasPoints;
    NSInteger drawPointsNumber;
    
    CGPoint previousPoint;
    CGPoint thirdLastPoint;
    
    NSInteger colorIndex;
}

@property(assign, nonatomic) CGFloat lineWidth;
@property(assign, nonatomic) CGFloat eraseLineWidth;
@property(assign, nonatomic) CGFloat remoteLineWidth;
@property(strong, nonatomic) UIColor *remoteStrokeColor;
@property(strong, nonatomic) UIColor *strokeColor;
@property(strong, nonatomic) NSString *pointsMessage;
@property(strong, nonatomic) UIImage *pathFormedImage;
@property(strong, nonatomic) UIImage *prePathFormedImage;

@end

@implementation HandDrawingView

@synthesize pathFormedImage = _pathFormedImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        colorIndex = [userData integerForKey:kDoodleLineColor];
        _strokeColor = [self getColorWithIndex:colorIndex];
        _lineWidth = [self getWidthWithIndex:[userData integerForKey:kDoodleLineWidth]];
        _eraseLineWidth = [self getWidthWithIndex:[userData integerForKey:kDoodleEraseWidth]];
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
    if (rect.size.width > 20) {
        [_pathFormedImage drawInRect:rect];
    }
    
    if (fromRemoteParty) {
        fromRemoteParty = NO;
        [_remoteStrokeColor setStroke];
        [_remotePath stroke];
    }
    else{
        if (!isDrawing) {
            [_path setLineWidth:_eraseLineWidth];
            [[UIColor whiteColor] setStroke];
            [_path stroke];
        }
        else{
            [_path setLineWidth:_lineWidth];
            [_strokeColor setStroke];
            [_path stroke];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    if ([_delegate respondsToSelector:@selector(handDrawingDidDraw)]) {
        [_delegate handDrawingDidDraw];
    }
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
        [_path addLineToPoint: p];
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
            [self sendDoodleMessage:@"DRAW" touchEnd:NO];
        }
        else{
            [self sendDoodleMessage:@"ERASE" touchEnd:NO];
        }
        drawPointsNumber = 0;
        _pointsMessage = @"";
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (drawPointsNumber < MaxDrawPoints) {
        CGSize winSize = self.bounds.size;
        if ([_pointsMessage isEqualToString:@""]) {
            _pointsMessage = [NSString stringWithFormat:@"%f:%f", point.x / winSize.width, point.y / winSize.height];
        }
        else{
            _pointsMessage = [NSString stringWithFormat:@"%@:%f:%f", _pointsMessage, point.x / winSize.width, point.y / winSize.height];
        }
    }
    
    if (firstTouch) {
        [_path addLineToPoint:point];
    }
    else{
        NSValue *val = [NSValue valueWithCGPoint:point];
        [_pathPoints addObject: val];
        NSArray *points = [self calculateSmoothLinePoints:_pathPoints];
        for (int i = 0; i < [points count]; ++i) {
            CGPoint p = [[points objectAtIndex:i] CGPointValue];
            [_path addLineToPoint:p];
        }
    }
    if (isDrawing) {
        [self sendDoodleMessage:@"DRAW" touchEnd:YES];
        [self writeToImageWithPath:_path color:_strokeColor width:_lineWidth isDrawing:isDrawing];
    }
    else{
        [self sendDoodleMessage:@"ERASE" touchEnd:YES];
        [self writeToImageWithPath:_path color:[UIColor whiteColor] width:_eraseLineWidth isDrawing:isDrawing];
    }
    [_path removeAllPoints];
    [_pathPoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self touchesEnded:touches withEvent:event];
}

- (void)sendDoodleMessage:(NSString *)drawing touchEnd:(BOOL)touchEnd
{
    int touchFlag = -1;
    if (touchEnd) {
        touchFlag = 1;
    }
    else{
        touchFlag = 0;
    }
    //Send message to remotrparty
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    CGFloat width;
    if (drawing) {
        width = _lineWidth;
    }
    else{
        width = _eraseLineWidth;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@%@%d%@%f%@%d",kDrawingPoints,kSeparator,drawing,kSeparator,_pointsMessage, kSeparator, colorIndex, kSeparator, width, kSeparator, touchFlag];
    [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
}

- (void)writeToImageWithPath:(UIBezierPath*)path color:(UIColor *)color width:(CGFloat)width isDrawing:(BOOL)drawing
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
    [path setLineWidth:width];
    [color setStroke];
    [path stroke];
    _prePathFormedImage = [_pathFormedImage copy];
    _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//handle drawing commands from remoteparty
- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing lineWidth:(CGFloat)width strokeColorIndex:(NSInteger)index touchEnd:(BOOL) touchEnd
{
    //firstTime = NO;
    remoteDrawing = drawing;
    NSArray *array = [self calculateSmoothLinePoints:points];
    for (int i = 0; i < [array count]; ++i) {
        if (!remotePathHasPoints) {
            CGPoint p = [[array objectAtIndex:i] CGPointValue];
            [_remotePath moveToPoint:p];
        }
        else{
            CGPoint p = [[array objectAtIndex:i] CGPointValue];
            [_remotePath addLineToPoint:p];
        }
        remotePathHasPoints = YES;
    }
    
    if (touchEnd) {
        if (drawing) {
            _remoteLineWidth = width;
            _remoteStrokeColor = [self getColorWithIndex:index];
            [_remotePath setLineWidth:_remoteLineWidth];
        }
        else{
            _remoteLineWidth = width;
            _remoteStrokeColor = [UIColor whiteColor];
            [_remotePath setLineWidth:_remoteLineWidth];
        }
        if (drawing) {
            [self writeToImageWithPath:_remotePath color:
             [self getColorWithIndex:index] width:_remoteLineWidth isDrawing:drawing];
        }
        else{
            [self writeToImageWithPath:_remotePath color:[UIColor whiteColor] width:_remoteLineWidth isDrawing:drawing];
        }
        [_remotePath removeAllPoints];
        remotePathHasPoints = NO;
        fromRemoteParty = YES;
        [self setNeedsDisplay];
        if ([_delegate respondsToSelector:@selector(handDrawingDidDraw)]) {
            [_delegate handDrawingDidDraw];
        }
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
    [self setNeedsDisplay];
    [self initPathImage];
}

- (void)revoke
{
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    [[SipStackUtils sharedInstance].messageService sendMessage:kHandDrawingRevoke toRemoteParty:remotePartyNumber];
    [self revokeFromRemoteParty];
}

- (void)revokeFromRemoteParty
{
    _pathFormedImage = [_prePathFormedImage copy];
    [self setNeedsDisplay];
}

- (void)initPathImage
{
    CGSize size= self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    [[UIColor whiteColor] setFill];
    [rectpath fill];
    _prePathFormedImage = [_pathFormedImage copy];
    _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)changeEraseLineWidthTo:(NSInteger)index
{
    _eraseLineWidth = [self getWidthWithIndex:index];
}

- (void)changeDrawLineWidthTo:(NSInteger)index
{
    _lineWidth = [self getWidthWithIndex:index];
}

- (void)changeDrawLineColorTo:(NSInteger)index
{
    _strokeColor = [self getColorWithIndex:index];
    colorIndex = index;
}


- (void)changeToDrawMode
{
    isDrawing = YES;
}

- (void)changeToEraseMode
{
    isDrawing = NO;
}

- (BOOL)getDrawingMode
{
    return isDrawing;
}

- (CGFloat)getWidthWithIndex:(NSInteger)index
{
    CGFloat width;
    switch (index) {
        case 1:
            width = 5.0;
            break;
        case 2:
            width = 13.0;
            break;
        case 3:
            width = 20.0;
            break;
        case 4:
            width = 28.0;
            break;
        default:
            width = 5.0;
            break;
    }
    return width;
}

- (UIColor *)getColorWithIndex:(NSInteger)index
{
    UIColor *colour;
    switch (index) {
        case 1:
             colour = [UIColor colorWithRed:35.0 / 255.0 green:31.0 / 255.0 blue:32.0 / 255.0 alpha:1.0];
            break;
        case 2:
            colour = [UIColor colorWithRed:235.0 / 255.0 green:28.0 / 255.0 blue:36.0 / 255.0 alpha:1.0];
            break;
        case 3:
            colour = [UIColor colorWithRed:249.0 / 255.0 green:222.0 / 255.0 blue:27.0 / 255.0 alpha:1.0];
            break;
        case 4:
            colour = [UIColor colorWithRed:1.0 / 255.0 green:128.0 / 255.0 blue:229.0 / 255.0 alpha:1.0];
            break;
        case 5:
            colour = [UIColor colorWithRed:17.0 / 255.0 green:185.0 / 255.0 blue:45.0 / 255.0 alpha:1.0];
            break;
        case 6:
            colour = [UIColor colorWithRed:180.0 / 255.0 green:46.0 / 255.0 blue:178.0 / 255.0 alpha:1.0];
            break;
            
        default:
            colour = [UIColor colorWithRed:35.0 / 255.0 green:31.0 / 255.0 blue:32.0 / 255.0 alpha:1.0];
            break;
    }
    return colour;
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    CGSize imageSize = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
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
