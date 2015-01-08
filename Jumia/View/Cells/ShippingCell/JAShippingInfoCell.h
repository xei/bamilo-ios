//
//  JAShippingInfoCell.h
//  Jumia
//
//  Created by Pedro Lopes on 08/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAShippingInfoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *separator;

-(void)loadWithShippingFee:(NSString *)shippingFee
              deliveryTime:(NSString *)deliveryTime;

-(void)loadWithPickupStation;

-(void)setPickupStationRegion:(NSString*)pickupStationRegion;

@end
