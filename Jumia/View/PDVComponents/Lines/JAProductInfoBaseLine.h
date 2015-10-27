//
//  JAProductInfoBaseLine.h
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@interface JAProductInfoBaseLine : JAClickableView

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic) BOOL topSeparatorVisibility;
@property (nonatomic) BOOL bottomSeparatorVisibility;
@property (nonatomic) UIColor *topSeparatorColor;
@property (nonatomic) UIColor *bottomSeparatorColor;
@property (nonatomic) CGFloat topSeparatorXOffset;
@property (nonatomic) CGFloat topSeparatorBorderWidth;
@property (nonatomic) CGFloat bottomSeparatorBorderWidth;
@property (nonatomic) CGFloat bottomSeparatorXOffset;

- (void)setTitle:(NSString *)title;

@end
