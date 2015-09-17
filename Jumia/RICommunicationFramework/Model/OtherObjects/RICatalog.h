//
//  RICatalog.h
//  Jumia
//
//  Created by josemota on 9/16/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIBanner.h"

@interface RICatalog : NSObject

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *filters;
@property (nonatomic, retain) NSArray *products;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *totalProducts;
@property (nonatomic, retain) RIBanner *banner;

+ (RICatalog *)parseCatalog:(NSDictionary *)catalogDictionary forCountryConfiguration:(RICountryConfiguration *)configuration;

@end
