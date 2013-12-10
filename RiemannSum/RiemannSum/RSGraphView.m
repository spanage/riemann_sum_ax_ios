//
//  RSGraphView.m
//  RiemannSum
//
//  Created by Sommer Panage on 8/11/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import "RSGraphView.h"
#import "RSRiemannModel.h"
#import "UIView+RSHelpers.h"

#define ERROR_TEXT @"Invalid Model"
#define ERROR_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f])

#define GRAPH_MARGIN_BOTTOM_LEFT 40.0f
#define GRAPH_MARGIN_TOP_RIGHT 20.0f
#define GRAPH_TICK_COUNT 11
#define GRAPH_TICK_LENGTH 10.0f
#define GRAPH_TICK_FORMAT_STRING @"%.02f"
#define GRAPH_TICK_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:12.0f])
#define GRAPH_CURVE_AX_INNER_HEIGHT 4.0f

@implementation RSGraphView
{
    RSRiemannModel *_model;
    UILabel *_errorLabel;
    
    NSMutableArray *_axElements;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithBackingModel:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithBackingModel:nil];
}

- (id)initWithBackingModel:(RSRiemannModel *)backingModel
{
    NSParameterAssert(backingModel);
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _model = backingModel;
        
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.text = ERROR_TEXT;
        _errorLabel.font = ERROR_FONT;
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        
        _axElements = [NSMutableArray new];
        
        [self addSubview:_errorLabel];
    }
    return self;
}

- (void)update
{
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _errorLabel.hidden = !_model.error;
    if (_model.error) {
        [_errorLabel sizeToFit];
        CGSize errorSize = CGSizeMake(self.bounds.size.width, _errorLabel.frame.size.height);
        CGPoint errorOrigin = CGPointMake(self.bounds.origin.x, floorf((CGRectGetMaxY(self.bounds) - errorSize.height) / 2.0f));
        _errorLabel.frame = CGRectMake(errorOrigin.x, errorOrigin.y, errorSize.width, errorSize.height);
    }
}

