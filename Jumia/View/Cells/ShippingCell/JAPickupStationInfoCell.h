//
//  JAPickupStationInfoCell.h
//  Jumia
//
//  Created by Pedro Lopes on 09/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIShippingMethodPickupStationOption;

@interface JAPickupStationInfoCell : UICollectionViewCell

@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UIView *lastSeparator;

-(void)loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation;

-(void)selectPickupStation;

-(void)deselectPickupStation;

+(CGFloat)getHeightForPickupStation:(RIShippingMethodPickupStationOption*)pickupStation;

@end
