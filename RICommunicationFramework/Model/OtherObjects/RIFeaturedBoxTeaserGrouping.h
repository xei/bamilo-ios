//
//  RIFeaturedBoxTeaserGrouping.h
//  Jumia
//
//  Created by Telmo Pinto on 16/07/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIFeaturedBoxTeaserGrouping : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSOrderedSet* teaserComponents;

+ (RIFeaturedBoxTeaserGrouping*)parseFeaturedBox:(NSDictionary*)json
                           country:(RICountryConfiguration*)country;

@end
