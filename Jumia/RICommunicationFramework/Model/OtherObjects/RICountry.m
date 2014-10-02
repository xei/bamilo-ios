//
//  RICountry.m
//  Comunication Project
//
//  Created by Pedro Lopes on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICountry.h"

@implementation RICountry

#pragma mark - Requests

+ (NSString*)getCountriesWithSuccessBlock:(void (^)(id countries))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSString *countryListURL = RI_COUNTRIES_URL;
#if defined(DEBUG) && DEBUG
    countryListURL = [NSString stringWithFormat:@"%@/staging", RI_COUNTRIES_URL];
#endif
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:countryListURL]
                                                             parameters:nil
                                                         httpMethodPost:NO
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
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
                                withSuccessBlock:(void (^)(RICountryConfiguration *configuration))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return  [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_COUNTRY_CONFIGURATION]]
                                                             parameters:nil
                                                         httpMethodPost:YES
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheNoTime
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
        operationID = [RICountry loadCountryConfigurationForCountry:[RIApi getCountryUrlInUse] withSuccessBlock:^(RICountryConfiguration *configuration) {
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
    
    return [countriesArray copy];
}

+ (RICountry *)parseCountryWithJson:(NSDictionary *)jsonObject
{
    RICountry *country = [[RICountry alloc] init];
    
    if ([jsonObject objectForKey:@"name"]) {
        country.name = [jsonObject objectForKey:@"name"];
    }
    
    if ([jsonObject objectForKey:@"url"]) {
        country.url = [jsonObject objectForKey:@"url"];
    }
    
    if ([jsonObject objectForKey:@"flag"]) {
        country.flag = [jsonObject objectForKey:@"flag"];
    }
    
    if ([jsonObject objectForKey:@"map_images"]) {
        NSDictionary *mapImagesObject =[jsonObject objectForKey:@"map_images"];
        NSMutableDictionary *mapImagesDictionary = [[NSMutableDictionary alloc] init];
        if(VALID_NOTEMPTY(mapImagesObject, NSDictionary)) {
            NSArray *mapImagesObjectKeys = [mapImagesObject allKeys];
            for(NSString *mapImageKey in mapImagesObjectKeys) {
                // TODO: Add filter to only sho iOS retina and non-retina images; check image keys
                // if(([@"retina" caseInsensitiveCompare:mapImageKey] == NSOrderedSame) || ([@"non-retina" caseInsensitiveCompare:mapImageKey] == NSOrderedSame))
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
    
    return country;
}

@end
