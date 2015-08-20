//
//  RISeller.h
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RISeller : NSObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * maxDeliveryTime;
@property (nonatomic, retain) NSNumber * minDeliveryTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * reviewAverage;
@property (nonatomic, retain) NSNumber * reviewTotal;
@property (nonatomic, retain) NSString * url;

+ (RISeller*)parseSeller:(NSDictionary*)sellerJSON;

@end
