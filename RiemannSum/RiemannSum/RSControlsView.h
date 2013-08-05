//
//  RSControlsView.h
//  RiemannSum
//
//  Created by Sommer Panage on 8/7/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RSControlsViewDelegate;

@interface RSControlsView : UIView

@property (nonatomic, weak) id<RSControlsViewDelegate> delegate;

@property (nonatomic, readonly) NSString *xMinString;
@property (nonatomic, readonly) NSString *xMaxString;
@property (nonatomic, readonly) double rectangleCountValue;
@property (nonatomic, readonly) NSString *selectedFunctionSegmentTitle;

- (BOOL)addFunctionString:(NSString *)functionString;
- (void)resignFirstResponder;
- (void)setXMinField:(NSString *)value;
- (void)setXMaxField:(NSString *)value;

@end

@protocol RSControlsViewDelegate <NSObject>

- (void)xMinTextFieldDidChange:(UITextField *)sender;
- (void)xMaxTextFieldDidChange:(UITextField *)sender;
- (void)functionSegmentSelectionDidChange:(UISegmentedControl *)sender;
- (void)rectangleCountStepperValueDidChange:(UIStepper *)sender;

@end