- (void)drawRect:(CGRect)rect
{
    [_axElements removeAllObjects];
    
    const CGRect b = self.bounds;
    CGContextRef ctx =  UIGraphicsGetCurrentContext();
    
    const CGRect graphFrame = CGRectMake(GRAPH_MARGIN_BOTTOM_LEFT,
                                         GRAPH_MARGIN_TOP_RIGHT,
                                         b.size.width - GRAPH_MARGIN_TOP_RIGHT - GRAPH_MARGIN_BOTTOM_LEFT,
                                         b.size.height - GRAPH_MARGIN_BOTTOM_LEFT - GRAPH_MARGIN_TOP_RIGHT);

    
    if (_model.error) {
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextFillRect(ctx, rect);
        }
        CGContextRestoreGState(ctx);
    } else {
        
        NSUInteger nPoints = graphFrame.size.width * [[UIScreen mainScreen] scale];
        RSFloat fOfXMin, fOfXMax;
        NSArray *curveValues = [_model evaluateFunctionForIntervals:(nPoints - 1) fOfXMin:&fOfXMin fOfXMax:&fOfXMax];
        NSAssert(curveValues, @"Function failed to produce values array but was not in error state.");
        
        const CGFloat yIntersection = fOfXMin > 0.0f ? fOfXMin : MIN(fOfXMax, 0.0f);
        const CGFloat xIntersection = _model.xMin > 0.0f ? _model.xMin : MIN(_model.xMax, 0.0f);
        
        const RSRiemannModelFunctionValue * const xMinVal = [RSRiemannModelFunctionValue valueWithX:_model.xMin fOfX:yIntersection];
        const RSRiemannModelFunctionValue * const xMaxVal = [RSRiemannModelFunctionValue valueWithX:_model.xMax fOfX:yIntersection];
        const RSRiemannModelFunctionValue * const fOfXMinVal = [RSRiemannModelFunctionValue valueWithX:xIntersection fOfX:fOfXMin];
        const RSRiemannModelFunctionValue * const fOfXMaxVal = [RSRiemannModelFunctionValue valueWithX:xIntersection fOfX:fOfXMax];
        
        const CGPoint xMinPoint= [self convertFunctionValueToGraphPoint:xMinVal fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
        const CGPoint xMaxPoint= [self convertFunctionValueToGraphPoint:xMaxVal fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
        const CGPoint yMinPoint= [self convertFunctionValueToGraphPoint:fOfXMinVal fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
        const CGPoint yMaxPoint= [self convertFunctionValueToGraphPoint:fOfXMaxVal fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];

#if ACCESSIBLE
        // We see here that order matters in our _axElemment array
        if (yMaxPoint.y < xMinPoint.y) {
            [_axElements addObject:[self axElementForAxisMin:yMinPoint minValue:fOfXMinVal.fOfX max:yMaxPoint maxValue:fOfXMaxVal.fOfX isY:YES]];
            [_axElements addObject:[self axElementForAxisMin:xMinPoint minValue:xMinVal.x max:xMaxPoint maxValue:xMaxVal.x isY:NO]];
        } else {
            [_axElements addObject:[self axElementForAxisMin:xMinPoint minValue:xMinVal.x max:xMaxPoint maxValue:xMaxVal.x isY:NO]];
            [_axElements addObject:[self axElementForAxisMin:yMinPoint minValue:fOfXMinVal.fOfX max:yMaxPoint maxValue:fOfXMaxVal.fOfX isY:YES]];
        }
#endif
        
        CGContextSaveGState(ctx);
        {
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            
            // Draw Axes
            CGContextSaveGState(ctx);
            {                
                CGContextSetLineWidth(ctx, 2.0f);
                
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, xMinPoint.x, xMinPoint.y);
                CGContextAddLineToPoint(ctx, xMaxPoint.x, xMaxPoint.y);
                CGContextStrokePath(ctx);
                
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, yMinPoint.x, yMinPoint.y);
                CGContextAddLineToPoint(ctx, yMaxPoint.x, yMaxPoint.y);
                CGContextStrokePath(ctx);
            }
            CGContextRestoreGState(ctx);
            
            // Draw Axes Labels
            CGContextSaveGState(ctx);
            {
                NSString* xMinString = [NSString stringWithFormat:GRAPH_TICK_FORMAT_STRING, _model.xMin];
                CGSize xMinSize = [xMinString sizeWithFont:GRAPH_TICK_FONT];
                CGPoint xMinCenter = CGPointMake(xMinPoint.x - GRAPH_TICK_LENGTH, xMinPoint.y);
                CGContextTranslateCTM(ctx, xMinCenter.x, xMinCenter.y);
                CGContextRotateCTM(ctx, -M_PI_2);
                CGContextTranslateCTM(ctx, -xMinCenter.x, -xMinCenter.y);
                [xMinString drawAtPoint:CGPointMake(xMinCenter.x - (xMinSize.width / 2.0f), xMinCenter.y - (xMinSize.height / 2.0f)) withFont:GRAPH_TICK_FONT];
            }
            CGContextRestoreGState(ctx);
            CGContextSaveGState(ctx);
            {
                NSString* xMaxString = [NSString stringWithFormat:GRAPH_TICK_FORMAT_STRING, _model.xMax];
                CGSize xMaxSize = [xMaxString sizeWithFont:GRAPH_TICK_FONT];
                CGPoint xMaxCenter = CGPointMake(xMaxPoint.x + GRAPH_TICK_LENGTH, xMinPoint.y);
                CGContextTranslateCTM(ctx, xMaxCenter.x, xMaxCenter.y);
                CGContextRotateCTM(ctx, M_PI_2);
                CGContextTranslateCTM(ctx, -xMaxCenter.x, -xMaxCenter.y);
                [xMaxString drawAtPoint:CGPointMake(xMaxCenter.x - (xMaxSize.width / 2.0f), xMaxCenter.y - (xMaxSize.height / 2.0f)) withFont:GRAPH_TICK_FONT];
            }
            CGContextRestoreGState(ctx);
            CGContextSaveGState(ctx);
            {
                NSString* fOfXMinString = [NSString stringWithFormat:GRAPH_TICK_FORMAT_STRING, fOfXMin];
                NSString* fOfXMaxString = [NSString stringWithFormat:GRAPH_TICK_FORMAT_STRING, fOfXMax];
                CGSize fOfXMinSize = [fOfXMinString sizeWithFont:GRAPH_TICK_FONT];
                CGSize fOfXMaxSize = [fOfXMaxString sizeWithFont:GRAPH_TICK_FONT];
                [fOfXMinString drawAtPoint:CGPointMake(yMinPoint.x - floorf(fOfXMinSize.width / 2.0f), yMinPoint.y + floorf(GRAPH_TICK_LENGTH / 2.0f)) withFont:GRAPH_TICK_FONT];
                [fOfXMaxString drawAtPoint:CGPointMake(yMaxPoint.x - floorf(fOfXMaxSize.width / 2.0f), yMaxPoint.y - floorf(GRAPH_TICK_LENGTH / 2.0f) - fOfXMaxSize.height) withFont:GRAPH_TICK_FONT];
            }
            CGContextRestoreGState(ctx);
            
            // Draw Ticks
            const CGFloat dx = floorf(graphFrame.size.width / (GRAPH_TICK_COUNT - 1));
            const CGFloat startY = xMinPoint.y - floorf(GRAPH_TICK_LENGTH / 2.0f);
            const CGFloat endY = xMinPoint.y + floorf(GRAPH_TICK_LENGTH / 2.0f);
            
            const CGFloat dy = floorf(graphFrame.size.height / (GRAPH_TICK_COUNT - 1));
            const CGFloat startX = yMinPoint.x - floorf(GRAPH_TICK_LENGTH / 2.0f);
            const CGFloat endX = yMinPoint.x + floorf(GRAPH_TICK_LENGTH / 2.0f);
            
            for (int i = 0; i < GRAPH_TICK_COUNT; ++i) {
                const CGFloat x = xMinPoint.x + i * dx;
                const CGFloat y = yMaxPoint.y + i * dy;
                CGContextSaveGState(ctx);
                {
                    CGContextSetLineWidth(ctx, 1.0f);
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, x, startY);
                    CGContextAddLineToPoint(ctx, x, endY);
                    CGContextStrokePath(ctx);
                }
                CGContextRestoreGState(ctx);
                
                CGContextSaveGState(ctx);
                {
                    CGContextSetLineWidth(ctx, 1.0f);
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, startX, y);
                    CGContextAddLineToPoint(ctx, endX, y);
                    CGContextStrokePath(ctx);
                }
                CGContextRestoreGState(ctx);
            }
        }
        CGContextRestoreGState(ctx);

        // Draw Function Curve
        UIBezierPath *curve = [UIBezierPath bezierPath];
        curve.lineWidth = 2.0f;
        CGPoint point = [self convertFunctionValueToGraphPoint:curveValues[0] fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
        [curve moveToPoint:point];
        for (int i = 1; i < [curveValues count]; ++i) {
            point = [self convertFunctionValueToGraphPoint:curveValues[i] fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
            [curve addLineToPoint:point];
        }
#if ACCESSIBLE
        [_axElements addObject:[self axElementForFunctionCurve:curve]];
#endif
        CGContextSaveGState(ctx);
        {
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
            [curve stroke];
        }
        CGContextRestoreGState(ctx);
        
        // Draw Rects
        NSArray *values = _model.functionValues;
        RSFloat dx = _model.deltaX;
        CGContextSaveGState(ctx);
        {
            CGContextSetLineWidth(ctx, 0.5f);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
            for (int i = 0; i < _model.intervalCount; ++i) {
                
                CGContextSaveGState(ctx);
                {
                    const RSRiemannModelFunctionValue * const value = values[i];
                    
                    const RSRiemannModelFunctionValue * const baseLeft = [RSRiemannModelFunctionValue valueWithX:value.x fOfX:xMinVal.fOfX];
                    const RSRiemannModelFunctionValue * const valueRight = [RSRiemannModelFunctionValue valueWithX:(value.x + dx) fOfX:value.fOfX];
                    
                    const CGPoint baseLeftPoint = [self convertFunctionValueToGraphPoint:baseLeft fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
                    const CGPoint valueRightPoint = [self convertFunctionValueToGraphPoint:valueRight fOfXMin:fOfXMin fOfXMax:fOfXMax rect:graphFrame];
                    
                    const CGPoint origin = CGPointMake(baseLeftPoint.x, (baseLeftPoint.y > valueRightPoint.y) ? valueRightPoint.y : baseLeftPoint.y);
                    const CGSize size = CGSizeMake(valueRightPoint.x - baseLeftPoint.x, fabsf(valueRightPoint.y - baseLeftPoint.y));
                    const CGRect newRect = CGRectMake(origin.x, origin.y, size.width, size.height);
                                        
                    CGContextFillRect(ctx, newRect);
                    CGContextStrokeRect(ctx, newRect);
#if ACCESSIBLE
                    [_axElements addObject:[self axElementForRectangle:newRect forValue:value withDx:dx rectNumber:i + 1]];
#endif
                }
                CGContextRestoreGState(ctx);
            }
        }
        CGContextRestoreGState(ctx);
    }
    
    // We do this to avoid waiting until we try to access the elements to rebuilt the AX-tree
#if ACCESSIBLE
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
#endif
}

- (CGPoint)convertFunctionValueToGraphPoint:(const RSRiemannModelFunctionValue *)value fOfXMin:(RSFloat)fOfXMin fOfXMax:(RSFloat)fOfXMax rect:(CGRect)rect
{
    CGFloat coef_x = CGRectGetWidth(rect) / (_model.xMax - _model.xMin);
    CGFloat coef_y = CGRectGetHeight(rect) / (fOfXMax - fOfXMin);
    
    CGPoint point;
    point.x = (value.x - _model.xMin) * coef_x + CGRectGetMinX(rect);
    point.y = CGRectGetMaxY(rect) - ((value.fOfX - fOfXMin) * coef_y);
    
    return point;
}

#pragma mark - Accessibility

#define AXIS_LABEL(Y) ((Y) ? (@"Y axis") : (@"X axis"))
#define AXIS_VALUE(MIN, MAX) ([NSString stringWithFormat:@"From %.02f to %.02f", (MIN), (MAX)])
#define RECT_LABEL(N) ([NSString stringWithFormat:@"Rectangle %d", (N)])
#define RECT_VALUE(X, DX, Y) ([NSString stringWithFormat:@"Height %.02f. From x = %.02f to %.02f. Area %.02f.", (Y), (X), ((X) + (DX)), ((DX) * (Y))])

#if ACCESSIBLE

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSInteger)accessibilityElementCount
{
    return [_axElements count];
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [_axElements indexOfObject:element];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    id elem = nil;
    if (index >= 0 && index < [_axElements count]) {
        elem = _axElements[index];
    }
    return elem;
}

