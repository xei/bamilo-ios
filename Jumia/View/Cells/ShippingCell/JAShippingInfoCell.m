//
//  JAShippingInfoCell.m
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingInfoCell.h"

@interface JAShippingInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *labelSeparator;

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
    NSDictionary* shippingFeeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* shippingFeeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    NSString *shippingFeeLabel = STRING_SHIPPING_FEE;
    NSRange shippingFeeRange = NSMakeRange(0, shippingFeeLabel.length);
    NSMutableAttributedString *finalshippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeLabel, shippingFee]
                                                                                               attributes:shippingFeeAttributes];
    
    [finalshippingFeeString setAttributes:shippingFeeLabelAttributes
                                    range:shippingFeeRange];
    
    
    [self.label setAttributedText:finalshippingFeeString];
    
    NSDictionary* deliveryTimeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* deliveryTimeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    NSString *deliveryTimeString = STRING_DELIVERY_TIME;
    NSRange deliveryTimeRange = NSMakeRange(0, deliveryTimeString.length);
    NSMutableAttributedString *finalDeliveryTimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", deliveryTimeString, deliveryTime]
                                                                                                attributes:deliveryTimeAttributes];
    
    [finalDeliveryTimeString setAttributes:deliveryTimeLabelAttributes
                                     range:deliveryTimeRange];
    
    
    [self.deliveryTimeLabel setAttributedText:finalDeliveryTimeString];
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
