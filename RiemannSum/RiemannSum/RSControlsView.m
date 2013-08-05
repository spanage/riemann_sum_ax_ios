//
//  RSControlsView.m
//  RiemannSum
//
//  Created by Sommer Panage on 8/7/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import "RSControlsView.h"
#import "UIView+RSHelpers.h"

#define MAX_FUNCTIONS 3
#define RECTANGLE_COUNT_MIN 1
#define RECTANGLE_COUNT_MAX 100
#define RECTANGLE_COUNT_STEP_VALUE 1

#define SEGMENTED_CONTROL_TEXT_PADDING 4.0f
#define VERTICAL_SPACER 6.0f
#define HORIZANTAL_SPACER_SMALL 4.0f
#define HORIZANTAL_SPACER_LARGE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (40.0f) : (12.0f))

#define X_MIN_PLACEHOLDER @"Min x"
#define X_MAX_PLACEHOLDER @"Max x"
#define RECTANGLE_COUNT_LABEL ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (@"Number of rects (n)") : (@"n"))

#define FUNCTION_SEGEMENTS_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:12.0f])
#define LABEL_FONT ([UIFont fontWithName:@"HelveticaNeue" size:16.0f])
#define VALUE_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0f])

// Accessibility Text
#define X_MIN_AX_LABEL @"Minimum x value"
#define X_MAX_AX_LABEL @"Maximum x value"
#define RECTANGLE_STEPPER_AX_LABEL @"Number of rectangles"
#define RECTANGLE_STEPPER_AX_VALUE(N) ((N > 1) ? ([NSString stringWithFormat:@"%d rectangles", (N)]) : ([NSString stringWithFormat:@"%d rectangle", (N)]))

@interface RectangleStepper : UIStepper
@end

@implementation RectangleStepper

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits |= UIAccessibilityTraitAdjustable;
        self.accessibilityLabel = RECTANGLE_STEPPER_AX_LABEL;
    }
    return self;
}

