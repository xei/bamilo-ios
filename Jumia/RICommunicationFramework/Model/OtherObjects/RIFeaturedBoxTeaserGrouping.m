//
//  RIFeaturedBoxTeaserGrouping.m
//  Jumia
//
//  Created by Telmo Pinto on 16/07/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIFeaturedBoxTeaserGrouping.h"
#import "RITeaserComponent.h"

@implementation RIFeaturedBoxTeaserGrouping

+ (RIFeaturedBoxTeaserGrouping*)parseFeaturedBox:(NSDictionary*)json
                           country:(RICountryConfiguration*)country;
{
    RIFeaturedBoxTeaserGrouping* newFeaturedBox = [[RIFeaturedBoxTeaserGrouping alloc] init];
 
    if (VALID_NOTEMPTY(json, NSDictionary)) {
        NSString* title = [json objectForKey:@"title"];
        if (VALID_NOTEMPTY(title, NSString)) {
            newFeaturedBox.title = title;
        }
        
        NSArray* teaserComponentsJson = [json objectForKey:@"data"];
        if (VALID_NOTEMPTY(teaserComponentsJson, NSArray)) {
            
            NSMutableArray* teaserComponentsArray = [NSMutableArray new];
            for (NSDictionary* teaserComponentJson in teaserComponentsJson) {
                if (VALID_NOTEMPTY(teaserComponentJson, NSDictionary)) {
                    RITeaserComponent* teaserComponent = [RITeaserComponent parseTeaserComponent:teaserComponentJson
                                                                                         country:country];
                    [teaserComponentsArray addObject:teaserComponent];
                }
            }
            newFeaturedBox.teaserComponents = [NSOrderedSet orderedSetWithArray:teaserComponentsArray];
        }

    }
    return newFeaturedBox;
}

@end
