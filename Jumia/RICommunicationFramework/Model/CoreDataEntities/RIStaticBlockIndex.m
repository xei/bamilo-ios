//
//  RIStaticBlockIndex.m
//  Jumia
//
//  Created by Telmo Pinto on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIStaticBlockIndex.h"


@implementation RIStaticBlockIndex

@dynamic key;
@dynamic url;
@dynamic data;

+ (NSString*)getStaticBlock:(NSString*)staticBlockKey
               successBlock:(void (^)(id staticBlock))successBlock
               failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
{
    NSArray* staticBlockIndexes = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIStaticBlockIndex class])];
    
    for (RIStaticBlockIndex* staticBlockIndex in staticBlockIndexes) {
        
        if (VALID_NOTEMPTY(staticBlockIndex, RIStaticBlockIndex) && [staticBlockIndex.key isEqualToString:staticBlockKey]) {
            //found it
            
            if (VALID_NOTEMPTY(staticBlockIndex.data, NSString)) {
                
                successBlock(staticBlockIndex.data);
                
            } else if (VALID_NOTEMPTY(staticBlockIndex.url, NSString)){
                
                return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:staticBlockIndex.url]
                                                                        parameters:nil httpMethodPost:YES
                                                                         cacheType:RIURLCacheNoCache
                                                                         cacheTime:RIURLCacheDefaultTime
                                                                      successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                                          
                                                                          NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                          if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                              
                                                                              NSArray* data = [metadata objectForKey:@"data"];
                                                                              
                                                                              if (VALID_NOTEMPTY(data, NSArray)) {
                                                                                  
                                                                                  staticBlockIndex.data = [data firstObject];
                                                                                  //static block index was already on database, it just lacked the data variable. let's save the context without adding any other NSManagedObject
                                                                                  [[RIDataBaseWrapper sharedInstance] saveContext];
                                                                                  successBlock([data firstObject]);
                                                                              }
                                                                          } else {
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
        }
    }
    
    return nil;
}

+ (NSString*)loadStaticBlockIndexesIntoDatabaseForCountry:(NSString*)countryUrl
                                         withSuccessBlock:(void (^)(id staticBlockIndexes))successBlock
                                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_GET_STATICBLOCKS]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  successBlock([RIStaticBlockIndex parseStaticBlockIndexes:metadata]);
                                                              } else {
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

+ (NSArray*)parseStaticBlockIndexes:(NSDictionary*)staticBlockIndexesJSON;
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIStaticBlockIndex class])];
    
    NSMutableArray* newStaticBlocks = [NSMutableArray new];
    
    NSArray* data = [staticBlockIndexesJSON objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(data, NSArray)) {
        for (NSDictionary* staticBlockIndexJSON in data) {
            
            if (VALID_NOTEMPTY(staticBlockIndexJSON, NSDictionary)) {
                
                RIStaticBlockIndex* staticBlockIndex = [RIStaticBlockIndex parseStaticBlockIndex:staticBlockIndexJSON];
                [RIStaticBlockIndex saveStaticBlockIndex:staticBlockIndex];
                [newStaticBlocks addObject:staticBlockIndex];
            }
        }
    }
    
    return newStaticBlocks;
}

+ (RIStaticBlockIndex*)parseStaticBlockIndex:(NSDictionary*)staticBlockIndexJSON
{
    RIStaticBlockIndex* newStaticBlockIndex = (RIStaticBlockIndex*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIStaticBlockIndex class])];
    
    if ([staticBlockIndexJSON objectForKey:@"key"]) {
        newStaticBlockIndex.key = [staticBlockIndexJSON objectForKey:@"key"];
    }
    if ([staticBlockIndexJSON objectForKey:@"url"]) {
        newStaticBlockIndex.url = [staticBlockIndexJSON objectForKey:@"url"];
    }
    
    return newStaticBlockIndex;
}

+ (void)saveStaticBlockIndex:(RIStaticBlockIndex*)staticBlockIndex;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:staticBlockIndex];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
