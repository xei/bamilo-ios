//
//  JAShippingCell.m
//  Jumia
//
//  Created by Pedro Lopes on 06/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingCell.h"

@interface JAShippingCell ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *checkMarkImageView;

@end

@implementation JAShippingCell

-(void)loadWithShippingMethod:(RIShippingMethod *)shippingMethod
{
    if (!self.clickableView) {
        self.clickableView = [[JAClickableView alloc] init];
        [self addSubview:self.clickableView];
    }
    self.clickableView.frame = self.bounds;
    
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_deselected"];
    if (!self.checkMarkImageView) {
        self.checkMarkImageView = [[UIImageView alloc] initWithImage:checkMarkImage];
        [self.clickableView addSubview:self.checkMarkImageView];
    }
    self.checkMarkImageView.frame = CGRectMake(16.0f,
                                               (self.clickableView.frame.size.height - checkMarkImage.size.height) / 2,
                                               checkMarkImage.size.width,
                                               checkMarkImage.size.height);
    
    if (!self.label) {
        self.label = [UILabel new];
        [self.clickableView addSubview:self.label];
        self.label.font = JAListFont;
        self.label.textAlignment = NSTextAlignmentLeft;
    }
    [self.label setText:[shippingMethod label]];
    self.label.frame = CGRectMake(CGRectGetMaxX(self.checkMarkImageView.frame) + 8.0f,
                                  0.0f,
                                  self.clickableView.frame.size.width - self.checkMarkImageView.frame.size.width - 16.0f*2 - 8.0f,
                                  self.clickableView.frame.size.height);
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
    
}

-(void)selectShippingMethod
{
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_selected"];
    [self.checkMarkImageView setImage:checkMarkImage];
}

-(void)deselectShippingMethod
{
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_deselected"];
    [self.checkMarkImageView setImage:checkMarkImage];
}

@end
