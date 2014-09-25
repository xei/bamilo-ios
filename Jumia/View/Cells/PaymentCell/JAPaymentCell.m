//
//  JAPaymentCell.m
//  Jumia
//
//  Created by Pedro Lopes on 10/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPaymentCell.h"
#import "RIPaymentMethodFormOption.h"
#import "JACheckoutForms.h"

@interface JAPaymentCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (strong, nonatomic) UIView *paymentMethodDetailsView;
@property (strong, nonatomic) RIPaymentMethodFormOption *paymentMethod;

@end

@implementation JAPaymentCell

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView
{
    self.paymentMethod = paymentMethod;
    
    [self.label setText:paymentMethod.label];
    
    if(VALID_NOTEMPTY(self.separator, UIView))
    {
        [self.separator removeFromSuperview];
    }
    
    self.paymentMethodDetailsView = paymentMethodView;
    [self.paymentMethodDetailsView setHidden:YES];
    [self addSubview:self.paymentMethodDetailsView];
    
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
    
    [self.paymentMethodDetailsView setFrame:CGRectMake(0.0f,
                                                       self.frame.size.height,
                                                       self.paymentMethodDetailsView.frame.size.width,
                                                       self.paymentMethodDetailsView.frame.size.height)];    
    [self.paymentMethodDetailsView setHidden:NO];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              44.0f + self.paymentMethodDetailsView.frame.size.height)];
    
    [self.separator setFrame:CGRectMake(0.0f,
                                        self.frame.size.height - 1.0f,
                                        self.frame.size.width,
                                        1.0f)];
}

-(void)deselectPaymentMethod
{
    [self.checkMark setHidden:YES];
    [self.paymentMethodDetailsView setHidden:YES];
    
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
