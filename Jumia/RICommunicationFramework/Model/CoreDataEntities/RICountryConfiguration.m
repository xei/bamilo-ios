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
    
    NSString *languageCode = @"";
    if ([json objectForKey:@"languages"]) {
        
        NSArray *languagesArray = [json objectForKey:@"languages"];
        
        for (NSDictionary *dic in languagesArray) {
            RILanguage *language = [RILanguage parseRILanguage:dic];
            language.countryConfig = newConfig;
            
            if([language.langDefault boolValue])
            {
                languageCode = language.langCode;
            }
            
            [newConfig addLanguagesObject:language];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:@"language_code"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    [RICountryConfiguration saveConfiguration:newConfig];
    
    return newConfig;
}

+ (NSString*)formatPrice:(NSNumber*)price country:(RICountryConfiguration*)country
{
    NSString *formattedPrice = [price stringValue];
    
    NSString* noFraction = @"";
    NSString* fraction = @"";
    if(NSNotFound != [formattedPrice rangeOfString:@"."].location)
    {
        NSArray *formattedPriceComponents = [formattedPrice componentsSeparatedByString:@"."];
        if(1 < [formattedPriceComponents count])
        {
            noFraction = [formattedPriceComponents objectAtIndex:0];
            fraction = [formattedPriceComponents objectAtIndex:1];
        }
    }
    else
    {
        noFraction = formattedPrice;
    }
    
    if(3 < [noFraction length])
    {
        NSString *thousands = [noFraction substringWithRange:NSMakeRange([noFraction length] - 3, 3)];
        NSString *other = [noFraction substringWithRange:NSMakeRange(0, [noFraction length] - 3)];
        
        if(0 == [[country noDecimals] integerValue])
        {
            formattedPrice = [NSString stringWithFormat:@"%@%@%@", other, [country thousandsSep], thousands];
        }
        else
        {
            while([[country noDecimals] integerValue] > [fraction length])
            {
                fraction = [NSString stringWithFormat:@"%@0",fraction];
            }
            
            formattedPrice = [NSString stringWithFormat:@"%@%@%@%@%@", other, [country thousandsSep], thousands, [country decimalsSep], fraction];
        }
    }
    else
    {
        if(0 == [[country noDecimals] integerValue])
        {
            formattedPrice = noFraction;
        }
        else
        {
            while([[country noDecimals] integerValue] > [fraction length])
            {
                fraction = [NSString stringWithFormat:@"%@0",fraction];
            }
            
            formattedPrice = [NSString stringWithFormat:@"%@%@%@", noFraction, [country decimalsSep], fraction];
        }
    }
    
    if(!VALID_NOTEMPTY([country currencyPosition], NSNumber) || ![[country currencyPosition] boolValue])
    {
        formattedPrice = [NSString stringWithFormat:@"%@ %@", [country currencySymbol], formattedPrice];
    }
    else
    {
        formattedPrice = [NSString stringWithFormat:@"%@ %@", formattedPrice, [country currencySymbol]];
    }
    
    return formattedPrice;
}

+ (void)saveConfiguration:(RICountryConfiguration *)configuration
{
    for (RILanguage *language in configuration.languages) {
        [RILanguage saveLanguage:language];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:configuration];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (RICountryConfiguration *)getCurrentConfiguration
{
    NSArray *configArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    if (0 == configArray.count) {
        return nil;
    } else {
        return configArray[0];
    }
}

@end
