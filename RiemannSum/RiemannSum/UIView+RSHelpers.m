//
//  UIView+RSHelpers.m
//  RiemannSum
//
//  Created by Sommer Panage on 8/31/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import "UIView+RSHelpers.h"

@implementation UIView (RSHelpers)

- (CGRect)rs_screenCoordinatesForRect:(CGRect)rect
{
    CGRect windowFrame = [self convertRect:rect toView:self.window];
    return [self.window convertRect:windowFrame toWindow:nil];
}

@end
