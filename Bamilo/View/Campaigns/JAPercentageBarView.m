//
//  JAPercentageBarView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPercentageBarView.h"

@interface JAPercentageBarView()

@property (nonatomic, strong)UIView* percentageBar;

@end

@implementation JAPercentageBarView

- (void)loadWithPercentage:(NSInteger)percentage;
{
    self.backgroundColor = JABlack400Color;
    
    if(VALID_NOTEMPTY(self.percentageBar, UIView)){
        [self.percentageBar removeFromSuperview];
    }
    
    CGFloat widthFromPercentage = self.frame.size.width * percentage / 100;
    
    self.percentageBar = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                 self.bounds.origin.y,
                                                                 widthFromPercentage,
                                                                  self.bounds.size.height)];
    if (percentage > 64) {
        self.percentageBar.backgroundColor = JAGreen1Color;
    } else if (percentage > 34) {
        self.percentageBar.backgroundColor = JAYellow1Color;
    } else {
        self.percentageBar.backgroundColor = JARed1Color;
    }
    
    [self addSubview:self.percentageBar];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
