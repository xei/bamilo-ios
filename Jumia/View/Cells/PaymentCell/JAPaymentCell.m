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

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *checkMark;
@property (strong, nonatomic) UIView *paymentMethodDetailsView;
@property (strong, nonatomic) RIPaymentMethodFormOption *paymentMethod;

@end

@implementation JAPaymentCell

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView isSelected:(BOOL)isSelected width:(CGFloat)width
{
    self.paymentMethod = paymentMethod;
    
    if (!self.clickableView) {
        self.clickableView = [[JAClickableView alloc] init];
        [self addSubview:self.clickableView];
    }
    
    [self.paymentMethodDetailsView removeFromSuperview];
    self.paymentMethodDetailsView = paymentMethodView;
    [self.paymentMethodDetailsView setHidden:YES];
    [self.clickableView addSubview:self.paymentMethodDetailsView];
    
    UIImage* checkMarkImageSelected = [UIImage imageNamed:@"round_checkbox_selected"];
    UIImage* checkMarkImageDeselected = [UIImage imageNamed:@"round_checkbox_deselected"];
    if (!self.checkMark) {
        self.checkMark = [[UIImageView alloc] initWithImage:checkMarkImageSelected];
        [self.clickableView addSubview:self.checkMark];
    }
    self.checkMark.frame = CGRectMake(16.f,
                                      10.0f,
                                      checkMarkImageSelected.size.width,
                                      checkMarkImageSelected.size.height);
    
    if (isSelected) {
        [self.checkMark setImage:checkMarkImageSelected];
        [self.paymentMethodDetailsView setHidden:NO];
        
        [self.paymentMethodDetailsView setFrame:CGRectMake([JAPaymentCell xPositionAfterCheckmark],
                                                           44.0f,
                                                           self.paymentMethodDetailsView.frame.size.width,
                                                           self.paymentMethodDetailsView.frame.size.height)];
        for (UILabel* label in self.paymentMethodDetailsView.subviews) {
            if (VALID_NOTEMPTY_VALUE(label, UILabel)) {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
        }
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  width,
                                  44.0f + self.paymentMethodDetailsView.frame.size.height)];
        
        [self.clickableView setFrame:self.bounds];
        self.clickableView.enabled = NO;

    } else {
    
        [self.checkMark setImage:checkMarkImageDeselected];
        [self.paymentMethodDetailsView setHidden:YES];
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  width,
                                  44.0f)];
        
        [self.clickableView setFrame:self.bounds];
        self.clickableView.enabled = YES;
    
    }

    if (!self.label) {
        self.label = [[UILabel alloc] init];
        [self.label setFont:JAListFont];
        [self.label setTextColor:JABlackColor];
        [self.clickableView addSubview:self.label];
    }
    [self.label setTextAlignment:NSTextAlignmentLeft];
    [self.label setText:paymentMethod.label];
    [self.label sizeToFit];
    
    self.label.frame = CGRectMake(CGRectGetMaxX(self.checkMark.frame) + 5.0f,
                                  13.0f,
                                  self.clickableView.frame.size.width - self.checkMark.frame.size.width - 16.0f*2 - 5.0f,
                                  self.label.frame.size.height);
    
    if (RI_IS_RTL) {
        [self.clickableView flipViewPositionInsideSuperview];
        [self.paymentMethodDetailsView flipSubviewAlignments];
        [self.paymentMethodDetailsView flipViewPositionInsideSuperview];
        [self.checkMark flipViewPositionInsideSuperview];
        [self.label flipViewPositionInsideSuperview];
        [self.label setTextAlignment:NSTextAlignmentRight];
    }
}

-(void)loadNoPaymentMethod:(NSString *)paymentMethod paymentMethodView:(UIView*)paymentMethodView
{
    [self.paymentMethodDetailsView removeFromSuperview];
    self.paymentMethodDetailsView = paymentMethodView;
    [self.paymentMethodDetailsView setY:11.f];
    [self.paymentMethodDetailsView setHidden:NO];
    [self addSubview:self.paymentMethodDetailsView];
    
    [self.checkMark setHidden:YES];

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

+ (CGFloat)xPositionAfterCheckmark
{
    UIImage* checkMarkImageSelected = [UIImage imageNamed:@"round_checkbox_selected"];
    return 16.0f + checkMarkImageSelected.size.width + 5.0f;
}

@end
