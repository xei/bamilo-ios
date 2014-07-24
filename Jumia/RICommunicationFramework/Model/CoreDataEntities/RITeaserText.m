//
//  RITeaserText.m
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaserText.h"
#import "RITeaser.h"


@implementation RITeaserText

@dynamic url;
@dynamic name;
@dynamic teaser;

+ (RITeaserText *)parseTeaserText:(NSDictionary *)json
{
    RITeaserText *newText = (RITeaserText*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserText class])];
    
    if ([json objectForKey:@"campaign_url"]) {
        newText.url = [json objectForKey:@"campaign_url"];
    }
    
    if ([json objectForKey:@"campaign_name"]) {
        newText.name = [json objectForKey:@"campaign_name"];
    }
    
    if ([json objectForKey:@"name"]) {
        newText.name = [json objectForKey:@"name"];
    }

    if ([json objectForKey:@"api_url"]) {
        newText.url = [json objectForKey:@"api_url"];
    }
    
    return newText;
}

+ (void)saveTeaserText:(RITeaserText *)text
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:text];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
