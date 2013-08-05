//
//  RiemannSumTests.m
//  RiemannSumTests
//
//  Created by Sommer Panage on 8/4/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import "RiemannSumTests.h"

#import "RSRiemannModel.h"

@interface RiemannSumTests()
@property RSRiemannModel *model;
@end

@implementation RiemannSumTests

- (void)setUp
{
    [super setUp];
    self.model = [[RSRiemannModel alloc] init];

}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEmptyModel
{
    STAssertEquals(self.model.xMin, 0.0f, @"Min X is initialized to 0.");
    STAssertEquals(self.model.xMax, 0.0f, @"Max X is initialized to 0.");
    STAssertEquals(self.model.intervalCount, 0, @"Interval Count is initialized to 0.");
    STAssertNil(self.model.function, @"Function is initialized to nil");
    STAssertEquals(self.model.deltaX, 0.0f, @"DeltaX is initially computed as 0.");
    STAssertNil(self.model.functionValues, @"Function is initially nil");
    STAssertEquals(self.model.sum, 0.0f, @"Sum is initially computed as 0");
    STAssertEquals(self.model.error, YES, @"Error conditions match expected.");
    
    RSFloat min, max;
    STAssertNil([self.model evaluateFunctionForIntervals:10 fOfXMin:&min fOfXMax:&max], @"Evaluation should fail");

}

- (void)testSimpleModel
{
    self.model.function = ^RSFloat(RSFloat x) {
        return 1.0f;
    };
    self.model.integratedFunction = ^RSFloat(RSFloat x) {
        return 1.0f * x;
    };

    self.model.xMin = -2.0f;
    self.model.xMax = 2.0f;
    self.model.intervalCount = 4;
    
    STAssertEquals(self.model.xMin, -2.0f, @"Min X is -2.");
    STAssertEquals(self.model.xMax, 2.0f, @"Max X is 2.");
    STAssertEquals(self.model.intervalCount, 4, @"Interval Count is 4.");
    STAssertNotNil(self.model.function, @"Function is non-nil.");
    STAssertEquals(self.model.deltaX, 1.0f, @"DeltaX is 1.");
    STAssertNotNil(self.model.functionValues, @"Function is non-nil.");
    STAssertEquals([self.model.functionValues count], (NSUInteger)4, @"Function has 4 values");
    
    RSRiemannModelFunctionValue *value;

    value = [self.model.functionValues objectAtIndex:0];
    STAssertEquals(value.x, -2.0f, @"First x = -2");
    STAssertEquals(value.fOfX, 1.0f, @"First f(x) = 1");
    
    value = [self.model.functionValues objectAtIndex:1];
    STAssertEquals(value.x, -1.0f, @"First x = -1");
    STAssertEquals(value.fOfX, 1.0f, @"First f(x) = 1");
    
    value = [self.model.functionValues objectAtIndex:2];
    STAssertEquals(value.x, 0.0f, @"First x = 0");
    STAssertEquals(value.fOfX, 1.0f, @"First f(x) = 1");
    
    value = [self.model.functionValues objectAtIndex:3];
    STAssertEquals(value.x, 1.0f, @"First x = 1");
    STAssertEquals(value.fOfX, 1.0f, @"First f(x) = 1");
    
    STAssertEquals(self.model.sum, 4.0f, @"Sum is initially computed as 0");
    STAssertEquals(NO, self.model.error, @"Error conditions match expected.");
    
    RSFloat min, max;
    NSArray *vals = [self.model evaluateFunctionForIntervals:10 fOfXMin:&min fOfXMax:&max];
    STAssertEquals([vals count], (NSUInteger)11, @"We return intervals + 1 values");
}

- (void)testXCubed
{
    [self _testModelWithFunction:^RSFloat(RSFloat x) {
        return x * x * x;
    } integratedFunction:^RSFloat(RSFloat x) {
        return x * x * x * x * 0.25;
    } xMin:-4.0f xMax:0 intervalCount:20 forSum:-70.56 forIntegratedValue:-64.00 error:NO];
}

- (void)testInvalidRange
{
    [self _testModelWithFunction:^RSFloat(RSFloat x) {
        return x * x * x;
    } integratedFunction:^RSFloat(RSFloat x) {
        return x * x * x * x * 0.25;
    } xMin:-4.0f xMax:-10.0 intervalCount:20 forSum:0 forIntegratedValue:0 error:YES];
}

- (void)testInvalidIntervalCount
{
    [self _testModelWithFunction:^RSFloat(RSFloat x) {
        return x * x * x;
    } integratedFunction:^RSFloat(RSFloat x) {
        return x * x * x * x * 0.25;
    } xMin:0.0f xMax:1.0 intervalCount:-1 forSum:0 forIntegratedValue:0 error:YES];
}

- (void)_testModelWithFunction:(RSRiemannModelFunction)function integratedFunction:(RSRiemannModelFunction)integratedFunction xMin:(RSFloat)xMin xMax:(RSFloat)xMax intervalCount:(int)intervalCount forSum:(RSFloat)sum forIntegratedValue:(RSFloat)integratedValue error:(BOOL)error
{
    self.model.function = function;
    self.model.integratedFunction = integratedFunction;
    self.model.xMin = xMin;
    self.model.xMax = xMax;
    self.model.intervalCount = intervalCount;
    
    STAssertEquals(error, self.model.error, @"Error conditions match expected.");

    if (!self.model.error) {
        STAssertEqualsWithAccuracy(self.model.sum, sum, 0.01, @"Sum is correct.");
        STAssertEqualsWithAccuracy(self.model.integratedValue, integratedValue, 0.01, @"Integrated value is correct.");
    }
}


@end
