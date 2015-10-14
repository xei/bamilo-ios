//
//  JACheckoutBottom.h
//  Jumia
//
//  Created by josemota on 7/27/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAButtonWithBlur.h"

@interface JACheckoutBottomView : UIView

@property (nonatomic) BOOL noTotal;
@property (nonatomic) NSString *totalValue;

- (instancetype)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;

- (void)setButtonText:(NSString *)text target:(id)target action:(SEL)selector;
- (void)disableButton;

@end
