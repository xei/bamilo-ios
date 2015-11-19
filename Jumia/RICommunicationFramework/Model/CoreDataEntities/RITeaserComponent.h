//
//  RITeaserComponent.h
//  Jumia
//
//  Created by Telmo Pinto on 16/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaserGrouping;

@interface RITeaserComponent : NSManagedObject

@property (nonatomic, retain) NSString * imageLandscapeUrl;
@property (nonatomic, retain) NSString * imagePortraitUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * endingDate;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * targetType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * clickUrl;
@property (nonatomic, retain) NSNumber * maxSavingPercentage;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * priceEuroConverted;
@property (nonatomic, retain) NSString * priceFormatted;
@property (nonatomic, retain) NSNumber * maxPriceEuroConverted;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSString * maxPriceFormatted;
@property (nonatomic, retain) RITeaserGrouping *teaserGrouping;
@property (nonatomic, retain) NSNumber * specialPrice;
@property (nonatomic, retain) NSNumber * specialPriceEuroConverted;
@property (nonatomic, retain) NSString * specialPriceFormatted;

+ (RITeaserComponent*)parseTeaserComponent:(NSDictionary*)teaserComponentJSON
                                   country:(RICountryConfiguration*)country;

+ (void)saveTeaserComponent:(RITeaserComponent *)teaserComponent andContext:(BOOL)save;

@end
