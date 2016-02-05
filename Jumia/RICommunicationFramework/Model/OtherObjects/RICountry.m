//
//  RICountry.m
//  Comunication Project
//
//  Created by Pedro Lopes on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICountry.h"
#import "RIPhonePrefix.h"

@implementation RICountry

#pragma mark - Requests

+ (NSString*)getCountriesWithSuccessBlock:(void (^)(id countries))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSString *countryListURL;
    
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        countryListURL = RI_COUNTRIES_URL_JUMIA;
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        countryListURL = RI_COUNTRIES_URL_DARAZ;
    }
#if defined(STAGING) && STAGING
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        countryListURL = RI_COUNTRIES_URL_JUMIA_STAGING;
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        countryListURL = RI_COUNTRIES_URL_DARAZ_STAGING;
    }
#endif
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:countryListURL]
                                                             parameters:nil
                                                             httpMethod:HttpResponseGet
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
                                                     userAgentInjection:nil
                                                           successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               
                                                               if (VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                               {
                                                                   NSDictionary *metadataObject = [jsonObject objectForKey:@"metadata"];
                                                                   NSArray *countriesArray = [RICountry parseCountriesWithJson:metadataObject];
                                                                   
                                                                   if(VALID_NOTEMPTY(countriesArray, NSArray))
                                                                   {
                                                                       successBlock(countriesArray);
                                                                   } else
                                                                   {
                                                                       failureBlock(apiResponse, nil);
                                                                   }
                                                               }
                                                           } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                               if(NOTEMPTY(errorJsonObject))
                                                               {
                                                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                               } else if(NOTEMPTY(errorObject))
                                                               {
                                                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                   failureBlock(apiResponse, errorArray);
                                                               } else
                                                               {
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                           }];
}

+ (NSString *)loadCountryConfigurationForCountry:(NSString*)countryUrl
                              userAgentInjection:(NSString*)userAgentInjection
                                withSuccessBlock:(void (^)(RICountryConfiguration *configuration))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_COUNTRY_CONFIGURATION]]
                                                             parameters:nil
                                                             httpMethod:HttpResponsePost
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
                                                     userAgentInjection:userAgentInjection
                                                           successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               
                                                               if ([jsonObject objectForKey:@"metadata"]) {
                                                                   RICountryConfiguration *config = [RICountryConfiguration parseCountryConfiguration:[jsonObject objectForKey:@"metadata"]];
                                                                   
                                                                   successBlock(config);
                                                               } else {
                                                                   
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                               
                                                           } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                               
                                                               if(NOTEMPTY(errorJsonObject)) {
                                                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                               } else if(NOTEMPTY(errorObject)) {
                                                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                   failureBlock(apiResponse, errorArray);
                                                               } else {
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                           }];
}

+ (NSString *)getCountryConfigurationWithSuccessBlock:(void (^)(RICountryConfiguration *configuration))successBlock
                                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSString *operationID = nil;
    
    NSArray *configuration = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    if (VALID_NOTEMPTY(configuration, NSArray)) {
        successBlock([configuration firstObject]);
    } else {
        operationID = [RICountry loadCountryConfigurationForCountry:[RIApi getCountryUrlInUse] userAgentInjection:[RIApi getCountryUserAgentInjection] withSuccessBlock:^(RICountryConfiguration *configuration) {
            successBlock(configuration);
        } andFailureBlock:failureBlock];
    }
    
    return operationID;
}

+ (NSString *)getCountryPhoneNumber
{
    NSArray *configuration = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICountryConfiguration class])];
    
    RICountryConfiguration *config = (RICountryConfiguration *)configuration[0];
    
    return config.phoneNumber;
}

#pragma mark - Cancel request

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Parsers

+ (NSArray *)parseCountriesWithJson:(NSDictionary *)jsonObject
{
    NSMutableArray *countriesArray = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(jsonObject, NSDictionary)) {
        NSArray *dataArray = [jsonObject objectForKey:@"data"];
        if(VALID_NOTEMPTY(dataArray, NSArray)) {
            for(NSDictionary *countryJsonObject in dataArray) {
                RICountry *country = [RICountry parseCountryWithJson:countryJsonObject];
                [countriesArray addObject:country];
            }
        }
    }
    
    //INSERTING INTEGRATION MOBILE
    //*****************
