//
//  RICountryConfiguration.m
//  Comunication Project
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICountryConfiguration.h"
#import "RILanguage.h"


@implementation RICountryConfiguration

@dynamic currencyIso;
@dynamic currencySymbol;
@dynamic currencyPosition;
@dynamic noDecimals;
@dynamic thousandsSep;
@dynamic decimalsSep;
@dynamic gaId;
@dynamic phoneNumber;
@dynamic csEmail;
@dynamic languages;

+ (RICountryConfiguration *)parseCountryConfiguration:(NSDictionary *)json
{
    RICountryConfiguration *newConfig = (RICountryConfiguration*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICountryConfiguration class])];
    
    if ([json objectForKey:@"currency_iso"]) {
        newConfig.currencyIso = [json objectForKey:@"currency_iso"];
    }
    
    if ([json objectForKey:@"currency_symbol"]) {
        newConfig.currencySymbol = [json objectForKey:@"currency_symbol"];
    }
    
    if ([json objectForKey:@"currency_position"]) {
        newConfig.currencyPosition = [NSNumber numberWithInteger:[[json objectForKey:@"currency_position"] integerValue]];
    }
    
    if ([json objectForKey:@"no_decimals"]) {
        newConfig.noDecimals = [NSNumber numberWithInteger:[[json objectForKey:@"no_decimals"] integerValue]];
    }
    
    if ([json objectForKey:@"thousands_sep"]) {
        newConfig.thousandsSep = [json objectForKey:@"thousands_sep"];
    }
    
    if ([json objectForKey:@"decimals_sep"]) {
        newConfig.decimalsSep = [json objectForKey:@"decimals_sep"];
    }
    
    if ([json objectForKey:@"ga_id"]) {
        newConfig.gaId = [json objectForKey:@"ga_id"];
    }
    
    if ([json objectForKey:@"phone_number"]) {
        newConfig.phoneNumber = [json objectForKey:@"phone_number"];
    }
    
    if ([json objectForKey:@"cs_email"]) {
        newConfig.csEmail = [json objectForKey:@"cs_email"];
    }
    
    if ([json objectForKey:@"languages"]) {
        
        NSArray *languagesArray = [json objectForKey:@"languages"];
        
        for (NSDictionary *dic in languagesArray) {
            RILanguage *language = [RILanguage parseRILanguage:dic];
            language.countryConfig = newConfig;
            
            [newConfig addLanguagesObject:language];
        }
    }
    
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    [RICountryConfiguration saveConfiguration:newConfig];
    
    return newConfig;
}

+ (void)saveConfiguration:(RICountryConfiguration *)configuration
{
    for (RILanguage *language in configuration.languages) {
        [RILanguage saveLanguage:language];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:configuration];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
