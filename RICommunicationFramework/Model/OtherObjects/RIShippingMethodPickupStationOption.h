//
//  RIShippingMethodPickupStationOption.h
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIShippingMethodPickupStationOption : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pickupId;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *openingHours;
@property (nonatomic, strong) NSString *pickupstationRegionId;
@property (nonatomic, strong) NSNumber *shippingFee;
@property (nonatomic, strong) NSArray *paymentMethods;
@property (nonatomic, strong) NSDictionary *regions;

/**
 * Method to parse a shipping method pickup station
 *
 * @param the json object with the shipping method pickup station object
 * @return a initialized pickup station object
 */
+(RIShippingMethodPickupStationOption*) parsePickupStation:(NSDictionary *)jsonObject;

@end
