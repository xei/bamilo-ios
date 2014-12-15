//
//  RIShippingMethod.h
//  Jumia
//
//  Created by plopes on 15/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIShippingMethod : NSObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * deliveryTime;

+ (RIShippingMethod *)parseShippingMethod:(NSDictionary *)shippingMethodJSON;

@end
