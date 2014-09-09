//
//  JAShippingInfoCell.m
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingInfoCell.h"

@interface JAShippingInfoCell ()

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
{
    NSDictionary* shippingFeeLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0f], NSFontAttributeName, nil];
    NSDictionary* shippingFeeAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f], NSFontAttributeName, nil];
    
    NSString *shippingFeeLabel = @"Shipping Fee: ";
    NSRange shippingFeeRange = NSMakeRange(shippingFeeLabel.length, shippingFee.length);
    NSMutableAttributedString *finalshippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", shippingFeeLabel, shippingFee]
                                                                                               attributes:shippingFeeLabelAttributes];
    
    [finalshippingFeeString setAttributes:shippingFeeAttributes
                                    range:shippingFeeRange];
    
    
    [self.label setAttributedText:finalshippingFeeString];
}

-(void)loadWithPickupStation
{
    [self.label setText:@"Please select"];
}

-(void)setPickupStationRegion:(NSString*)pickupStationRegion
{
    [self.label setTextColor:UIColorFromRGB(0x666666)];
    [self.label setText:pickupStationRegion];
}

@end
