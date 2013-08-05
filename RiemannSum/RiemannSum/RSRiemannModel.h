//
//  RSRiemannModel.h
//  RiemannSum
//
//  Created by Sommer Panage on 8/4/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//
//  Models the Riemann Sum (Left sum) as an approximation for
//  the inegration of a function.

#import <Foundation/Foundation.h>


typedef float RSFloat;
static const RSFloat RSFloatMax = INFINITY;
static const RSFloat RSFloatMin = -INFINITY;

typedef RSFloat(^RSRiemannModelFunction)(RSFloat x);

@interface RSRiemannModel : NSObject

@property (nonatomic, assign) RSFloat xMin;
@property (nonatomic, assign) RSFloat xMax;
@property (nonatomic, assign) int intervalCount;
@property (nonatomic, copy) RSRiemannModelFunction function;
@property (nonatomic, copy) RSRiemannModelFunction integratedFunction;

/* Convenience properties */
@property (nonatomic, readonly) RSFloat deltaX;
@property (nonatomic, readonly) NSArray *functionValues;
@property (nonatomic, readonly) RSFloat sum;
@property (nonatomic, readonly) RSFloat integratedValue;
@property (nonatomic, readonly) BOOL error; // indicates model is in error state

// returns array sized intervals + 1 of RSRiemannModelFunctionValue objects and provides min f(x) and max f(x)
- (NSArray *)evaluateFunctionForIntervals:(NSUInteger)intervals fOfXMin:(RSFloat *)fOfXMin fOfXMax:(RSFloat *)fOfXMax;

@end


@interface RSRiemannModelFunctionValue : NSObject

+ (instancetype)valueWithX:(RSFloat)x fOfX:(RSFloat)fOfX;

@property (nonatomic, readonly) RSFloat x;
@property (nonatomic, readonly) RSFloat fOfX;

@end