- (UIAccessibilityElement *)axElementForAxisMin:(CGPoint)min minValue:(RSFloat)minValue max:(CGPoint)max maxValue:(RSFloat)maxValue isY:(BOOL)isY
{
    const CGFloat halfBreadth = floorf(GRAPH_TICK_LENGTH / 2.0f);
    CGFloat width, height;
    
    if (isY) {
        min.x -= halfBreadth;
        width = 2.0f * halfBreadth;
        height = max.y - min.y;
    } else {
        min.y -= halfBreadth;
        width = max.x - min.x;
        height = 2.0f * halfBreadth;
    }
    
    CGRect axFrame = CGRectMake(min.x, min.y, width, height);
    
    UIAccessibilityElement *elem = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    elem.accessibilityLabel = AXIS_LABEL(isY);
    elem.accessibilityValue = AXIS_VALUE(minValue, maxValue);
    elem.accessibilityFrame = [self rs_screenCoordinatesForRect:axFrame];
    
    return elem;
}

- (UIAccessibilityElement *)axElementForRectangle:(CGRect)rect forValue:(const RSRiemannModelFunctionValue * const)value withDx:(RSFloat)dx rectNumber:(NSUInteger)n
{
    UIAccessibilityElement *elem = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    elem.accessibilityLabel = RECT_LABEL(n);
    elem.accessibilityValue = RECT_VALUE(value.x, dx, value.fOfX);
    elem.accessibilityFrame = [self rs_screenCoordinatesForRect:rect];
    return elem;
}

