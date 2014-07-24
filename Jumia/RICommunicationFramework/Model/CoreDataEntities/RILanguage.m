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

+ (RILanguage *)parseRILanguage:(NSDictionary *)json
{
    RILanguage *newLanguage = (RILanguage *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RILanguage class])];
    
    if ([json objectForKey:@"lang_code"]) {
        newLanguage.langCode = [json objectForKey:@"lang_code"];
    }
    
    if ([json objectForKey:@"lang_name"]) {
        newLanguage.langName = [json objectForKey:@"lang_name"];
    }
    
    if ([json objectForKey:@"lang_default"]) {
        newLanguage.langDefault = [NSNumber numberWithInteger:[[json objectForKey:@"lang_default"] integerValue]];
    }
    
    return newLanguage;
}

+ (void)saveLanguage:(RILanguage *)language
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:language];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
