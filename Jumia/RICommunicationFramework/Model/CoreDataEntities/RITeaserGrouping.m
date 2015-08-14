//
//  RITeaserGrouping.m
//  Jumia
//
//  Created by Telmo Pinto on 16/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RITeaserGrouping.h"
#import "RITeaserComponent.h"

@implementation RITeaserGrouping

@dynamic title;
@dynamic type;
@dynamic teaserComponents;

+ (NSString*)loadTeasersIntoDatabaseForCountryUrl:(NSString*)countryUrl
                                 withSuccessBlock:(void (^)(NSArray* teaserGroupings))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    //remove existing ones from database
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RITeaserGrouping class])];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_GET_TEASERS]];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if(VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      NSArray *data = [metadata objectForKey:@"data"];
                                                                      if(VALID_NOTEMPTY(data, NSArray))
                                                                      {
                                                                          NSArray* teaserGroupingsArray = [RITeaserGrouping parseTeaserGroupings:data
                                                                                                           country:configuration];
                                                                          if (VALID_NOTEMPTY(teaserGroupingsArray, NSArray)) {
                                                                              successBlock(teaserGroupingsArray);
                                                                          } else {
                                                                              failureBlock(apiResponse, nil);
                                                                          }
                                                                      } else {
                                                                          failureBlock(apiResponse, nil);
                                                                      }
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, errorMessages);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,   NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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

+ (NSString*)getTeaserGroupingsWithSuccessBlock:(void (^)(NSArray* teaserGroupings))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSString *operationID = nil;
    NSArray *allTeaserGroupings = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RITeaserGrouping
                                                                                                          class])];
    
    if (VALID_NOTEMPTY(allTeaserGroupings, NSArray)) {
        successBlock(allTeaserGroupings);
    } else {
        operationID = [RITeaserGrouping loadTeasersIntoDatabaseForCountryUrl:[RIApi getCountryUrlInUse]
                                                            withSuccessBlock:^(NSArray *teaserGroupings) {
                                                                if (VALID_NOTEMPTY(teaserGroupings, NSArray)) {
                                                                    successBlock(teaserGroupings);
                                                                } else {
                                                                    failureBlock(RIApiResponseUnknownError, nil);
                                                                }
        } andFailureBlock:failureBlock];
    }
    
    return operationID;
}


+ (NSArray*)parseTeaserGroupings:(NSArray*)teaserGroupingsJSONArray
                         country:(RICountryConfiguration*)country
{
    NSMutableArray* newTeaserGroupings = [NSMutableArray new];
    
    if (VALID_NOTEMPTY(teaserGroupingsJSONArray, NSArray)) {
        
        for (NSDictionary* teaserGroupingJSON in teaserGroupingsJSONArray) {
         
            if (VALID_NOTEMPTY(teaserGroupingJSON, NSDictionary)) {
            
                RITeaserGrouping* newTeaserGrouping = [RITeaserGrouping parseTeaserGrouping:teaserGroupingJSON
                                                                                    country:country];
                [newTeaserGroupings addObject:newTeaserGrouping];
            }
        }
    }
    
    return [newTeaserGroupings copy];
}

+ (RITeaserGrouping*)parseTeaserGrouping:(NSDictionary*)teaserGroupingJSON
                                 country:(RICountryConfiguration*)country
{
    RITeaserGrouping* newTeaserGrouping = (RITeaserGrouping*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserGrouping class])];
    
    if (VALID_NOTEMPTY(teaserGroupingJSON, NSDictionary)) {

        if ([teaserGroupingJSON objectForKey:@"title"]) {
            newTeaserGrouping.title = [teaserGroupingJSON objectForKey:@"title"];
        }
        
        if ([teaserGroupingJSON objectForKey:@"type"]) {
            newTeaserGrouping.type = [teaserGroupingJSON objectForKey:@"type"];
        }
        
        NSArray* data = [teaserGroupingJSON objectForKey:@"data"];
        
        if (VALID_NOTEMPTY(data, NSArray)) {

            for (NSDictionary* teaserComponentJSON in data) {
                
                if (VALID_NOTEMPTY(teaserComponentJSON, NSDictionary)) {
                 
                    RITeaserComponent* newTeaserComponent = [RITeaserComponent parseTeaserComponent:teaserComponentJSON
                                                                                            country:country];
                    newTeaserComponent.teaserGrouping = newTeaserGrouping;
                    
                    [newTeaserGrouping addTeaserComponentsObject:newTeaserComponent];
                }
            }
        }
    }
    
    [RITeaserGrouping saveTeaserGrouping:newTeaserGrouping];
    
    return newTeaserGrouping;
}

+ (void)saveTeaserGrouping:(RITeaserGrouping *)teaserGrouping
{
    for (RITeaserComponent *teaserComponent in teaserGrouping.teaserComponents) {
        [RITeaserComponent saveTeaserComponent:teaserComponent];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserGrouping];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
