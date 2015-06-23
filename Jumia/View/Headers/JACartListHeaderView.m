//
//  JACartListHeaderView.m
//  Jumia
//
//  Created by Pedro Lopes on 28/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACartListHeaderView.h"

@implementation JACartListHeaderView

- (void)awakeFromNib {
    // Initialization code
}

- (void) loadHeaderWithText:(NSString*)text width:(CGFloat)width
{
    [self setFrame:CGRectMake(0.0f,
                              0.0f,
                              width,
                              27.0f)];
    
    [self setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    self.title.font = [UIFont fontWithName:kFontRegularName size:self.title.font.pointSize];
    self.title.textAlignment = NSTextAlignmentLeft;
    [self.title setText:text];
    [self.title setTextColor:UIColorFromRGB(0x4e4e4e)];
    
    [self.separator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
