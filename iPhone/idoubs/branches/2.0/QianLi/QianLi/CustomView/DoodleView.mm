//
//  DoodleView.m
//  QianLi
//
//  Created by lutan on 8/27/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "DoodleView.h"
#import "SipStackUtils.h"

@interface DoodleView (){
    UIBezierPath *_path;
    UIBezierPath *_remotePath;
   // NSMutableArray *_pathsArray;
    NSMutableArray *_pathPoints;
    UIImage *_pathFormedImage;
    BOOL firstTouch;
    BOOL firstDrawInRect;
    BOOL firstTime;
    BOOL _isDrawing;
    BOOL fromRemoteParty;
    BOOL remoteDrawing;
    BOOL isClearAll;
    NSInteger numberOfPoints; //to record how many points we have got and needed to send to our partner
    
    CGPoint previousPoint;
    CGPoint thirdLastPoint;
}

@property(strong, nonatomic) UIColor *strokeColor;
@property(strong, nonatomic) NSString *pointsMessage;

@end

@implementation DoodleView

@synthesize isDrawing = _isDrawing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setMultipleTouchEnabled:YES];
        _path = [UIBezierPath bezierPath];
        _remotePath = [UIBezierPath bezierPath];
        [_path setLineWidth:2.0];
        [_remotePath setLineWidth:2.0];
        _path.lineCapStyle = kCGLineCapRound;
        _remotePath.lineCapStyle = kCGLineCapRound;
        _strokeColor = [UIColor redColor];
        firstDrawInRect = YES;
        firstTime = YES;
        _isDrawing = YES;
        fromRemoteParty = NO;
        isClearAll = NO;
        _pathPoints = [[NSMutableArray alloc] initWithCapacity:2];
        self.backgroundColor = nil;
        self.layer.opaque = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer: tapGesture];
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
    
    if (firstDrawInRect) {
        [self writeToImageWithPath:_path Color:_strokeColor];
        firstDrawInRect = NO;
    }
    
    if (rect.size.width > 20) {
        [_pathFormedImage drawInRect:rect];
    }
    [_strokeColor setStroke];
    
    if (fromRemoteParty) {
        fromRemoteParty = NO;
        if (remoteDrawing) {
            [_remotePath stroke];
        }
        else{
        }
    }
    else{
        if (!_isDrawing) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextClearRect(context, rect);
        }
        else{
            [_path stroke];
        }
    }
}

