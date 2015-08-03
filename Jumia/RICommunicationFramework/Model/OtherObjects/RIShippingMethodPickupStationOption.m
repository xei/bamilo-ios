//
//  RIShippingMethodPickupStationOption.m
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethodPickupStationOption.h"

@implementation RIShippingMethodPickupStationOption

+(RIShippingMethodPickupStationOption*) parsePickupStation:(NSDictionary *)jsonObject
{
    RIShippingMethodPickupStationOption *pickupStation = [[RIShippingMethodPickupStationOption alloc] init];
    
    if ([jsonObject objectForKey:@"id_pickupstation"]) {
        pickupStation.uid = [jsonObject objectForKey:@"id_pickupstation"];
    }
    
    if ([jsonObject objectForKey:@"name"]) {
        pickupStation.name = [jsonObject objectForKey:@"name"];
    }
    
    if ([jsonObject objectForKey:@"pickup_id"]) {
        pickupStation.pickupId = [jsonObject objectForKey:@"pickup_id"];
    }
    
    if ([jsonObject objectForKey:@"image"]) {
        pickupStation.image = [jsonObject objectForKey:@"image"];
    }
    
    if ([jsonObject objectForKey:@"address"]) {
        pickupStation.address = [jsonObject objectForKey:@"address"];
    }
    
    if ([jsonObject objectForKey:@"place"]) {
        pickupStation.place = [jsonObject objectForKey:@"place"];
    }
    
    if ([jsonObject objectForKey:@"city"]) {
        pickupStation.city = [jsonObject objectForKey:@"city"];
    }
    
    if ([jsonObject objectForKey:@"opening_hours"]) {
        pickupStation.openingHours = [jsonObject objectForKey:@"opening_hours"];
    }
    
    if ([jsonObject objectForKey:@"id_pickupstation_region"]) {
        pickupStation.pickupstationRegionId = [jsonObject objectForKey:@"id_pickupstation_region"];
    }
    
    NSArray* paymentMethods = [jsonObject objectForKey:@"payment_method"];
    if (VALID_NOTEMPTY(paymentMethods, NSArray)) {
        pickupStation.paymentMethods = [paymentMethods copy];
    }
    
    NSArray* regions = [jsonObject objectForKey:@"regions"];
    if (VALID_NOTEMPTY(regions, NSDictionary)) {
        pickupStation.regions = [regions copy];
    }
    
    NSArray *shippingFee = [jsonObject objectForKey:@"shipping_fee"];
    if (VALID_NOTEMPTY(shippingFee, NSNumber)) {
        pickupStation.shippingFee = [shippingFee copy];
    }
    
    return pickupStation;
}

@end
