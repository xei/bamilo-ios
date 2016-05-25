//
//  JAShippingInfoCell.h
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAShippingInfoCell : UITableViewCell

-(void)loadWithShippingFee:(NSString *)shippingFee
              deliveryTime:(NSString *)deliveryTime
                     width:(CGFloat)width;

-(void)loadWithPickupStationWidth:(CGFloat)width;

-(void)setPickupStationRegion:(NSString*)pickupStationRegion;

@end
