//
//  JACTAButtons.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACTAButtons.h"

@implementation JACTAButtons

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JACTAButtons *)getNewPDVCTAButtons
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACTAButtons"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACTAButtons class]]) {
            return (JACTAButtons *)obj;
        }
    }
    
    return nil;
}

- (void)layoutView
{    
    UIFont *buttonsFont = [UIFont fontWithName:@"HelveticaNeue"
                                          size:16.0];
    
    self.addToCartButton.titleLabel.font = buttonsFont;
    self.callToOrderButton.titleLabel.font = buttonsFont;
    
    [self.addToCartButton setTitle:@"Add to Cart"
                          forState:UIControlStateNormal];
    
    [self.callToOrderButton setTitle:@"Call to Order"
                            forState:UIControlStateNormal];
    
    self.addToCartButton.layer.cornerRadius = 4.0f;
    
    self.callToOrderButton.layer.cornerRadius = 4.0f;
    self.callToOrderButton.layer.borderWidth = 1.0f;
    self.callToOrderButton.layer.borderColor = (__bridge CGColorRef)([UIColor colorWithRed:78.0/255.0 green:78.0/255.0 blue:78.0/255.0 alpha:1.0f]);
}

@end
