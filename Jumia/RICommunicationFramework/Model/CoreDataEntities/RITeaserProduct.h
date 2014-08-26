//
//  RITeaserProduct.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaser;

@interface RITeaserProduct : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSString * maxPriceFormatted;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * priceFormatted;
@property (nonatomic, retain) NSNumber * maxSpecialPrice;
@property (nonatomic, retain) NSString * maxSpecialPriceFormatted;
@property (nonatomic, retain) NSNumber * specialPrice;
@property (nonatomic, retain) NSString * specialPriceFormatted;
@property (nonatomic, retain) NSString * maxSavingPercentage;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) RITeaser *teaser;

/**
 *  Method to parse an RITeaserProduct given a JSON object and the country configuration
 *
 *  @return the parsed RITeaserProduct
 */
+ (RITeaserProduct *)parseTeaserProduct:(NSDictionary *)json
                   countryConfiguration:(RICountryConfiguration*)countryConfiguration;

/**
 *  Save in the core data a given RITeaserProduct
 *
 *  @param the RITeaserProduct to save
 */
+ (void)saveTeaserProduct:(RITeaserProduct *)product;

@end
