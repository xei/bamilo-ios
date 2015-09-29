//
//  RIRegion.m
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIRegion.h"

@implementation RIRegion

+ (NSString *)getRegionsForUrl:(NSString*)url
                  successBlock:(void (^)(NSArray *regions))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock([RIRegion parseRegions:metadata]);
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

+ (NSArray*)parseRegions:(NSDictionary*)jsonObject
{
    NSMutableArray *regions = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY([jsonObject objectForKey:@"data"], NSArray))
    {
        NSArray *dataArray = [jsonObject objectForKey:@"data"];
        for(NSDictionary *regionObject in dataArray)
        {
            [regions addObject:[RIRegion parseRegion:regionObject]];
        }
    }
    return [regions copy];
}

+ (RIRegion*)parseRegion:(NSDictionary*)regionObject
{
    RIRegion *newRegion = [[RIRegion alloc] init];
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"value"], NSString))
    {
        newRegion.value = [regionObject objectForKey:@"value"];
    } else if (VALID_NOTEMPTY([regionObject objectForKey:@"value"], NSNumber)) {
        NSNumber* value = [regionObject objectForKey:@"value"];
        newRegion.value = [value stringValue];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"label"], NSString))
    {
        newRegion.label = [regionObject objectForKey:@"label"];
    }
    
    return newRegion;
}

@end
