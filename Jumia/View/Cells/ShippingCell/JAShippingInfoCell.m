//
//  JAShippingInfoCell.m
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingInfoCell.h"

@interface JAShippingInfoCell () {}

@property (strong, nonatomic) UILabel *deliveryTimeLabel;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *labelSeparator;
@property (strong, nonatomic) UILabel *shippingFeeAlert;

@property (nonatomic, strong) UIView* separator;
@property (nonatomic, strong) UIImageView* dropdownImageView;
@property (nonatomic, strong) UILabel* regionLabel;

@end

@implementation JAShippingInfoCell

-(void)loadWithShippingFee:(NSString *)shippingFee
              deliveryTime:(NSString *)deliveryTime
{
    if (!self.label) {
        self.label = [UILabel new];
        self.label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.label];
    }
    NSDictionary* shippingFeeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABodyFont, NSFontAttributeName, JABlackColor, NSForegroundColorAttributeName, nil];
    NSDictionary* shippingFeeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABodyFont, NSFontAttributeName, JABlack800Color, NSForegroundColorAttributeName, nil];
    NSString *shippingFeeString = STRING_SHIPPING_FEE;
    NSRange shippingFeeRange = NSMakeRange(0, shippingFeeString.length);
    NSMutableAttributedString *finalshippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeString, shippingFee]
                                                                                               attributes:shippingFeeAttributes];
    
    [finalshippingFeeString setAttributes:shippingFeeLabelAttributes
                                    range:shippingFeeRange];
    
    [self.label setAttributedText:finalshippingFeeString];
    self.label.frame = CGRectMake(48.0f,
                                  0.0f,
                                  self.frame.size.width - 48.0f - 16.0f,
                                  self.label.frame.size.height);
    [self.label sizeToFit];
    
    if (!self.shippingFeeAlert) {
        self.shippingFeeAlert = [[UILabel alloc] init];
        [self addSubview:self.shippingFeeAlert];
        [self.shippingFeeAlert setTextColor:JABlack800Color];
        [self.shippingFeeAlert setFont:JABodyFont];
    }
    
    self.shippingFeeAlert.frame = CGRectMake(48.0f,
                                             CGRectGetMaxY(self.label.frame) + 4,
                                             self.frame.size.width,
                                             self.label.height);
    [self.shippingFeeAlert setText:STRING_SHIPPING_FEE_INFO];
    [self.shippingFeeAlert sizeToFit];
    
    if (![shippingFee isEqualToString:STRING_FREE]) {
        [self.shippingFeeAlert setHidden:NO];
        [self.shippingFeeAlert setY:CGRectGetMaxY(self.label.frame) + 4];
    }else{
        [self.shippingFeeAlert setHidden:YES];
        [self.shippingFeeAlert setY:self.label.y];
    }
    
    if (!self.deliveryTimeLabel) {
        self.deliveryTimeLabel = [UILabel new];
        self.deliveryTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.deliveryTimeLabel];
    }
    
    NSDictionary* deliveryTimeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABodyFont, NSFontAttributeName, JABlackColor, NSForegroundColorAttributeName, nil];
    NSDictionary* deliveryTimeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABodyFont, NSFontAttributeName, JABlack800Color, NSForegroundColorAttributeName, nil];
    
    NSString *deliveryTimeString = STRING_DELIVERY_TIME;
    NSRange deliveryTimeRange = NSMakeRange(0, deliveryTimeString.length);
    NSMutableAttributedString *finalDeliveryTimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", deliveryTimeString, deliveryTime]
                                                                                                attributes:deliveryTimeAttributes];
    
    [finalDeliveryTimeString setAttributes:deliveryTimeLabelAttributes
                                     range:deliveryTimeRange];

    [self.deliveryTimeLabel setAttributedText:finalDeliveryTimeString];
    
    self.deliveryTimeLabel.frame = CGRectMake(48.0f,
                                              CGRectGetMaxY(_shippingFeeAlert.frame) + 4,
                                              self.frame.size.width - 27.0f - 17.0f,
                                              self.label.frame.size.height);
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

-(void)loadWithPickupStationWidth:(CGFloat)width
{
    if (!self.label) {
        self.label = [UILabel new];
        self.label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.label];
    }
    self.label.font = JABodyFont;
    self.label.textColor = JABlack800Color;
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.frame = CGRectMake(16.0f,
                                  0.0f,
                                  width - 27.0f - 17.0f,
                                  self.label.frame.size.height);
    [self.label setText:STRING_PLEASE_SELECT];
    [self.label sizeToFit];
    
    if (!self.separator) {
        self.separator = [UIView new];
        [self addSubview:self.separator];
        self.separator.backgroundColor = JABlack400Color;
    }
    self.separator.frame = CGRectMake(16.0f,
                                      49.0f,
                                      width - 16.0f,
                                      1.0f);

    UIImage* dropdownImage = [UIImage imageNamed:@"ic_dropdown"];
    if (!self.dropdownImageView) {
        self.dropdownImageView = [[UIImageView alloc] initWithImage:dropdownImage];
        [self addSubview:self.dropdownImageView];
    }
    self.dropdownImageView.frame = CGRectMake(width - 16.0f - dropdownImage.size.width,
                                              30.0f,
                                              dropdownImage.size.width,
                                              dropdownImage.size.height);
    
    if (!self.regionLabel) {
        self.regionLabel = [[UILabel alloc] init];
        self.regionLabel.textColor = JABlackColor;
        self.regionLabel.font = JABodyFont;
        [self addSubview:self.regionLabel];
    }
    self.regionLabel.textAlignment = NSTextAlignmentLeft;
    self.regionLabel.frame = CGRectMake(16.0f,
                                        20.0f,
                                        width - 16.0f*2 - self.dropdownImageView.frame.size.width,
                                        20.0f);
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

-(void)setPickupStationRegion:(NSString*)pickupStationRegion
{
    [self.regionLabel setText:pickupStationRegion];
}

@end
