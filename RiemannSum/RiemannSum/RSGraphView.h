//
//  RSGraphView.h
//  RiemannSum
//
//  Created by Sommer Panage on 8/11/13.
//  Copyright (c) 2013 Sommer Panage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSRiemannModel;

@interface RSGraphView : UIView

// TODO: Bool to toggle show graph on/off
- (id)initWithBackingModel:(RSRiemannModel *)backingModel;
- (void)update;

@end
