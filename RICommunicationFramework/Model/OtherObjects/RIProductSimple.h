//
//  RIProductSimple.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIProductSimple : NSObject

@property (nonatomic, retain) NSString * attributePackageType;
@property (nonatomic, retain) NSString * variation;
@property (nonatomic, retain) NSString * maxDeliveryTime;
@property (nonatomic, retain) NSString * minDeliveryTime;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * priceFormatted;
@property (nonatomic, retain) NSNumber * priceEuroConverted;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * specialPrice;
@property (nonatomic, retain) NSString * specialPriceFormatted;
@property (nonatomic, retain) NSNumber * specialPriceEuroConverted;
@property (nonatomic, retain) NSNumber * stock;

/**
 *  Method to parse an RIProductSimple given a JSON object
 *
 *  @return the parsed RIProductSimple
 */
+ (RIProductSimple *)parseProductSimple:(NSDictionary*)productSimpleJSON
                                country:(RICountryConfiguration*)country
                           variationKey:(NSString*)variationKey;


@end
