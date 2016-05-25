//
//  JAPickupStationInfoCell.h
//  Jumia
//
//  Created by Pedro Lopes on 09/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIShippingMethodPickupStationOption;

@interface JAPickupStationInfoCell : UITableViewCell

@property (strong, nonatomic) JAClickableView *clickableView;
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UIView *lastSeparator;

-(void)loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation width:(CGFloat)width;

-(void)selectPickupStation;

-(void)deselectPickupStation;

+(CGFloat)getHeightForPickupStation:(RIShippingMethodPickupStationOption*)pickupStation width:(CGFloat)width;

@end
