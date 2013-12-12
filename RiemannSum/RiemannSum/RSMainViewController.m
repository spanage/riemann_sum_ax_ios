//
//  RSMainViewController.m
//  RiemannSum
//
//  Created by Sommer Panage on 8/4/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import <math.h>
#import "RSControlsView.h"
#import "RSGraphView.h"
#import "RSMainViewController.h"
#import "RSRiemannModel.h"

// STRING CONSTANTS
#define ERROR_X_ALERT_TITLE @"Error"
#define ERROR_X_ALERT_MESSAGE @"You've entered an invalid x-value."
#define ERROR_X_ALERT_CANCEL @"OK"
#define TITLE @"Riemann Sum Demo"
#define SUM_FORMAT @"Riemann sum: %.02f"
#define INTEGRAL_FORMAT @"Actual value: %.02f"

// STYLE CONSTANTS
#define TITLE_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:30.0f])
#define TITLE_LINE_BREAK_MODE NSLineBreakByTruncatingTail
#define SUM_INTEGRAL_FONT ([UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f])
#define INTEGRAL_COLOR ([UIColor colorWithRed:0.6f green:0.0f blue:0.0f alpha:1.0f]);
#define BACKGROUND_COLOR ([UIColor colorWithWhite:0.9 alpha:1.0])

// LAYOUT CONSTANTS
#define TOP_MARGIN 20.0f
#define VERITICAL_SPACER ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (20.0f) : (10.0f))
#define CONTROLS_HEIGHT 120.0f
#define GRAPH_SIZE_IPHONE (CGSizeMake(300.0f, 200.0f))
#define GRAPH_SIZE_IPAD (CGSizeMake(600.0f, 400.0f))
#define GRAPH_SIZE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (GRAPH_SIZE_IPAD) : (GRAPH_SIZE_IPHONE))

@interface RSMainViewController () <RSControlsViewDelegate>

@end

@implementation RSMainViewController
{
    UILabel *_titleView;
    RSControlsView *_controlsView;
    RSGraphView *_graphView;
    UILabel *_sumView;
    UILabel *_integralView;
    
    NSNumberFormatter *_numberFormatter;
    
    NSArray *_functionStrings;
    NSDictionary *_functionDictionary;
    NSDictionary *_integralDictionary;
    
    RSRiemannModel *_currentModel;
    
    NSString *_previousXMinString;
    NSString *_previousXMaxString;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString *sineString = @"sin(x)";
        NSString *xSquaredString = @"x^2";
        NSString *xCubedString = @"x^3";

#if ACCESSIBLE
        sineString.accessibilityLabel = @"sine x";
        xSquaredString.accessibilityLabel = @"x squared";
        xCubedString.accessibilityLabel = @"x cubed";
#endif
        
        _functionStrings = @[sineString, xSquaredString, xCubedString];
        
        RSRiemannModelFunction sinFunction = ^(RSFloat x) {
            return (RSFloat) sinf((float)x);
        };
        RSRiemannModelFunction xSquaredFunction = ^(RSFloat x) {
            return (x * x);
        };
        RSRiemannModelFunction xCubedFunction = ^(RSFloat x) {
            return (x * x * x);
        };
        
        _functionDictionary = @{
                               _functionStrings[0] : sinFunction,
                               _functionStrings[1] : xSquaredFunction,
                               _functionStrings[2] : xCubedFunction};
        
        RSRiemannModelFunction sinIntegralFunction = ^(RSFloat x) {
            return (RSFloat) -cosf((float)x);
        };
        RSRiemannModelFunction xSquaredIntegralFunction = ^(RSFloat x) {
            return (x * x * x * (1.0f / 3.0f));
        };
        RSRiemannModelFunction xCubedIntegralFunction = ^(RSFloat x) {
            return (x * x * x * x * 0.25f);
        };
        
        _integralDictionary = @{
                                _functionStrings[0] : sinIntegralFunction,
                                _functionStrings[1] : xSquaredIntegralFunction,
                                _functionStrings[2] : xCubedIntegralFunction};
                
        _currentModel = [[RSRiemannModel alloc] init];
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.locale = [NSLocale currentLocale];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = BACKGROUND_COLOR;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMainView)]];
    
    _titleView = [[UILabel alloc] init];
    _titleView.text = TITLE;
    _titleView.lineBreakMode = TITLE_LINE_BREAK_MODE;
    _titleView.font = TITLE_FONT;
    _titleView.backgroundColor = [UIColor clearColor];
    _titleView.textColor = [UIColor darkTextColor];
