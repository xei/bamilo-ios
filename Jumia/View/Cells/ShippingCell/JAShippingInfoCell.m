//
//  JAShippingInfoCell.m
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingInfoCell.h"

@interface JAShippingInfoCell () {
    UILabel *_shippingFeeAlert;
}

@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *labelSeparator;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation JAShippingInfoCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

-(void)loadWithShippingFee:(NSString *)shippingFee
              deliveryTime:(NSString *)deliveryTime
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.frame = self.bounds;
    
    NSDictionary* shippingFeeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* shippingFeeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    NSString *shippingFeeLabel = STRING_SHIPPING_FEE;
    NSRange shippingFeeRange = NSMakeRange(0, shippingFeeLabel.length);
    NSMutableAttributedString *finalshippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeLabel, shippingFee]
                                                                                               attributes:shippingFeeAttributes];
    
    [finalshippingFeeString setAttributes:shippingFeeLabelAttributes
                                    range:shippingFeeRange];
    
    
    [self.label setAttributedText:finalshippingFeeString];
    
    // this triggers the constraints error output
    self.label.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.frame = CGRectMake(27.0f,
                                  0.0f,
                                  self.contentView.frame.size.width - 27.0f - 17.0f,
                                  self.label.frame.size.height);
    [self.label sizeToFit];
    
    if (!_shippingFeeAlert) {
        _shippingFeeAlert = [[UILabel alloc] initWithFrame:CGRectMake(self.label.x, CGRectGetMaxY(self.label.frame) + 4, self.contentView.width, self.label.height)];
        [self.contentView addSubview:_shippingFeeAlert];
    }
    
    [_shippingFeeAlert setTextColor:self.label.textColor];
    [_shippingFeeAlert setText:STRING_SHIPPING_FEE_INFO];
    [_shippingFeeAlert setFont:[UIFont fontWithName:kFontLightName size:11.0f]];
    [_shippingFeeAlert sizeToFit];
    
    if (![shippingFee isEqualToString:STRING_FREE]) {
        [_shippingFeeAlert setHidden:NO];
        [_shippingFeeAlert setY:CGRectGetMaxY(self.label.frame) + 4];
    }else{
        [_shippingFeeAlert setHidden:YES];
        [_shippingFeeAlert setY:self.label.y];
    }
    
    NSDictionary* deliveryTimeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* deliveryTimeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    NSString *deliveryTimeString = STRING_DELIVERY_TIME;
    NSRange deliveryTimeRange = NSMakeRange(0, deliveryTimeString.length);
    NSMutableAttributedString *finalDeliveryTimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", deliveryTimeString, deliveryTime]
                                                                                                attributes:deliveryTimeAttributes];
    
    [finalDeliveryTimeString setAttributes:deliveryTimeLabelAttributes
                                     range:deliveryTimeRange];
    
    
    [self.deliveryTimeLabel setAttributedText:finalDeliveryTimeString];
    
    // this triggers the constraints error output
    self.deliveryTimeLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.deliveryTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.deliveryTimeLabel.frame = CGRectMake(27.0f,
                                              CGRectGetMaxY(_shippingFeeAlert.frame) + 4,
                                              self.contentView.frame.size.width - 27.0f - 17.0f,
                                              self.label.frame.size.height);
    
    self.separator.translatesAutoresizingMaskIntoConstraints = YES;
    self.separator.frame = CGRectMake(0.0f,
                                      self.contentView.frame.size.height - 1.0f,
                                      self.contentView.frame.size.width,
                                      1.0f);
    
    if (RI_IS_RTL) {
        [self.contentView flipAllSubviews];
    }
}

-(void)loadWithPickupStation
{
    [self.label setText:STRING_PLEASE_SELECT];
}

-(void)setPickupStationRegion:(NSString*)pickupStationRegion
{
    [self.label setTextColor:UIColorFromRGB(0x666666)];
    [self.label setText:pickupStationRegion];
}

@end