//    NSMutableDictionary* integrationDict = [NSMutableDictionary new];
//    
//    [integrationDict setObject:@"MA" forKey:@"country_iso"];
//    [integrationDict setObject:@"http://www.jumia.com/images/mobapi/flag_morocco.png" forKey:@"flag"];
//    [integrationDict setObject:[NSNumber numberWithBool:0] forKey:@"force_files"];
//    [integrationDict setObject:@"Integration Mobile Maroc" forKey:@"name"];
//    [integrationDict setObject:@"integration-mobile-www.jumia.ma/mobapi/" forKey:@"url"];
//    
//    NSMutableDictionary* mapFiles = [NSMutableDictionary new];
//    [mapFiles setObject:@"http://www.jumia.com/images/mobapi/map_hdpi_ma.png" forKey:@"hdpi"];
//    [mapFiles setObject:@"http://www.jumia.com/images/mobapi/map_mdpi_ma.png" forKey:@"mdpi"];
//    [mapFiles setObject:@"http://www.jumia.com/images/mobapi/map_xhdpi_ma.png" forKey:@"xdpi"];
//    
//    [integrationDict setObject:mapFiles forKey:@"map_files"];
//    
//    RICountry *country = [RICountry parseCountryWithJson:integrationDict];
//    [countriesArray addObject:country];
    //*****************
    
    return [countriesArray copy];
}

+ (RICountry *)parseCountryWithJson:(NSDictionary *)jsonObject
{
    RICountry *country = [[RICountry alloc] init];
    
    if ([jsonObject objectForKey:@"name"]) {
        country.name = [jsonObject objectForKey:@"name"];
    }
    
    if ([jsonObject objectForKey:@"flag"]) {
        country.flag = [jsonObject objectForKey:@"flag"];
    }
    
    if ([jsonObject objectForKey:@"map_files"]) {
        NSDictionary *mapImagesObject =[jsonObject objectForKey:@"map_files"];
        NSMutableDictionary *mapImagesDictionary = [[NSMutableDictionary alloc] init];
        if(VALID_NOTEMPTY(mapImagesObject, NSDictionary)) {
            NSArray *mapImagesObjectKeys = [mapImagesObject allKeys];
            for(NSString *mapImageKey in mapImagesObjectKeys) {
                [mapImagesDictionary setValue:[mapImagesObject objectForKey:mapImageKey] forKey:mapImageKey];
            }
        }
        country.mapImages = [mapImagesDictionary copy];
    }
    
    if ([jsonObject objectForKey:@"force_https"]) {
        country.forceHttps = [[jsonObject objectForKey:@"force_https"] boolValue];
    }
    
    if ([jsonObject objectForKey:@"is_live"]) {
        country.isLive = [[jsonObject objectForKey:@"is_live"] boolValue];
    }
    
    if ([jsonObject objectForKey:@"country_iso"]) {
        country.countryIso = [jsonObject objectForKey:@"country_iso"];
    }
    
    if ([jsonObject objectForKey:@"url"]) {
        if([[jsonObject objectForKey:@"url"] rangeOfString:@"http://"].location == NSNotFound && [[jsonObject objectForKey:@"url"] rangeOfString:@"https://"].location == NSNotFound)
        {
            if(country.forceHttps)
            {
                country.url = [NSString stringWithFormat:@"%@%@", @"https://", [jsonObject objectForKey:@"url"]];
            }
            else
            {
                country.url = [NSString stringWithFormat:@"%@%@", @"http://", [jsonObject objectForKey:@"url"]];
            }
        }
        else
        {
            country.url = [jsonObject objectForKey:@"url"];
        }
    }
    
    if ([jsonObject objectForKey:@"user_agent"]) {
        country.userAgentInjection = [jsonObject objectForKey:@"user_agent"];
    }
    
    if ([jsonObject objectForKey:@"languages"]) {
        NSArray* languagesArrayJSON = [jsonObject objectForKey:@"languages"];
        if (VALID_NOTEMPTY(languagesArrayJSON, NSArray)) {
            NSMutableArray* languagesArray = [NSMutableArray new];
            for (NSDictionary* languageJSON in languagesArrayJSON) {
                RILanguage* newLanguage = [RILanguage parseLanguage:languageJSON];
                [languagesArray addObject:newLanguage];
            }
            country.languages = [languagesArray copy];
        }
    }
    
    return country;
}

