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

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIView *lastSeparator;

- (void) loadWithPickupStation:(RIShippingMethodPickupStationOption*)pickupStation;

-(void)selectPickupStation;

-(void)deselectPickupStation;

@end
