//
//  JASellerDeliveryView.h
//  Jumia
//
//  Created by miguelseabra on 14/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISellerDelivery.h"

@interface JASellerDeliveryView : UIView

-(void)setupWithSellerDelivery:(RISellerDelivery*)sellerDelivery index:(NSInteger)index ofMax:(NSInteger)max width:(CGFloat)width;
-(void)updateWidth:(CGFloat)width;
@end