- (UIAccessibilityElement *)axElementForFunctionCurve:(UIBezierPath *)curve
{
    UIAccessibilityElement *elem = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
    elem.accessibilityLabel = @"Function Curve";

    UIBezierPath *translatedTopCurve = [curve copy];
    UIBezierPath *translatedBottomCurve = [curve bezierPathByReversingPath];
    const CGRect frameInScreenCoords = [self rs_screenCoordinatesForRect:self.bounds];
    const CGFloat dx = frameInScreenCoords.origin.x - self.bounds.origin.x;
    const CGFloat yOffset = floorf(GRAPH_CURVE_AX_INNER_HEIGHT / 2);
    const CGFloat dyTop = frameInScreenCoords.origin.y - self.bounds.origin.y - yOffset;
    const CGFloat dyBottom = frameInScreenCoords.origin.y - self.bounds.origin.y + yOffset;
    [translatedTopCurve applyTransform:CGAffineTransformMakeTranslation(dx, dyTop)];
    [translatedBottomCurve applyTransform:CGAffineTransformMakeTranslation(dx, dyBottom)];

    const CGFloat axCurveHeight = ceilf(2.0f * yOffset);
    UIBezierPath *axPath = [translatedTopCurve copy];
    [axPath addLineToPoint:CGPointMake(axPath.currentPoint.x, axPath.currentPoint.y + axCurveHeight)];
    [axPath appendPath:translatedBottomCurve];
    [axPath addLineToPoint:CGPointMake(axPath.currentPoint.x, axPath.currentPoint.y - axCurveHeight)];

    elem.accessibilityPath = axPath;
    return elem;
}
#endif

@end