#if ACCESSIBLE
    _titleView.accessibilityTraits |= UIAccessibilityTraitHeader;
#endif
    
    _controlsView = [[RSControlsView alloc] init];
    _controlsView.delegate = self;
    for (NSString *functionString in [_functionDictionary allKeys]) {
        if (![_controlsView addFunctionString:functionString]){
            break;
        }
    }
    
    _graphView = [[RSGraphView alloc] initWithBackingModel:_currentModel];
    
    _sumView = [[UILabel alloc] init];
    _sumView.font = SUM_INTEGRAL_FONT;
    _sumView.backgroundColor = [UIColor clearColor];
    _sumView.textColor = [UIColor blackColor];
    
    _integralView = [[UILabel alloc] init];
    _integralView.font = SUM_INTEGRAL_FONT;
    _integralView.backgroundColor = [UIColor clearColor];
    _integralView.textColor = INTEGRAL_COLOR;
    
    [self.view addSubview:_titleView];
    [self.view addSubview:_controlsView];
    [self.view addSubview:_graphView];
    [self.view addSubview:_sumView];
    [self.view addSubview:_integralView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RSFloat xMin;
    if ([self parseFloatFromString:_controlsView.xMinString value:&xMin]) {
        _currentModel.xMin = xMin;
    }
    _previousXMinString = _controlsView.xMinString;
    
    RSFloat xMax;
    if ([self parseFloatFromString:_controlsView.xMaxString value:&xMax]) {
        _currentModel.xMax = xMax;
    }
    _previousXMaxString = _controlsView.xMaxString;

    _currentModel.intervalCount = _controlsView.rectangleCountValue;
    if (_controlsView.selectedFunctionSegmentTitle) {
        _currentModel.function = [_functionDictionary objectForKey:_controlsView.selectedFunctionSegmentTitle];
        _currentModel.integratedFunction = [_integralDictionary objectForKey:_controlsView.selectedFunctionSegmentTitle];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_titleView sizeToFit];
    CGPoint textOrigin = CGPointMake(floorf((self.view.bounds.size.width - _titleView.frame.size.width) / 2.0f), TOP_MARGIN);
    _titleView.frame = CGRectMake(textOrigin.x, textOrigin.y, _titleView.frame.size.width, _titleView.frame.size.height);
    
    CGSize controlsSize = CGSizeMake(self.view.bounds.size.width, CONTROLS_HEIGHT);
    CGPoint controlOrigin = CGPointMake(floorf((self.view.bounds.size.width - controlsSize.width) / 2.0f), CGRectGetMaxY(_titleView.frame));
    _controlsView.frame = CGRectMake(controlOrigin.x, controlOrigin.y + VERITICAL_SPACER, controlsSize.width, controlsSize.height);
    
    CGSize graphSize = GRAPH_SIZE;
    CGPoint graphOrigin = CGPointMake(floorf((self.view.bounds.size.width - graphSize.width) / 2.0f), CGRectGetMaxY(_controlsView.frame) + VERITICAL_SPACER);
    _graphView.frame = CGRectMake(graphOrigin.x, graphOrigin.y, graphSize.width, graphSize.height);
    
    [_sumView sizeToFit];
    CGPoint sumOrigin = CGPointMake(floorf((self.view.bounds.size.width - _sumView.frame.size.width) / 2.0f), CGRectGetMaxY(_graphView.frame) + VERITICAL_SPACER);
    _sumView.frame = CGRectMake(sumOrigin.x, sumOrigin.y, _sumView.frame.size.width, _sumView.frame.size.height);
    
    [_integralView sizeToFit];
    CGPoint integralOrigin = CGPointMake(floorf((self.view.bounds.size.width - _integralView.frame.size.width) / 2.0f), CGRectGetMaxY(_sumView.frame));
    _integralView.frame = CGRectMake(integralOrigin.x, integralOrigin.y, _integralView.frame.size.width, _integralView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showInputError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_X_ALERT_TITLE message:ERROR_X_ALERT_MESSAGE delegate:nil cancelButtonTitle:ERROR_X_ALERT_CANCEL otherButtonTitles: nil];
    [alert show];
}

