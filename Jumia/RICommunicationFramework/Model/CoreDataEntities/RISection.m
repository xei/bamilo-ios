//
//  RISection.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISection.h"
#import "RIApi.h"


@implementation RISection

@dynamic md5;
@dynamic name;
@dynamic url;
@dynamic api;

+ (RISection* )parseSection:(NSDictionary*)section;
{
    RISection* newSection = (RISection*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISection class])];
    
    if ([section objectForKey:@"section_name"]) {
        newSection.name = [section objectForKey:@"section_name"];
    }
    if ([section objectForKey:@"section_md5"]) {
        newSection.md5 = [section objectForKey:@"section_md5"];
    }
    if ([section objectForKey:@"url"]) {
        newSection.url = [section objectForKey:@"url"];
    }
    
    return newSection;
}

+ (void)saveSection:(RISection*)section;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:section];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
