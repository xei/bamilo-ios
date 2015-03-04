//
//  RISeller.h
//  Jumia
//
//  Created by Telmo Pinto on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIProduct;

@interface RISeller : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * maxDeliveryTime;
@property (nonatomic, retain) NSNumber * minDeliveryTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * reviewAverage;
@property (nonatomic, retain) NSNumber * reviewTotal;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) RIProduct *product;

@end

@interface RISeller (CoreDataGeneratedAccessors)

+ (RISeller*)parseSeller:(NSDictionary*)sellerJSON;
+ (void)saveSeller:(RISeller*)seller;

@end