-(void)handleTap:(UITapGestureRecognizer *)tap
{
    [_delegate didTapOnView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_isDrawing) {
        _pointsMessage = @"";
        numberOfPoints = 0;
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
    _pointsMessage = [NSString stringWithFormat:@"%f:%f", p.x / winSize.width, p.y / winSize.height];
    numberOfPoints = 1;
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
        if (!_isDrawing) {
            [self setNeedsDisplayInRect:CGRectMake(p.x - 6, p.y - 6, 12, 12)];
        }
        else{
            [_path addLineToPoint:p];
        }
    }
    
    // Prepare the drawing points
    CGSize winSize = self.frame.size;
    if (numberOfPoints < MaxDrawPoints) {
        if ([_pointsMessage isEqualToString:@""]) {
            _pointsMessage = [NSString stringWithFormat:@"%f:%f",point.x / winSize.width, point.y / winSize.height];
        }
        else{
            _pointsMessage = [NSString stringWithFormat:@"%@:%f:%f",_pointsMessage, point.x / winSize.width, point.y / winSize.height];
        }
        numberOfPoints ++;
    }
    else{
        if (_isDrawing) {
            [self sendDoodleMessage:@"DRAW"];
        }
        else{
            [self sendDoodleMessage:@"ERASE"];
        }
        numberOfPoints = 3;
        _pointsMessage = [NSString stringWithFormat:@"%f:%f:%f:%f:%f:%f", thirdLastPoint.x / winSize.width, thirdLastPoint.y / winSize.height, previousPoint.x / winSize.width, previousPoint.y / winSize.height, point.x / winSize.width, point.y / winSize.height];
    }
    
    thirdLastPoint = previousPoint;
    previousPoint = point;
    
    if (!_isDrawing) {
        return;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (firstTouch) {
        [_path removeAllPoints];
        [_pathPoints removeAllObjects];
        return;
    }
    if (!_isDrawing) {
        [_path removeAllPoints];
        [_pathPoints removeAllObjects];
        [self sendDoodleMessage:@"ERASE"];
        _pathFormedImage = [self screenshot];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    if (numberOfPoints < MaxDrawPoints) {
        CGSize winSize = self.frame.size;
        _pointsMessage = [NSString stringWithFormat:@"%@:%f:%f",_pointsMessage, pos.x / winSize.width, pos.y / winSize.height];
    }
    
    [self sendDoodleMessage:@"DRAW"];
    NSValue *val = [NSValue valueWithCGPoint:pos];
    [_pathPoints addObject: val];
    NSArray *points = [self calculateSmoothLinePoints:_pathPoints];
    for (int i = 0; i < [points count]; ++i) {
        CGPoint p = [[points objectAtIndex:i] CGPointValue];
        [_path addLineToPoint:p];
    }
    [self writeToImageWithPath:_path Color:_strokeColor];
    [_path removeAllPoints];
    [_pathPoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self touchesEnded:touches withEvent:event];
}

- (void)sendDoodleMessage:(NSString *)drawing{
    //Send message to remotrparty
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@", kDoodleImagePoints, kSeparator, drawing, kSeparator, _pointsMessage];
    [[SipStackUtils sharedInstance].messageService sendMessage:str toRemoteParty:remotePartyNumber];
}

- (void)writeToImageWithPath:(UIBezierPath*)path Color:(UIColor *)color
{
    CGSize size= self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (firstTime) {
        [self drawImage];
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

- (void)drawImage
{
    if (_image == nil) {
        return;
    }
//    [_image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGSize newImageSize = [self adjustImageFrame:_image.size];
    [_image drawInRect:CGRectMake((self.frame.size.width-newImageSize.width)/2, (self.frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height)];
}

- (CGSize)adjustImageFrame:(CGSize)imageSize
{
    // 调节图片的大小, 使其适应屏幕
    // 目标: 在不拉伸图片的时候使其充满屏幕
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGSize newImageSize = imageSize;
    
    if ((imageSize.width / imageSize.height) <= (width / height)) {
        newImageSize.height = height;
        newImageSize.width = imageSize.width * height / imageSize.height;
    }
    else {
        newImageSize.width = width;
        newImageSize.height = imageSize.height * width / imageSize.width;
    }
    
    return newImageSize;
}

- (void)drawingOnImageWithPoints:(NSMutableArray *)points Drawing:(BOOL)drawing
{
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
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[self layer] renderInContext:context];
        fromRemoteParty = YES;
        for (int i = 0; i < [array count]; ++i) {
           CGPoint p = [[array objectAtIndex:i] CGPointValue];
           CGContextClearRect(context, CGRectMake(p.x - 6, p.y - 6, 12, 12));
        }
        _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
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

- (void)changePaintingMode
{
    _isDrawing = !_isDrawing;
}

- (void)clearAll
{
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    [[SipStackUtils sharedInstance].messageService sendMessage:kClearAllDoodle toRemoteParty:remotePartyNumber];
    [self clearAllFromRemote];
}

- (void)clearAllFromRemote
{
    isClearAll = YES;
    [self setNeedsDisplayInRect:self.frame];
    [self initPathImage];
    [self setNeedsDisplay];
}

- (void)initPathImage
{
    CGSize size= self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self drawImage];
    _pathFormedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    CGSize imageSize = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGSize newImageSize = [self adjustImageFrame:_image.size];
    [_image drawInRect:CGRectMake((320-newImageSize.width)/2, (self.frame.size.height-newImageSize.height)/2, newImageSize.width, newImageSize.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[self layer] renderInContext:context];
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
