//
//  JAButtonWithBlur.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface JAButtonWithBlur : FXBlurView

@property (assign, nonatomic) UIInterfaceOrientation orienation;

- (instancetype)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;

- (void) addButton:(NSString*)name target:(id)target action:(SEL)action;

@end
