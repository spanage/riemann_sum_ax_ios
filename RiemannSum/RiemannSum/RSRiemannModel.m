//
//  RSRiemannModel.m
//  RiemannSum
//
//  Created by Sommer Panage on 8/4/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import "RSRiemannModel.h"

@interface RSRiemannModelFunctionValue()

@property (nonatomic, readwrite) RSFloat x;
@property (nonatomic, readwrite) RSFloat fOfX;

@end

@implementation RSRiemannModelFunctionValue

+ (instancetype)valueWithX:(RSFloat)x fOfX:(RSFloat)fOfX
{
    RSRiemannModelFunctionValue *value = [[RSRiemannModelFunctionValue alloc] init];
    value.x = x;
    value.fOfX = fOfX;
    return value;
}

@end

@implementation RSRiemannModel

- (RSFloat)deltaX
{
    return (_intervalCount && (_xMax > _xMin)) ? (_xMax - _xMin) / ((RSFloat)_intervalCount) : 0.0f;
}

- (NSArray *)functionValues
{
    NSMutableArray *values;
    if (_function) {
        values = [[NSMutableArray alloc] initWithCapacity:_intervalCount];
        const RSFloat deltaX = [self deltaX];
        RSFloat x = _xMin;
        for (int i = 0; i < _intervalCount; i++) {
            const RSFloat fOfX = _function(x);
            [values addObject:[RSRiemannModelFunctionValue valueWithX:x fOfX:fOfX]];
            x += deltaX;
        }
    }
    return [values copy];
}

- (RSFloat)sum
{
    NSArray *functionValues = [self functionValues];
    const RSFloat dx = [self deltaX];
    
    RSFloat sum = 0;
    for (int i = 0; i < _intervalCount; i++) {
        RSRiemannModelFunctionValue *value = [functionValues objectAtIndex:i];
        sum += (dx * value.fOfX);
    }
    
    return sum;
}

- (RSFloat)integratedValue
{
    RSFloat value = 0.0f;
    if (_integratedFunction) {
        value = _integratedFunction(_xMax) - _integratedFunction(_xMin);
    }
    return value;
}

- (BOOL)error
{
    return (_xMax <= _xMin) || (_intervalCount < 0) || (_function == nil) || (_integratedFunction == nil);
}

- (NSArray *)evaluateFunctionForIntervals:(NSUInteger)intervals fOfXMin:(RSFloat *)fOfXMin fOfXMax:(RSFloat *)fOfXMax
{
    if (self.error) {
        return nil;
    }
    
    NSUInteger dataPoints = intervals + 1;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:dataPoints];
    
    RSFloat dx = (_xMax - _xMin) / ((RSFloat)intervals);
    
    RSFloat x = _xMin;
    RSFloat min = INFINITY;
    RSFloat max = -INFINITY;
    for (int i = 0; i < dataPoints; ++i) {
        RSRiemannModelFunctionValue *value = [[RSRiemannModelFunctionValue alloc] init];
        RSFloat fOfX = _function(x);
        min = (fOfX < min) ? fOfX : min;
        max = (fOfX > max) ? fOfX : max;
        value.x = x;
        value.fOfX = fOfX;
        [values addObject:value];
        x += dx;
        
    }
    *fOfXMin = min;
    *fOfXMax = max;
    return [values copy];
}

@end
