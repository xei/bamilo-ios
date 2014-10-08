//
//  RICity.m
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICity.h"

@implementation RICity

+ (NSString *)getCitiesForUrl:(NSString*)url
                       region:(NSString*)regionId
                 successBlock:(void (^)(NSArray *cities))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    url = [url stringByReplacingOccurrencesOfString:@"fk_customer_address_region" withString:regionId];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock([RICity parseCities:metadata]);
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

+ (NSArray*)parseCities:(NSDictionary*)jsonObject
{
    NSMutableArray *cities = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY([jsonObject objectForKey:@"data"], NSArray))
    {
        NSArray *dataArray = [jsonObject objectForKey:@"data"];
        for(NSDictionary *cityObject in dataArray)
        {
            [cities addObject:[RICity parseRegion:cityObject]];
        }
    }
    return [cities copy];
}

+ (RICity*)parseRegion:(NSDictionary*)cityObject
{
    RICity* newCity = [[RICity alloc] init];
    
    if(VALID_NOTEMPTY([cityObject objectForKey:@"id"], NSString))
    {
        newCity.uid = [cityObject objectForKey:@"id"];
    }
    
    if(VALID_NOTEMPTY([cityObject objectForKey:@"value"], NSString))
    {
        newCity.value = [cityObject objectForKey:@"value"];
    }
    
    if(VALID_NOTEMPTY([cityObject objectForKey:@"group"], NSString))
    {
        newCity.group = [cityObject objectForKey:@"group"];
    }
    
    return newCity;
}


@end
