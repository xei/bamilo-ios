//
//  RILanguage.m
//  Comunication Project
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RILanguage.h"
#import "RICountryConfiguration.h"


@implementation RILanguage

@dynamic langCode;
@dynamic langDefault;
@dynamic langName;
@dynamic countryConfig;

+ (RILanguage *)parseLanguage:(NSDictionary *)json;
{
    RILanguage *newLanguage = (RILanguage *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RILanguage class])];
    
    if ([json objectForKey:@"code"]) {
        newLanguage.langCode = [json objectForKey:@"code"];
    }
    
    if ([json objectForKey:@"name"]) {
        newLanguage.langName = [json objectForKey:@"name"];
    }
    
    if ([json objectForKey:@"default"]) {
        newLanguage.langDefault = [NSNumber numberWithInteger:[[json objectForKey:@"default"] integerValue]];
    }
    
    return newLanguage;
}

+ (void)saveLanguage:(RILanguage *)language andContext:(BOOL)save
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:language];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
