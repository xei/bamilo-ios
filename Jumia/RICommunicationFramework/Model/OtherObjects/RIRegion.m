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
               andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock([RIRegion parseRegions:metadata]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
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
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"id_customer_address_region"], NSString))
    {
        newRegion.uid = [regionObject objectForKey:@"id_customer_address_region"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"fk_country"], NSString))
    {
        newRegion.fkCountry = [regionObject objectForKey:@"fk_country"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"code"], NSString))
    {
        newRegion.code = [regionObject objectForKey:@"code"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"name"], NSString))
    {
        newRegion.name = [regionObject objectForKey:@"name"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"sort"], NSString))
    {
        newRegion.sort = [regionObject objectForKey:@"sort"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"created_at"], NSString))
    {
        newRegion.createdAt = [regionObject objectForKey:@"created_at"];
    }
    
    if(VALID_NOTEMPTY([regionObject objectForKey:@"updated_at"], NSString))
    {
        newRegion.updatedAt = [regionObject objectForKey:@"updated_at"];
    }
    
    return newRegion;
}

@end
