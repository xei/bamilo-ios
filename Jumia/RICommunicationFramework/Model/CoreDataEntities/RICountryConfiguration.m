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

@dynamic csEmail;
@dynamic currencyIso;
@dynamic currencyPosition;
@dynamic currencySymbol;
@dynamic decimalsSep;
@dynamic gaId;
@dynamic noDecimals;
@dynamic phoneNumber;
@dynamic thousandsSep;
@dynamic ratingIsEnabled;
@dynamic ratingRequiresLogin;
@dynamic reviewIsEnabled;
@dynamic reviewRequiresLogin;
@dynamic languages;
@dynamic facebookAvailable;
@dynamic gtmId;

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
    
    if ([json objectForKey:@"ga_ios_id"]) {
        newConfig.gaId = [json objectForKey:@"ga_ios_id"];
    }
    
    if ([json objectForKey:@"phone_number"]) {
        newConfig.phoneNumber = [json objectForKey:@"phone_number"];
    }
    
    if ([json objectForKey:@"cs_email"]) {
        newConfig.csEmail = [json objectForKey:@"cs_email"];
    }
    
    if([json objectForKey:@"gtm_ios"]){
        newConfig.gtmId = [json objectForKey:@"gtm_ios"];
    }
    
    if([json objectForKey:@"facebook_is_available"]){
        newConfig.facebookAvailable = [json objectForKey:@"facebook_is_available"];
        
        //$$$ FORCE UPDATE CAN REMOVE THIS
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsHasDownloadedFacebookConfigs];
    }
    
    NSString *languageCode = @"";
    if ([json objectForKey:@"languages"]) {
        
        NSArray *languagesArray = [json objectForKey:@"languages"];
        
        for (NSDictionary *dic in languagesArray) {
            RILanguage *language = [RILanguage parseLanguage:dic];
            language.countryConfig = newConfig;
            
            if([language.langDefault boolValue])
            {
                languageCode = language.langCode;
            }
            
            [newConfig addLanguagesObject:language];
        }
    }

    if ([json objectForKey:@"rating"]) {
        
        NSDictionary* ratingDic = [json objectForKey:@"rating"];
        if (VALID_NOTEMPTY(ratingDic, NSDictionary)) {
            
            if ([ratingDic objectForKey:@"is_enable"]) {
                newConfig.ratingIsEnabled = [ratingDic objectForKey:@"is_enable"];
            }
            
            if ([ratingDic objectForKey:@"required_login"]) {
                newConfig.ratingRequiresLogin = [ratingDic objectForKey:@"required_login"];
            }
        }
    }
    
    if ([json objectForKey:@"review"]) {
        
        NSDictionary* reviewDic = [json objectForKey:@"review"];
        if (VALID_NOTEMPTY(reviewDic, NSDictionary)) {
            
            if ([reviewDic objectForKey:@"is_enable"]) {
                newConfig.reviewIsEnabled = [reviewDic objectForKey:@"is_enable"];
            }
            
            if ([reviewDic objectForKey:@"required_login"]) {
                newConfig.reviewRequiresLogin = [reviewDic objectForKey:@"required_login"];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:kLanguageCodeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    [RICountryConfiguration saveConfiguration:newConfig andContext:YES];
    
    return newConfig;
}

+ (NSString*)formatPrice:(NSNumber*)price country:(RICountryConfiguration*)country
{
    NSDecimalNumber* decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[price decimalValue]];
    NSString* formattedPrice = [decimalNumber stringValue];
    
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
        NSString *millions = @"";
      
        if(0 == [[country noDecimals] integerValue])
        {
            formattedPrice = [NSString stringWithFormat:@"%@%@%@", other, [country thousandsSep], thousands];
            if(6 <[noFraction length])
            {
                thousands = [noFraction substringWithRange:NSMakeRange([noFraction length] - 3, 3)];
                other = [noFraction substringWithRange:NSMakeRange([noFraction length] - 6, 3)];
                millions = [noFraction substringWithRange:NSMakeRange(0, [noFraction length]- 6)];
                formattedPrice = [NSString stringWithFormat:@"%@%@%@%@%@",millions, [country thousandsSep], other, [country thousandsSep], thousands];
            }
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

+ (void)saveConfiguration:(RICountryConfiguration *)configuration andContext:(BOOL)save
{
    for (RILanguage *language in configuration.languages) {
        [RILanguage saveLanguage:language andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:configuration];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
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
