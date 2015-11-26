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
@property (nonatomic, retain) NSString * deliveryTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * reviewAverage;
@property (nonatomic, retain) NSNumber * reviewTotal;
@property (nonatomic, retain) NSString * url;
@property (nonatomic) BOOL isGlobal;
@property (nonatomic, retain) NSString * shippingGlobal;
@property (nonatomic, retain) NSString * linkTextGlobal;
@property (nonatomic, retain) NSString * linkTargetStringGlobal;
@property (nonatomic, retain) NSString * warranty;
@property (nonatomic, retain) NSString * cmsInfo;

+ (RISeller*)parseSeller:(NSDictionary*)sellerJSON;

@end
