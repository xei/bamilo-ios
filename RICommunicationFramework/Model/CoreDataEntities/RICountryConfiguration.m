//
//  RICountryConfiguration.m
//  Comunication Project
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICountryConfiguration.h"
#import "RILanguage.h"
#import "NSString+Extensions.h"

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
@dynamic richRelevanceEnabled;
@dynamic suggesterProvider;
@dynamic algoliaAppId;
@dynamic algoliaNamespacePrefix;
@dynamic algoliaApiKey;

@dynamic casIsActive;
@dynamic casTitle;
@dynamic casSubtitle;
@dynamic casImages;

@dynamic redirectHtml;
@dynamic redirectStringTarget;

@synthesize suggesterProviderEnum;

+ (RICountryConfiguration *)parseCountryConfiguration:(NSDictionary *)json
{
    RICountryConfiguration *newConfig = (RICountryConfiguration*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICountryConfiguration class])];
    
    if (VALID_NOTEMPTY([json objectForKey:@"redirect_info"], NSDictionary)) {
        NSDictionary *redirectInfo = [json objectForKey:@"redirect_info"];
        if (VALID_NOTEMPTY([redirectInfo objectForKey:@"ios_link"], NSString) && VALID_NOTEMPTY([redirectInfo objectForKey:@"html"], NSString)) {
            [newConfig setRedirectHtml:[redirectInfo objectForKey:@"html"]];
            [newConfig setRedirectStringTarget:[RITarget getTargetString:EXTERNAL_LINK node:[redirectInfo objectForKey:@"ios_link"]]];
        }
    }
    
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
    
    if([json objectForKey:@"rich_relevance_enabled"]){
        newConfig.richRelevanceEnabled = [json objectForKey:@"rich_relevance_enabled"];
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
    
    newConfig.suggesterProvider = VALID_VALUE([json objectForKey:@"suggester_provider"], NSString);
    
    NSDictionary *algolia = VALID_VALUE([json objectForKey:@"algolia"], NSDictionary);
    if (algolia) {
        newConfig.algoliaAppId = VALID_VALUE([algolia objectForKey:@"application_id"], NSString);
        newConfig.algoliaNamespacePrefix = VALID_VALUE([algolia objectForKey:@"namespace_prefix"], NSString);
        newConfig.algoliaApiKey = VALID_VALUE([algolia objectForKey:@"suggester_api_key"], NSString);
    }
    
    if (VALID_NOTEMPTY([json objectForKey:@"auth_info"], NSDictionary)) {
        NSDictionary *casDictionary = [json objectForKey:@"auth_info"];
        newConfig.casIsActive = @YES;
        newConfig.casTitle = [casDictionary objectForKey:@"title"];
        newConfig.casSubtitle = [casDictionary objectForKey:@"sub_title"];
        
        NSMutableArray* urlMutableArray = [NSMutableArray new];
        NSArray* imageList = [casDictionary objectForKey:@"image_list"];
        if (VALID_NOTEMPTY(imageList, NSArray)) {
            for (NSDictionary* urlDic in imageList) {
                if (VALID_NOTEMPTY(urlDic, NSDictionary)) {
                    NSString* urlString = [urlDic objectForKey:@"url"];
                    if (VALID_NOTEMPTY(urlString, NSString)) {
                        [urlMutableArray addObject:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                    }
                }
            }
        }
        newConfig.casImages = [urlMutableArray copy];
    }
    
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    [RICountryConfiguration saveConfiguration:newConfig andContext:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckRedirectInfoNotification object:nil];
    
    return newConfig;
}

- (SuggesterProvider)suggesterProviderEnum
{
    if (VALID_NOTEMPTY(self.suggesterProvider, NSString) && [self.suggesterProvider isEqualToString:@"algolia"]) {
        return ALGOLIA;
    }
    return API;
}

+ (NSString*)formatPrice:(NSNumber*)price country:(RICountryConfiguration*)country {
    NSString *priceString = [NSString stringWithFormat:@"%ld", price.longValue ?: 0];
    return [NSString stringWithFormat:@"%@ %@", [[priceString formatPrice] numbersToPersian], STRING_CURRENCY];
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