- (void)accessibilityIncrement
{
    self.value += 1.0;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)accessibilityDecrement
{
    self.value -= 1.0;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end


@interface RSControlsView() <UITextFieldDelegate>
@end

@implementation RSControlsView
{
    NSMutableArray *_functionStrings;
    NSMutableArray *_axFunctionStrings;
    UISegmentedControl *_functionSegmentedControl;
    UITextField *_xMinTextField;
    UITextField *_xMaxTextField;
    UIStepper *_rectangleCountStepper;
    UIView *_secondRowContainerView;
    UILabel *_rectangleCountLabel;
    UILabel *_rectangleCountValueLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (NSString *)xMinString
{
    return _xMinTextField.text;
}

- (NSString *)xMaxString
{
    return _xMaxTextField.text;
}

- (double)rectangleCountValue
{
    return _rectangleCountStepper.value;
}

- (NSString *)selectedFunctionSegmentTitle
{
    NSString *title;
    if (_functionSegmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
        title = [_functionSegmentedControl titleForSegmentAtIndex:_functionSegmentedControl.selectedSegmentIndex];
    }
    return title;
}

- (BOOL)addFunctionString:(NSString *)functionString
{
    BOOL added = NO;
    if ([_functionStrings count] < MAX_FUNCTIONS) {
        [_functionStrings addObject:functionString];
        [_functionSegmentedControl insertSegmentWithTitle:functionString atIndex:_functionSegmentedControl.numberOfSegments animated:NO];
        added = YES;
    }
    return added;
}

- (void)resignFirstResponder
{
    if ([_xMinTextField isFirstResponder]) {
        [_xMinTextField resignFirstResponder];
    } else if ([_xMaxTextField isFirstResponder]) {
        [_xMaxTextField resignFirstResponder];
    }
}

- (void)setXMinField:(NSString *)value
{
    _xMinTextField.text = value;
}

- (void)setXMaxField:(NSString *)value
{
    _xMaxTextField.text = value;
}

#pragma mark Private

- (void)setup
{
    _functionStrings = [[NSMutableArray alloc] initWithCapacity:MAX_FUNCTIONS];
    _axFunctionStrings = [[NSMutableArray alloc] initWithCapacity:MAX_FUNCTIONS];

    _functionSegmentedControl = [[UISegmentedControl alloc] init];
    _functionSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    _functionSegmentedControl.tintColor = [UIColor blackColor];
    _functionSegmentedControl.apportionsSegmentWidthsByContent = YES;
    [_functionSegmentedControl setTitleTextAttributes:@{UITextAttributeFont: FUNCTION_SEGEMENTS_FONT} forState:UIControlStateNormal];
    [_functionSegmentedControl addTarget:self action:@selector(functionSegmentDidUpdate:) forControlEvents:(UIControlEventValueChanged)];

    _xMinTextField = [[UITextField alloc] init];
    _xMinTextField.placeholder = X_MIN_PLACEHOLDER;
    _xMinTextField.backgroundColor = [UIColor whiteColor];
    _xMinTextField.borderStyle = UITextBorderStyleRoundedRect;
    _xMinTextField.delegate = self;
    _xMinTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _xMinTextField.clearsOnBeginEditing = YES;
    _xMinTextField.returnKeyType = UIReturnKeyDone;
    _xMinTextField.accessibilityLabel = X_MIN_AX_LABEL;
    
    _xMaxTextField = [[UITextField alloc] init];
    _xMaxTextField.placeholder = X_MAX_PLACEHOLDER;
    _xMaxTextField.backgroundColor = [UIColor whiteColor];
    _xMaxTextField.borderStyle = UITextBorderStyleRoundedRect;
    _xMaxTextField.delegate = self;
    _xMaxTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _xMaxTextField.clearsOnBeginEditing = YES;
    _xMaxTextField.returnKeyType = UIReturnKeyDone;
    _xMaxTextField.accessibilityLabel = X_MAX_AX_LABEL;

    _rectangleCountStepper = [[RectangleStepper alloc] init];
    _rectangleCountStepper.tintColor = [UIColor blackColor];
    _rectangleCountStepper.minimumValue = RECTANGLE_COUNT_MIN;
    _rectangleCountStepper.maximumValue = RECTANGLE_COUNT_MAX;
    _rectangleCountStepper.stepValue = RECTANGLE_COUNT_STEP_VALUE;
    [_rectangleCountStepper addTarget:self action:@selector(rectangleCountDidUpdate:) forControlEvents:UIControlEventValueChanged];

    _rectangleCountLabel = [[UILabel alloc] init];
    _rectangleCountLabel.backgroundColor = [UIColor clearColor];
    _rectangleCountLabel.text = RECTANGLE_COUNT_LABEL;
    _rectangleCountLabel.font = LABEL_FONT;
    _rectangleCountLabel.textColor = [UIColor darkTextColor];
    _rectangleCountLabel.isAccessibilityElement = NO;
    
    _rectangleCountValueLabel = [[UILabel alloc] init];
    _rectangleCountValueLabel.backgroundColor = [UIColor clearColor];
    _rectangleCountValueLabel.text = [NSString stringWithFormat:@"%d", (int)_rectangleCountStepper.value];
    _rectangleCountValueLabel.font = VALUE_FONT;
    _rectangleCountValueLabel.isAccessibilityElement = NO;
    
    _secondRowContainerView = [[UIView alloc] init];
    _secondRowContainerView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_functionSegmentedControl];
    [_secondRowContainerView addSubview:_xMinTextField];
    [_secondRowContainerView addSubview:_xMaxTextField];
    [_secondRowContainerView addSubview:_rectangleCountStepper];
    [_secondRowContainerView addSubview:_rectangleCountLabel];
    [_secondRowContainerView addSubview:_rectangleCountValueLabel];
    [self addSubview:_secondRowContainerView];

    
}

- (void)rectangleCountDidUpdate:(UIControl *)sender
{
    if (sender == _rectangleCountStepper) {
        [self resignFirstResponder];
        _rectangleCountValueLabel.text = [NSString stringWithFormat:@"%d", (int)_rectangleCountStepper.value];
        _rectangleCountStepper.accessibilityValue = RECTANGLE_STEPPER_AX_VALUE((int)_rectangleCountStepper.value);
        [_delegate rectangleCountStepperValueDidChange:_rectangleCountStepper];
    }
}

- (void)functionSegmentDidUpdate:(UIControl *)sender
{
    if (sender == _functionSegmentedControl) {
        [self resignFirstResponder];
        [_delegate functionSegmentSelectionDidChange:_functionSegmentedControl];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _xMinTextField) {
        [_delegate xMinTextFieldDidChange:textField];
    } else if (textField == _xMaxTextField){
        [_delegate xMaxTextFieldDidChange:textField];
    }
}

#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_functionSegmentedControl sizeToFit];
    CGSize functionControlSize = _functionSegmentedControl.frame.size;
    CGPoint functionControlOrigin = CGPointMake(floor((self.bounds.size.width - functionControlSize.width) / 2.0f), self.bounds.origin.y);
    _functionSegmentedControl.frame = CGRectMake(functionControlOrigin.x, functionControlOrigin.y, functionControlSize.width, functionControlSize.height);
    
    _secondRowContainerView.frame = CGRectMake(self.bounds.origin.x, CGRectGetMaxY(_functionSegmentedControl.frame) + VERTICAL_SPACER, self.bounds.size.width, self.bounds.size.height - _functionSegmentedControl.frame.size.height - VERTICAL_SPACER);
    
    [_xMinTextField sizeToFit];
    const CGSize xMinSize = _xMinTextField.frame.size;
    
    [_xMaxTextField sizeToFit];
    const CGSize xMaxSize = _xMaxTextField.frame.size;
    
    [_rectangleCountLabel sizeToFit];
    const CGSize stepperLabelSize = _rectangleCountLabel.frame.size;
    
    [_rectangleCountStepper sizeToFit];
    const CGSize stepperSize = _rectangleCountStepper.frame.size;
    
    const int sizingGuildInt = (int)_rectangleCountStepper.maximumValue * 10; // big enough for an extra digit
    const CGSize stepperValueSize = [[NSString stringWithFormat:@"%d", sizingGuildInt] sizeWithFont:_rectangleCountValueLabel.font constrainedToSize:_secondRowContainerView.bounds.size];
    
    const CGFloat actualWidth = xMinSize.width + HORIZANTAL_SPACER_SMALL + xMaxSize.width + HORIZANTAL_SPACER_LARGE + stepperLabelSize.width + HORIZANTAL_SPACER_SMALL + stepperSize.width + HORIZANTAL_SPACER_SMALL + stepperValueSize.width;
    
    _secondRowContainerView.frame = CGRectMake(floorf((CGRectGetMaxX(self.bounds) - actualWidth) / 2.0f), CGRectGetMaxY(_functionSegmentedControl.frame) + VERTICAL_SPACER, actualWidth, self.bounds.size.height - _functionSegmentedControl.frame.size.height - VERTICAL_SPACER);

    CGFloat x = _secondRowContainerView.bounds.origin.x;
    const CGFloat y = _secondRowContainerView.bounds.origin.y;
    
    // Setup xmin and xmax fields
    
    CGPoint xMinOrigin = CGPointMake(x, y);
    _xMinTextField.frame = CGRectMake(xMinOrigin.x, xMinOrigin.y, xMinSize.width, xMinSize.height);
    
    x = CGRectGetMaxX(_xMinTextField.frame) + HORIZANTAL_SPACER_SMALL;
    CGPoint xMaxOrigin = CGPointMake(x, y);
    _xMaxTextField.frame = CGRectMake(xMaxOrigin.x, xMaxOrigin.y, xMaxSize.width, xMaxSize.height);
    
    // Setup stepper and its labels
    
    x = CGRectGetMaxX(_xMaxTextField.frame) + HORIZANTAL_SPACER_LARGE;
    CGPoint stepperLabelOrigin = CGPointMake(x, y);
    _rectangleCountLabel.frame = CGRectMake(stepperLabelOrigin.x, stepperLabelOrigin.y, stepperLabelSize.width, stepperLabelSize.height);
    
    x = CGRectGetMaxX(_rectangleCountLabel.frame) + HORIZANTAL_SPACER_SMALL;
    CGPoint stepperOrigin = CGPointMake(x, y);
    _rectangleCountStepper.frame = CGRectMake(stepperOrigin.x, stepperOrigin.y, stepperSize.width, stepperSize.height);
    
    x = CGRectGetMaxX(_rectangleCountStepper.frame) + HORIZANTAL_SPACER_SMALL;
    CGPoint stepperValueOrigin = CGPointMake(x, y);
    _rectangleCountValueLabel.frame = CGRectMake(stepperValueOrigin.x, stepperValueOrigin.y, stepperValueSize.width, stepperValueSize.height);
    
    // Center text fields with stepper
    if (xMinSize.height > stepperSize.height) {
        _rectangleCountStepper.center = CGPointMake(_rectangleCountStepper.center.x, _xMinTextField.center.y);
    } else {
        _xMinTextField.center = CGPointMake(_xMinTextField.center.x, _rectangleCountStepper.center.y);
        _xMaxTextField.center = CGPointMake(_xMaxTextField.center.x, _rectangleCountStepper.center.y);

    }
    
    // Center align labels
    _rectangleCountLabel.center = CGPointMake(_rectangleCountLabel.center.x, _rectangleCountStepper.center.y);
    _rectangleCountValueLabel.center = CGPointMake(_rectangleCountValueLabel.center.x, _rectangleCountStepper.center.y);
    
    // Accessibility: Here we work around a known issue (radar# 14828925) where the segmented control
    // does not respect the accessibilityLabel properties on the NSStrings provided.
    NSArray *segments = [_functionSegmentedControl subviews];
    for (UIView *view in segments) {
        NSString *oldLabel = view.accessibilityLabel;
        NSUInteger index = [_functionStrings indexOfObject:oldLabel];
        if (index != NSNotFound) {
            view.accessibilityLabel = [_functionStrings[index] accessibilityLabel];
        }
    }
    
    CGRect axStepperFrame = CGRectMake(
                                       _rectangleCountLabel.frame.origin.x,
                                       _rectangleCountStepper.frame.origin.y,
                                       _rectangleCountLabel.frame.size.width + _rectangleCountStepper.frame.size.width + _rectangleCountValueLabel.frame.size.width,
                                       _rectangleCountStepper.frame.size.height);
    _rectangleCountStepper.accessibilityFrame = [_rectangleCountStepper.superview rs_screenCoordinatesForRect:axStepperFrame];
    
}

@end
