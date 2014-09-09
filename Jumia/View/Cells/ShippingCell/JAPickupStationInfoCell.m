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

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *openingHours;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHeightConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoYConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openingHoursHeightConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressHeightConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityHeightConstrain;

@end

@implementation JAPickupStationInfoCell

- (void) loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation
{
    NSDictionary* labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:13.0f], NSFontAttributeName, nil];
    NSDictionary* valueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f], NSFontAttributeName, nil];
    
    CGFloat totalHeight = 0.0f;
    NSString *cityLabelString = @"City: ";
    NSString *trimmedCityString =  [pickupStation.city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange cityRange = NSMakeRange(cityLabelString.length, trimmedCityString.length);
    NSMutableAttributedString *finalCityString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", cityLabelString, trimmedCityString] attributes:labelAttributes];
    [finalCityString setAttributes:valueAttributes
                             range:cityRange];
    [self.cityLabel setAttributedText:finalCityString];
    [self.cityLabel sizeToFit];
    self.cityHeightConstrain.constant = self.cityLabel.frame.size.height;
    totalHeight += self.cityLabel.frame.size.height;
    [self.cityLabel layoutIfNeeded];
    
    NSString *addressLabelString = @"Address: ";
    NSString *trimmedAddressString =  [pickupStation.address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange addressRange = NSMakeRange(addressLabelString.length, trimmedAddressString.length);
    NSMutableAttributedString *finalAddressString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", addressLabelString,trimmedAddressString] attributes:labelAttributes];
    [finalAddressString setAttributes:valueAttributes
                                range:addressRange];
    [self.addressLabel setAttributedText:finalAddressString];
    [self.addressLabel sizeToFit];
    self.addressHeightConstrain.constant = self.addressLabel.frame.size.height;
    totalHeight += self.addressLabel.frame.size.height;
    [self.addressLabel layoutIfNeeded];
    
    NSString *openingHoursString = @"Opening Hours: ";
    NSString *trimmedOpeningHoursString =  [pickupStation.openingHours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange openingHoursRange = NSMakeRange(openingHoursString.length, trimmedOpeningHoursString.length);
    NSMutableAttributedString *finalOpeningHoursString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", openingHoursString, trimmedOpeningHoursString] attributes:labelAttributes];
    [finalOpeningHoursString setAttributes:valueAttributes
                                     range:openingHoursRange];
    [self.openingHours setAttributedText:finalOpeningHoursString];
    [self.openingHours sizeToFit];
    self.openingHoursHeightConstrain.constant = self.openingHours.frame.size.height;
    [self.openingHours layoutIfNeeded];
    totalHeight += self.openingHours.frame.size.height;
    
    self.infoHeightConstrain.constant = totalHeight;
    self.infoYConstrain.constant = (self.frame.size.height - totalHeight) / 2;
    [self.infoView layoutIfNeeded];
    
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
