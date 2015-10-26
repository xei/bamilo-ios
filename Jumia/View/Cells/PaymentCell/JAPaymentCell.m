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

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView isSelected:(BOOL)isSelected
{
    self.paymentMethod = paymentMethod;
    
    if(VALID_NOTEMPTY(self.separator, UIView))
    {
        [self.separator removeFromSuperview];
    }
    self.separator = [[UIView alloc] init];
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self addSubview:self.separator];
    
    self.paymentMethodDetailsView = paymentMethodView;
    [self.paymentMethodDetailsView setHidden:YES];
    [self addSubview:self.paymentMethodDetailsView];
    
    // this triggers the constraints error output
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (isSelected) {
        [self.checkMark setHidden:NO];
        [self.paymentMethodDetailsView setHidden:NO];
        
        [self.paymentMethodDetailsView setFrame:CGRectMake(0.0f,
                                                           44.0f,
                                                           self.paymentMethodDetailsView.frame.size.width,
                                                           self.paymentMethodDetailsView.frame.size.height)];
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  44.0f + self.paymentMethodDetailsView.frame.size.height)];
        
        [self.clickableView setFrame:self.bounds];
        self.clickableView.enabled = NO;

    } else {
    
        [self.checkMark setHidden:YES];
        [self.paymentMethodDetailsView setHidden:YES];
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  44.0f)];
        
        [self.clickableView setFrame:self.bounds];
        self.clickableView.enabled = YES;
    
    }
    
    [self.separator setFrame:CGRectMake(0.0f,
                                        self.frame.size.height - 1.0f,
                                        self.frame.size.width,
                                        1.0f)];
    
    // this triggers the constraints error output
    self.label.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.label.font = [UIFont fontWithName:kFontLightName size:self.label.font.pointSize];
    self.label.textAlignment = NSTextAlignmentLeft;
    [self.label setText:paymentMethod.label];
    
    self.label.frame = CGRectMake(17.0f,
                                  11.0f,
                                  self.clickableView.frame.size.width - self.checkMark.frame.size.width - 14.0f*2,
                                  self.label.frame.size.height);
    
    self.checkMark.translatesAutoresizingMaskIntoConstraints = YES;
    self.checkMark.frame = CGRectMake(self.clickableView.frame.size.width - self.checkMark.frame.size.width - 14.0f,
                                      15.0f,
                                      self.checkMark.frame.size.width,
                                      self.checkMark.frame.size.height);
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
    }
}

-(void)loadNoPaymentMethod:(NSString *)paymentMethod paymentMethodView:(UIView*)paymentMethodView {
    
    if(VALID_NOTEMPTY(self.separator, UIView))
    {
        [self.separator removeFromSuperview];
    }
    self.separator = [[UIView alloc] init];
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self addSubview:self.separator];
    
    self.paymentMethodDetailsView = paymentMethodView;
    [self.paymentMethodDetailsView setY:11.f];
    [self.paymentMethodDetailsView setHidden:NO];
    [self addSubview:self.paymentMethodDetailsView];
    
    // this triggers the constraints error output
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.checkMark setHidden:YES];
    [self.separator setFrame:CGRectMake(0.0f,
                                        self.frame.size.height - 1.0f,
                                        self.frame.size.width,
                                        1.0f)];
    [self.label setHidden:YES];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              4004.0f)];
    
    [self.clickableView setFrame:self.bounds];
    self.clickableView.enabled = YES;
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
    }
}

@end
