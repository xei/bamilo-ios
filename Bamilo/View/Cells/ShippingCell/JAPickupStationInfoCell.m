//
//  JAPickupStationInfoCell.m
//  Jumia
//
//  Created by Pedro Lopes on 09/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPickupStationInfoCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+JA.h"
#import "RIShippingMethodPickupStationOption.h"

@interface JAPickupStationInfoCell () {}

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UIImageView *checkMarkImageView;

@property (strong, nonatomic) UILabel *shippingFeeLabel;
@property (strong, nonatomic) UILabel *shippingFeeAlertLabel;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UILabel *cityLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *openingHours;

@end

@implementation JAPickupStationInfoCell

-(void)loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation width:(CGFloat)width
{
    if (!self.clickableView){
        self.clickableView = [[JAClickableView alloc] init];
        [self addSubview:self.clickableView];
    }
    self.clickableView.frame = self.bounds;
    self.clickableView.width = width;
    
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABADGEFont, NSFontAttributeName, JABlackColor, NSForegroundColorAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JACaptionFont, NSFontAttributeName, JABlack800Color, NSForegroundColorAttributeName, nil];
    
    CGFloat totalHeight = 0.0f;
    
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_deselected"];
    if (!self.checkMarkImageView) {
        self.checkMarkImageView = [[UIImageView alloc] initWithImage:checkMarkImage];
        [self.clickableView addSubview:self.checkMarkImageView];
    }
    self.checkMarkImageView.frame = CGRectMake(16.0f,
                                               16.0f,
                                               checkMarkImage.size.width,
                                               checkMarkImage.size.height);
    
    if (!self.image) {
        self.image = [[UIImageView alloc] init];
        [self.clickableView addSubview:self.image];
    }
    self.image.frame = CGRectMake(CGRectGetMaxX(self.checkMarkImageView.frame)+5.0f,
                                  16.0f,
                                  80.0f,
                                  60.0f);
    [self.image sd_setImageWithURL:[NSURL URLWithString:pickupStation.image]
               placeholderImage:[UIImage imageNamed:@"placeholder_variations"]];
    [self.image changeImageHeight:0.0f andWidth:60.0f];
    
    CGFloat infoViewX = CGRectGetMaxX(self.image.frame) + 10.0f;
    CGFloat infoViewWidth = width - infoViewX;
    
    if (!self.infoView) {
        self.infoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.clickableView addSubview:self.infoView];
    }
    
    if (!self.cityLabel) {
        self.cityLabel = [[UILabel alloc] init];
        [self.infoView addSubview:self.cityLabel];
    }
    
    [self.cityLabel setFrame:CGRectMake(0,
                                        0,
                                        infoViewWidth,
                                        self.infoView.frame.size.height)];
    [self.cityLabel setNumberOfLines:0];
    [self.cityLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSString *cityLabelString = [STRING_CITY uppercaseString];
    NSString *trimmedCityString = [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [self.cityLabel setAttributedText:finalCityString];
    [self.cityLabel sizeToFit];
    
    totalHeight += self.cityLabel.frame.size.height;
    
    if (!self.addressLabel) {
        self.addressLabel = [[UILabel alloc] init];
        [self.infoView addSubview:self.addressLabel];
    }
    
    [self.addressLabel setFrame:CGRectMake(0,
                                      CGRectGetMaxY(self.cityLabel.frame),
                                      infoViewWidth,
                                       self.infoView.frame.size.height)];
    [self.addressLabel setNumberOfLines:0];
    [self.addressLabel setLineBreakMode:NSLineBreakByWordWrapping];

    NSString *addressLabelString = [STRING_ADDRESS uppercaseString];
    NSString *trimmedAddressString = [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];
    [self.addressLabel setAttributedText:finalAddressString];
    [self.addressLabel sizeToFit];
    
    totalHeight += self.addressLabel.frame.size.height;
    
    if (!self.openingHours) {
        self.openingHours = [[UILabel alloc] init];
        [self.infoView addSubview:self.openingHours];
    }
    
    [self.openingHours setFrame:CGRectMake(0,
                                      CGRectGetMaxY(self.addressLabel.frame),
                                      infoViewWidth,
                                       self.infoView.frame.size.height)];
    [self.openingHours setNumberOfLines:0];
    [self.openingHours setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSString *openingHoursString = [STRING_OPENING_HOURS uppercaseString];
    NSString *trimmedOpeningHoursString = [pickupStation.openingHours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange openingHoursRange = NSMakeRange(openingHoursString.length, trimmedOpeningHoursString.length);
    NSMutableAttributedString *finalOpeningHoursString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", openingHoursString, trimmedOpeningHoursString] attributes:labelAttributes];
    [finalOpeningHoursString setAttributes:valueAttributes
                                     range:openingHoursRange];
    [self.openingHours setAttributedText:finalOpeningHoursString];
    [self.openingHours sizeToFit];
    
    totalHeight += self.openingHours.frame.size.height;
    
    if (!self.shippingFeeLabel) {
        self.shippingFeeLabel = [[UILabel alloc] init];
        [self.infoView addSubview:self.shippingFeeLabel];
    }
    
    [self.shippingFeeLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.openingHours.frame), infoViewWidth, 20)];
    [self.shippingFeeLabel setNumberOfLines:0];
    [self.shippingFeeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSString *shippingFeeString = [STRING_SHIPPING_FEE uppercaseString];
    NSString *shippingFeeValue = [RICountryConfiguration formatPrice:pickupStation.shippingFee country:[RICountryConfiguration getCurrentConfiguration]];
    if ([pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        shippingFeeValue = STRING_FREE;
    }
    NSRange shippingFeeRange = NSMakeRange(shippingFeeString.length, shippingFeeValue.length+1);
    NSMutableAttributedString *finalShippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeString, shippingFeeValue] attributes:labelAttributes];
    [finalShippingFeeString setAttributes:valueAttributes
                                     range:shippingFeeRange];
    [self.shippingFeeLabel setAttributedText:finalShippingFeeString];
    [self.shippingFeeLabel sizeToFit];
    
    if (!self.shippingFeeAlertLabel) {
        self.shippingFeeAlertLabel = [[UILabel alloc] init];
        [self.infoView addSubview:self.shippingFeeAlertLabel];
        [self.shippingFeeAlertLabel setFont:JACaptionFont];
    }
    
    [self.shippingFeeAlertLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.shippingFeeLabel.frame), self.infoView.width, 20)];
    [self.shippingFeeAlertLabel setText:STRING_SHIPPING_FEE_INFO];
    [self.shippingFeeAlertLabel sizeToFit];
    
    if ([pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [self.shippingFeeAlertLabel setHidden:YES];
    }else{
        [self.shippingFeeAlertLabel setHidden:NO];
    }
    
    self.infoView.frame = CGRectMake(infoViewX,
                                     16.0f,
                                     self.frame.size.width - CGRectGetMaxX(self.image.frame) + 10.0f,
                                     CGRectGetMaxY(self.shippingFeeAlertLabel.frame));
    
    if(!self.separator)
    {
        self.separator = [[UIView alloc] initWithFrame:CGRectZero];
        [self.separator setBackgroundColor:JABlack400Color];
        [self.clickableView addSubview:self.separator];
    }
    [self.separator setFrame:CGRectMake(16.0f,
                                        CGRectGetMaxY(self.infoView.frame) + 15.0f,
                                        width,
                                        1.0f)];
    
    self.clickableView.frame = self.bounds;
    self.clickableView.width = width;
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
    }
}

