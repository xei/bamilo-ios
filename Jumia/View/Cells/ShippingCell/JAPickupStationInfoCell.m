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

@interface JAPickupStationInfoCell ()
{
    UILabel *_shippingFeeLabel;
    UILabel *_shippingFeeAlertLabel;
    UIView *_infoView;
    UILabel *_cityLabel;
    UILabel *_addressLabel;
    UILabel *_openingHours;
}

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;

@end

@implementation JAPickupStationInfoCell

-(void)loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation
{
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    CGFloat totalHeight = 0.0f;
    
    CGFloat separatorWidth = 206.0f; // used to be 209.0f
    CGFloat infoViewWidth = 180.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        separatorWidth = 652.0f;
        infoViewWidth = 624.0f;
    }
    
    if (!_infoView) {
        _infoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_infoView];
    }
    
    if (!_cityLabel) {
        _cityLabel = [[UILabel alloc] init];
        [_infoView addSubview:_cityLabel];
    }
    
    [_cityLabel setFrame:CGRectMake(0,
                                   0,
                                   infoViewWidth,
                                    _infoView.frame.size.height)];
    [_cityLabel setNumberOfLines:0];
    [_cityLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [_cityLabel setTextColor:UIColorFromRGB(0x666666)];
    
    NSString *cityLabelString = STRING_CITY;
    NSString *trimmedCityString = [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [_cityLabel setAttributedText:finalCityString];
    [_cityLabel sizeToFit];
    
    totalHeight += _cityLabel.frame.size.height;
    
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        [_infoView addSubview:_addressLabel];
    }
    
    [_addressLabel setFrame:CGRectMake(0,
                                      CGRectGetMaxY(_cityLabel.frame),
                                      infoViewWidth,
                                       _infoView.frame.size.height)];
    [_addressLabel setNumberOfLines:0];
    [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_addressLabel setTextColor:UIColorFromRGB(0x666666)];

    NSString *addressLabelString = STRING_ADDRESS;
    NSString *trimmedAddressString = [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];
    [_addressLabel setAttributedText:finalAddressString];
    [_addressLabel sizeToFit];
    
    totalHeight += _addressLabel.frame.size.height;
    
    if (!_openingHours) {
        _openingHours = [[UILabel alloc] init];
        [_infoView addSubview:_openingHours];
    }
    
    [_openingHours setFrame:CGRectMake(0,
                                      CGRectGetMaxY(_addressLabel.frame),
                                      infoViewWidth,
                                       _infoView.frame.size.height)];
    [_openingHours setNumberOfLines:0];
    [_openingHours setLineBreakMode:NSLineBreakByWordWrapping];
    [_openingHours setTextColor:UIColorFromRGB(0x666666)];
    
    NSString *openingHoursString = STRING_OPENING_HOURS;
    NSString *trimmedOpeningHoursString = [pickupStation.openingHours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange openingHoursRange = NSMakeRange(openingHoursString.length, trimmedOpeningHoursString.length);
    NSMutableAttributedString *finalOpeningHoursString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", openingHoursString, trimmedOpeningHoursString] attributes:labelAttributes];
    [finalOpeningHoursString setAttributes:valueAttributes
                                     range:openingHoursRange];
    [_openingHours setAttributedText:finalOpeningHoursString];
    [_openingHours sizeToFit];
    
    totalHeight += _openingHours.frame.size.height;
    
    if (!_shippingFeeLabel) {
        _shippingFeeLabel = [[UILabel alloc] init];
        [_infoView addSubview:_shippingFeeLabel];
    }
    
    [_shippingFeeLabel setFrame:CGRectMake(0, CGRectGetMaxY(_openingHours.frame), infoViewWidth, 20)];
    [_shippingFeeLabel setNumberOfLines:0];
    [_shippingFeeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_shippingFeeLabel setTextColor:UIColorFromRGB(0x666666)];
    NSString *shippingFeeString = STRING_SHIPPING_FEE;
    NSString *shippingFeeValue = [RICountryConfiguration formatPrice:pickupStation.shippingFee country:[RICountryConfiguration getCurrentConfiguration]];
    if ([pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        shippingFeeValue = STRING_FREE;
    }
    NSRange shippingFeeRange = NSMakeRange(shippingFeeString.length, shippingFeeValue.length);
    NSMutableAttributedString *finalShippingFeeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", shippingFeeString, shippingFeeValue] attributes:labelAttributes];
    [finalShippingFeeString setAttributes:valueAttributes
                                     range:shippingFeeRange];
    [_shippingFeeLabel setAttributedText:finalShippingFeeString];
    [_shippingFeeLabel sizeToFit];
    
    if (!_shippingFeeAlertLabel) {
        _shippingFeeAlertLabel = [[UILabel alloc] init];
        [_infoView addSubview:_shippingFeeAlertLabel];
        [_shippingFeeAlertLabel setFont:[UIFont fontWithName:kFontLightName size:11.0f]];
    }
    
    [_shippingFeeAlertLabel setFrame:CGRectMake(0, CGRectGetMaxY(_shippingFeeLabel.frame) + 4, _infoView.width, 20)];
    [_shippingFeeAlertLabel setText:STRING_SHIPPING_FEE_INFO];
    [_shippingFeeAlertLabel setTextColor:UIColorFromRGB(0x666666)];
    [_shippingFeeAlertLabel sizeToFit];
    
    if ([pickupStation.shippingFee isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_shippingFeeAlertLabel setHidden:YES];
    }else{
        [_shippingFeeAlertLabel setHidden:NO];
    }
    
    if(!_separator)
    {
        _separator = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_separator];
    }
    
    [_separator setFrame:CGRectMake(82,
                                        self.height - 1.0f,
                                        self.width,
                                        1.0f)];
    
    [_separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    
    [_infoView setFrame:self.bounds];
    _infoView.y += 16;
    _infoView.x += 85;
    _infoView.width -= 85;
    
    [_image setImageWithURL:[NSURL URLWithString:pickupStation.image]
               placeholderImage:[UIImage imageNamed:@"placeholder_variations"]];
    [_image changeImageHeight:0.0f andWidth:60.0f];
    
    _clickableView.frame = self.bounds;
}

-(void)selectPickupStation
{
    [self.checkMark setHidden:NO];
    self.clickableView.enabled = NO;
}

-(void)deselectPickupStation
{
    [self.checkMark setHidden:YES];
    self.clickableView.enabled = YES;
}

+(CGFloat)getHeightForPickupStation:(RIShippingMethodPickupStationOption*)pickupStation
{
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontRegularName size:13.0f], NSFontAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:kFontLightName size:13.0f], NSFontAttributeName, nil];
    
    CGFloat totalHeight = 16.0f;
    
    CGFloat infoViewWidth = 180.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        infoViewWidth = 624.0f;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, infoViewWidth, 10000.0f)];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setTextColor:UIColorFromRGB(0x666666)];
    
    NSString *cityLabelString = STRING_CITY;
    NSString *trimmedCityString = [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [label setAttributedText:finalCityString];
    [label sizeToFit];
    
    totalHeight += label.frame.size.height;

    NSString *addressLabelString = STRING_ADDRESS;
    NSString *trimmedAddressString = [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];

    [label setFrame:CGRectMake(0.0f, 0.0f, infoViewWidth, 10000.0f)];
    [label setAttributedText:finalAddressString];
    [label sizeToFit];
    
    totalHeight += label.frame.size.height;
    
    NSString *openingHoursString = STRING_OPENING_HOURS;
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
    [shippingFeeLabel setTextColor:UIColorFromRGB(0x666666)];
    NSString *shippingFeeString = STRING_SHIPPING_FEE;
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
        [shippingFeeAlertLabel setFont:[UIFont fontWithName:kFontLightName size:11.0f]];
        
        [shippingFeeAlertLabel setFrame:CGRectMake(0, 0, infoViewWidth, 20)];
        [shippingFeeAlertLabel setText:STRING_SHIPPING_FEE_INFO];
        [shippingFeeAlertLabel setTextColor:UIColorFromRGB(0x666666)];
        [shippingFeeAlertLabel sizeToFit];
        
        totalHeight += shippingFeeAlertLabel.height + 4;
    }
    
    totalHeight += 16;
    
    NSLog(@"totalHeight: %f", totalHeight);
    
    return totalHeight;
}

@end