#pragma mark RSControlsViewDelegate

- (void)xMinTextFieldDidChange:(UITextField *)sender
{
    RSFloat value;
    const BOOL success = [self parseFloatFromString:sender.text value:&value];
    const BOOL shouldUpdateX = (_currentModel.xMin != value) || _currentModel.error;
    
    if (success && shouldUpdateX) {
        _currentModel.xMin = value;
        [_graphView update];
        [self updateResultsViews];
        _previousXMinString = _controlsView.xMinString;
    } else {
        if (!success && [sender.text length]) {
            [self showInputError];
        }
        [_controlsView setXMinField:_previousXMinString];
    }
}

- (void)xMaxTextFieldDidChange:(UITextField *)sender
{
    RSFloat value;
    const BOOL success = [self parseFloatFromString:sender.text value:&value];
    const BOOL shouldUpdateX = (_currentModel.xMax != value) || _currentModel.error;
    
    if (success && shouldUpdateX) {
        _currentModel.xMax = value;
        [_graphView update];
        [self updateResultsViews];
        _previousXMaxString = _controlsView.xMaxString;
    } else {
        if (!success && [sender.text length]) {
            [self showInputError];
        }
        [_controlsView setXMaxField:_previousXMaxString];
    }
}

- (void)functionSegmentSelectionDidChange:(UISegmentedControl *)sender
{
    NSString *key = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    RSRiemannModelFunction newFunction = [_functionDictionary objectForKey:key];
    RSRiemannModelFunction newIntegratedFunction = [_integralDictionary objectForKey:key];
    if (newFunction && newIntegratedFunction && _currentModel.function != newFunction) {
        _currentModel.function = newFunction;
        _currentModel.integratedFunction = newIntegratedFunction;
        [_graphView update];
        [self updateResultsViews];
    }
}

- (void)rectangleCountStepperValueDidChange:(UIStepper *)sender
{
    if (_currentModel.intervalCount != sender.value) {
        _currentModel.intervalCount = sender.value;
        [_graphView update];
        [self updateResultsViews];
    }
}

#pragma mark Private

- (void)didTapMainView
{
    [_controlsView resignFirstResponder];
}

- (BOOL)parseFloatFromString:(NSString *)floatString value:(RSFloat *)value;
{
    BOOL success = NO;

    if (floatString) {
        NSScanner *scanner = [NSScanner localizedScannerWithString:floatString];
        double result;
        if ([scanner scanDouble:&result] && [scanner isAtEnd]) {
            *value = result;
            success = YES;
       
        }
    }
    return success;
}

- (void)updateResultsViews
{
    if (_currentModel.error) {
        _sumView.text = @"";
        _integralView.text = @"";
    } else {
        _sumView.text = [NSString stringWithFormat:SUM_FORMAT, _currentModel.sum];
        _integralView.text = [NSString stringWithFormat:INTEGRAL_FORMAT, _currentModel.integratedValue];
    }
    [self.view setNeedsLayout];
}

@end