-(void)selectPickupStation
{
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_selected"];
    [self.checkMarkImageView setImage:checkMarkImage];
    self.clickableView.enabled = NO;
}

-(void)deselectPickupStation
{
    UIImage* checkMarkImage = [UIImage imageNamed:@"round_checkbox_deselected"];
    [self.checkMarkImageView setImage:checkMarkImage];
    self.clickableView.enabled = YES;
}

+(CGFloat)getHeightForPickupStation:(RIShippingMethodPickupStationOption*)pickupStation width:(CGFloat)width
{
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JABADGEFont, NSFontAttributeName, JABlackColor, NSForegroundColorAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:JACaptionFont, NSFontAttributeName, JABlack800Color, NSForegroundColorAttributeName, nil];
    
    CGFloat totalHeight = 16.0f;
    
    CGFloat infoViewX = 115.0f;
    CGFloat infoViewWidth = width - infoViewX;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, infoViewWidth, 10000.0f)];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSString *cityLabelString = [STRING_CITY uppercaseString];
    NSString *trimmedCityString = [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [label setAttributedText:finalCityString];
    [label sizeToFit];
    
    totalHeight += label.frame.size.height;

    NSString *addressLabelString = [STRING_ADDRESS uppercaseString];
    NSString *trimmedAddressString = [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];

    [label setFrame:CGRectMake(0.0f, 0.0f, infoViewWidth, 10000.0f)];
    [label setAttributedText:finalAddressString];
    [label sizeToFit];
    
    totalHeight += label.frame.size.height;
    
    NSString *openingHoursString = [STRING_OPENING_HOURS uppercaseString];
    NSString *trimmedOpeningHoursString = [pickupStation.openingHours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange openingHoursRange = NSMakeRange(openingHoursString.length, trimmedOpeningHoursString.length);
    NSMutableAttributedString *finalOpeningHoursString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", openingHoursString, trimmedOpeningHoursString] attributes:labelAttributes];
    [finalOpeningHoursString setAttributes:valueAttributes
                                     range:openingHoursRange];
    
    [label setFrame:CGRectMake(0.0f, 0.0f, infoViewWidth, 10000.0f)];
    [label setAttributedText:finalOpeningHoursString];
    [label sizeToFit];
    
    totalHeight += label.frame.size.height;
    
    UILabel *shippingFeeLabel = [[UILabel alloc] init];
    
    [shippingFeeLabel setFrame:CGRectMake(0, 0, infoViewWidth, 20)];
    [shippingFeeLabel setNumberOfLines:0];
    [shippingFeeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSString *shippingFeeString = [STRING_SHIPPING_FEE uppercaseString];
    NSString *shippingFeeValue = [RICountryConfiguration formatPrice:pickupStation.shippingFee country:[RICountryConfiguration getCurrentConfiguration]];
    if ([pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        shippingFeeValue = STRING_FREE;
    }
    NSRange shippingFeeRange = NSMakeRange(shippingFeeString.length, shippingFeeValue.length);
    NSMutableAttributedString *finalShippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeString, shippingFeeValue] attributes:labelAttributes];
    [finalShippingFeeString setAttributes:valueAttributes
                                    range:shippingFeeRange];
    [shippingFeeLabel setAttributedText:finalShippingFeeString];
    [shippingFeeLabel sizeToFit];
    
    totalHeight += shippingFeeLabel.height;
    
    if (![pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        UILabel *shippingFeeAlertLabel = [[UILabel alloc] init];
        [shippingFeeAlertLabel setFont:JACaptionFont];
        
        [shippingFeeAlertLabel setFrame:CGRectMake(0, 0, infoViewWidth, 20)];
        [shippingFeeAlertLabel setText:STRING_SHIPPING_FEE_INFO];
        [shippingFeeAlertLabel sizeToFit];
        
        totalHeight += shippingFeeAlertLabel.height;
    }
    
    totalHeight += 16;
    
    return totalHeight;
}

@end
