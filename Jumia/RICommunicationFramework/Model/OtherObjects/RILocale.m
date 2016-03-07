//
//  RILocale.m
//  Jumia
//
//  Created by Telmo Pinto on 30/09/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RILocale.h"

@implementation RILocale

+ (NSString *)getLocalesForUrl:(NSString*)url
                    parameters:(NSDictionary *)parameters
                  successBlock:(void (^)(NSArray *regions))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:parameters
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock([RILocale parseLocaleArray:metadata]);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
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


+ (NSArray*)parseLocaleArray:(NSDictionary*)jsonObject
{
    NSMutableArray *localesMutableArray = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY([jsonObject objectForKey:@"data"], NSArray))
    {
        NSArray *dataArray = [jsonObject objectForKey:@"data"];
        for(NSDictionary *localeJSON in dataArray)
        {
            [localesMutableArray addObject:[RILocale parseLocale:localeJSON]];
        }
    }
    return [localesMutableArray copy];
}

+ (RILocale*)parseLocale:(NSDictionary*)localeObject
{
    RILocale* newLocale = [[RILocale alloc] init];
    
    if(VALID_NOTEMPTY([localeObject objectForKey:@"value"], NSString))
    {
        newLocale.value = [localeObject objectForKey:@"value"];
    } else if (VALID_NOTEMPTY([localeObject objectForKey:@"value"], NSNumber)) {
        NSNumber* value = [localeObject objectForKey:@"value"];
        newLocale.value = [value stringValue];
    }
    
    if(VALID_NOTEMPTY([localeObject objectForKey:@"label"], NSString))
    {
        newLocale.label = [localeObject objectForKey:@"label"];
    }
    
    return newLocale;
}


@end
