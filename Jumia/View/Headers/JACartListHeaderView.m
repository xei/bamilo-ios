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
    
    [self setBackgroundColor:JAWhiteColor];
    
    self.title.frame = CGRectMake(6.0f,
                                  self.title.frame.origin.y,
                                  width - 2*6.0f,
                                  self.title.frame.size.height);
    self.title.font = [UIFont fontWithName:kFontRegularName size:self.title.font.pointSize];
    self.title.textAlignment = NSTextAlignmentLeft;
    [self.title setText:text];
    [self.title setTextColor:JAButtonTextOrange];
    
    self.separator.frame = CGRectMake(0.0f,
                                      self.separator.frame.origin.y,
                                      width,
                                      1.0f);
    [self.separator setBackgroundColor:JAOrange1Color];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
