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

@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UILabel *cityLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *openingHours;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;

@end

@implementation JAPickupStationInfoCell

- (void) loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation
{
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0f], NSFontAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f], NSFontAttributeName, nil];
    
    CGFloat totalHeight = 0.0f;

    if(VALID_NOTEMPTY(self.cityLabel, UILabel))
    {
        [self.cityLabel removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.addressLabel, UILabel))
    {
        [self.addressLabel removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.openingHours, UILabel))
    {
        [self.openingHours removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.infoView, UIView))
    {
        [self.infoView removeFromSuperview];
    }
    
    self.infoView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.infoView.frame.origin.x,
                                                               self.infoView.frame.origin.y,
                                                               180.0f,
                                                               self.infoView.frame.size.height)];
    [self.cityLabel setNumberOfLines:0];
    [self.cityLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.cityLabel setTextColor:UIColorFromRGB(0x666666)];
    
    NSString *cityLabelString = @"City: ";
    NSString *trimmedCityString =  [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [self.cityLabel setAttributedText:finalCityString];
    [self.cityLabel sizeToFit];
    
    [self.infoView addSubview:self.cityLabel];
    totalHeight += self.cityLabel.frame.size.height;
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.infoView.frame.origin.x,
                                                                  CGRectGetMaxY(self.cityLabel.frame),
                                                                  180.0f,
                                                                  self.infoView.frame.size.height)];
    [self.addressLabel setNumberOfLines:0];
    [self.addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.addressLabel setTextColor:UIColorFromRGB(0x666666)];

    NSString *addressLabelString = @"Address: ";
    NSString *trimmedAddressString =  [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];
    [self.addressLabel setAttributedText:finalAddressString];
    [self.addressLabel sizeToFit];
    
    [self.infoView addSubview:self.addressLabel];
    totalHeight += self.addressLabel.frame.size.height;
    
    self.openingHours = [[UILabel alloc] initWithFrame:CGRectMake(self.infoView.frame.origin.x,
                                                                  CGRectGetMaxY(self.addressLabel.frame),
                                                                  180.0f,
                                                                  self.infoView.frame.size.height)];
    [self.openingHours setNumberOfLines:0];
    [self.openingHours setLineBreakMode:NSLineBreakByWordWrapping];
    [self.openingHours setTextColor:UIColorFromRGB(0x666666)];
    
    NSString *openingHoursString = @"Opening Hours: ";
    NSString *trimmedOpeningHoursString =  [pickupStation.openingHours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange openingHoursRange = NSMakeRange(openingHoursString.length, trimmedOpeningHoursString.length);
    NSMutableAttributedString *finalOpeningHoursString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", openingHoursString, trimmedOpeningHoursString] attributes:labelAttributes];
    [finalOpeningHoursString setAttributes:valueAttributes
                                     range:openingHoursRange];
    [self.openingHours setAttributedText:finalOpeningHoursString];
    [self.openingHours sizeToFit];
    
    [self.infoView addSubview:self.openingHours];
    totalHeight += self.openingHours.frame.size.height;
    
    [self.infoView setFrame:CGRectMake(CGRectGetMaxX(self.image.frame) + 10.0f,
                                       (self.frame.size.height - totalHeight) / 2,
                                       180.0f,
                                       totalHeight)];
    [self addSubview:self.infoView];
    
    [self.image setImageWithURL:[NSURL URLWithString:pickupStation.image]
               placeholderImage:[UIImage imageNamed:@"placeholder_variations"]];
    [self.image changeImageSize:0.0f andWidth:60.0f];
}

-(void)selectPickupStation
{
    [self.checkMark setHidden:NO];
}

-(void)deselectPickupStation
{
    [self.checkMark setHidden:YES];
}

@end
