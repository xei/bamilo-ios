//
//  JAPaymentCell.m
//  Jumia
//
//  Created by Pedro Lopes on 10/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPaymentCell.h"
#import "RIPaymentMethodFormOption.h"

@interface JAPaymentCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;

@end

@implementation JAPaymentCell

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)shippingMethod
{
    [self.label setText:shippingMethod.label];
    
    if(VALID_NOTEMPTY(self.separator, UIView))
    {
        [self.separator removeFromSuperview];
    }
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               self.frame.size.height - 1.0f,
                                                               self.frame.size.width,
                                                               1.0f)];
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self addSubview:self.separator];
}

-(void)selectPaymentMethod
{
    [self.checkMark setHidden:NO];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              84.0f)];
    [self.separator setFrame:CGRectMake(0.0f,
                                         self.frame.size.height - 1.0f,
                                         self.frame.size.width,
                                         1.0f)];
}

-(void)deselectPaymentMethod
{
    [self.checkMark setHidden:YES];
   
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              44.0f)];
    [self.separator setFrame:CGRectMake(0.0f,
                                         self.frame.size.height - 1.0f,
                                         self.frame.size.width,
                                         1.0f)];
}

@end