+ (RICountry*)getUniqueCountry
{
    RICountry* uniqueCountry = [[RICountry alloc] init];
    if([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        NSDictionary* languageJSON = @{@"code":@"my_MM",@"default":@1,@"name":@"ျမန္မာ"};
        RILanguage* language = [RILanguage parseLanguage:languageJSON];
        uniqueCountry.selectedLanguage = language;
        uniqueCountry.name = RI_UNIQUE_COUNTRY_NAME_SHOP;
        uniqueCountry.countryIso = RI_UNIQUE_COUNTRY_ISO_SHOP;
        uniqueCountry.url = RI_UNIQUE_COUNTRY_URL_SHOP;
        uniqueCountry.isLive = YES;
#if defined(STAGING) && STAGING
        uniqueCountry.url = RI_UNIQUE_COUNTRY_URL_SHOP_STAGING;
        uniqueCountry.isLive = NO;
        uniqueCountry.userAgentInjection = RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_SHOP;
#endif
        return uniqueCountry;
    } else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"]) {
        NSDictionary* languageJSON = @{@"code":@"fa_IR",@"default":@1,@"name":@"فارسی"};
        RILanguage* language = [RILanguage parseLanguage:languageJSON];
        uniqueCountry.selectedLanguage = language;
        uniqueCountry.name = RI_UNIQUE_COUNTRY_NAME_BAMILO;
        uniqueCountry.countryIso = RI_UNIQUE_COUNTRY_ISO_BAMILO;
        uniqueCountry.url = RI_UNIQUE_COUNTRY_URL_BAMILO;
        uniqueCountry.isLive = YES;
//#if defined(STAGING) && STAGING
//        uniqueCountry.url = RI_UNIQUE_COUNTRY_URL_BAMILO_STAGING;
//        uniqueCountry.isLive = NO;
//        uniqueCountry.userAgentInjection = RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_BAMILO_INTEGRATION_MOBILE;
//#endif
        return uniqueCountry;
    } else {
        return nil;
    }
}

+ (NSString *)getCountryPhonePrefixesWithSuccessBlock:(void (^)(NSArray *prefixes))successBlock
                                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_PHONE_PREFIXES]]
                                                             parameters:nil
                                                             httpMethod:HttpResponsePost
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
                                                     userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                           successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               
                                                               NSMutableArray *prefixes = [NSMutableArray new];
                                                               if ([jsonObject objectForKey:@"metadata"]) {
                                                                   NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                   if (VALID_NOTEMPTY([metadata objectForKey:@"data"], NSArray)) {
                                                                       for (NSDictionary *prefix in [metadata objectForKey:@"data"]) {
                                                                           [prefixes addObject:[RIPhonePrefix parse:prefix]];
                                                                       }
                                                                   }
                                                                   
                                                                   successBlock([prefixes copy]);
                                                               } else {
                                                                   
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                               
                                                           } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                               
                                                               if(NOTEMPTY(errorJsonObject)) {
                                                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                               } else if(NOTEMPTY(errorObject)) {
                                                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                   failureBlock(apiResponse, errorArray);
                                                               } else {
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                           }];
}

+ (NSString *)getCountryFaqAndTermsWithSuccessBlock:(void (^)(NSArray *faqAndTerms))successBlock
                                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_FAQ_AND_TERMS]]
                                                             parameters:nil
                                                         httpMethod:HttpResponsePost
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
                                                     userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                           successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               
                                                               if ([jsonObject objectForKey:@"metadata"]) {
                                                                   NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                   if (VALID_NOTEMPTY([metadata objectForKey:@"data"], NSArray)) {
                                                                       successBlock([[metadata objectForKey:@"data"] copy]);
                                                                       return;
                                                                   }
                                                               }
                                                               failureBlock(apiResponse, nil);
                                                               
                                                           } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                               
                                                               if(NOTEMPTY(errorJsonObject)) {
                                                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                               } else if(NOTEMPTY(errorObject)) {
                                                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                   failureBlock(apiResponse, errorArray);
                                                               } else {
                                                                   failureBlock(apiResponse, nil);
                                                               }
                                                           }];
}

@end
