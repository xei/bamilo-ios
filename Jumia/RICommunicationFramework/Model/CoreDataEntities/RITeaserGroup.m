//
//  RITeaserGroup.m
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaserGroup.h"
#import "RITeaser.h"
#import "RITeaserCategory.h"


@implementation RITeaserGroup

@dynamic type;
@dynamic title;
@dynamic teasers;
@dynamic teaserCategory;

+ (RITeaserGroup *)parseTeaserGroup:(NSDictionary *)json
               countryConfiguration:(RICountryConfiguration*)countryConfiguration
{
    RITeaserGroup *newGroup = (RITeaserGroup*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserGroup class])];
    
    if ([json objectForKey:@"group_title"]) {
        newGroup.title = [json objectForKey:@"group_title"];
    }
    
    if ([json objectForKey:@"group_type"]) {
        newGroup.type = [NSNumber numberWithInt:[[json objectForKey:@"group_type"] integerValue]];
        
        NSInteger tempGroupTypeId = [[json objectForKey:@"group_type"] integerValue];
    
        if ([json objectForKey:@"data"]) {
            NSArray *teasers = [json objectForKey:@"data"];
            
            for (NSDictionary *dic in teasers) {
                RITeaser *teaser = [RITeaser parseTeaser:dic ofType:tempGroupTypeId
                                    countryConfiguration:countryConfiguration];
                teaser.teaserGroup = newGroup;
                
                [newGroup addTeasersObject:teaser];
            }
        }
    }
    
    return newGroup;
}

+ (void)saveTeaserGroup:(RITeaserGroup *)teaserGroup
{
    for (RITeaser *teaser in teaserGroup.teasers) {
        [RITeaser saveTeaser:teaser];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserGroup];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
