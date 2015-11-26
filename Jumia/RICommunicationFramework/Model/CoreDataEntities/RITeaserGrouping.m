//
//  RITeaserGrouping.m
//  Jumia
//
//  Created by Telmo Pinto on 16/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RITeaserGrouping.h"
#import "RITeaserComponent.h"
#import "RIForm.h"

@implementation RITeaserGrouping

@dynamic title;
@dynamic type;
@dynamic teaserComponents;

+ (NSString*)loadTeasersIntoDatabaseForCountryUrl:(NSString*)countryUrl
                        countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                 withSuccessBlock:(void (^)(NSDictionary* teaserGroupings, BOOL richTeasers))successBlock
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
                                                    userAgentInjection:countryUserAgentInjection
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if(VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      NSArray *data = [metadata objectForKey:@"data"];
                                                                      if(VALID_NOTEMPTY(data, NSArray))
                                                                      {
                                                                          NSDictionary* teaserGroupingsDict = [RITeaserGrouping parseTeaserGroupings:data
                                                                                                           country:configuration];
                                                                          if (VALID_NOTEMPTY(teaserGroupingsDict, NSDictionary)) {
                                                                              if ([teaserGroupingsDict objectForKey:@"richTeaserGroupings"]) {
                                                                                  successBlock(teaserGroupingsDict,YES);
                                                                              } else
                                                                                  successBlock(teaserGroupingsDict,NO);
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

+ (NSString*)getTeaserGroupingsWithSuccessBlock:(void (^)(NSDictionary* teaserGroupings, BOOL richTeaserGrouping))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
                                   andRichBlock:(void (^)(RITeaserGrouping * richTeaserGrouping))richBlock
{
    NSString *operationID = nil;
    NSArray *allTeaserGroupings = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RITeaserGrouping
                                                                                                          class])];
    
    if (VALID_NOTEMPTY(allTeaserGroupings, NSArray)) {
        NSDictionary* allTeaserGroupingsDict = [NSDictionary dictionaryWithObjects:allTeaserGroupings
                                                         forKeys:[allTeaserGroupings valueForKey:@"type"]];
        successBlock(allTeaserGroupingsDict,NO);
    } else {
        operationID = [RITeaserGrouping loadTeasersIntoDatabaseForCountryUrl:[RIApi getCountryUrlInUse]
                                                   countryUserAgentInjection:[RIApi getCountryUserAgentInjection]
                                                            withSuccessBlock:^(NSDictionary* teaserGroupings, BOOL richTeasers) {
                                                                if (VALID_NOTEMPTY(teaserGroupings, NSDictionary)) {
                                                                    
                                                                    if ([teaserGroupings objectForKey:@"richTeaserGroupings"]) {
                                                                        NSMutableDictionary *withoutRich = [NSMutableDictionary dictionaryWithDictionary:teaserGroupings];
                                                                        [withoutRich removeObjectForKey:@"richTeaserGroupings"];
                                                                        
                                                                        successBlock(withoutRich,YES);
                                                                        [RITeaserGrouping getTeaserRichRelevance:[teaserGroupings objectForKey:@"richTeaserGroupings"]
                                                                                                    successBlock:richBlock
                                                                                                 andFailureBlock:failureBlock];
                                                                    } else
                                                                        successBlock(teaserGroupings, NO);
                                                                } else {
                                                                    failureBlock(RIApiResponseUnknownError, nil);
                                                                }
                                                            } andFailureBlock:failureBlock];
    }

    return operationID;
}

+ (void)getTeaserRichRelevance:(NSDictionary*) richTeasers
                  successBlock:(void(^)(RITeaserGrouping * richTeaserGrouping))richBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSDictionary *topSellerJson = [richTeasers objectForKey:@"top_sellers"];
    
    
    NSString *target = [[[topSellerJson objectForKey:@"target"] componentsSeparatedByString:@"::"] objectAtIndex:1];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@richrelevance/request/req/%@/", [RIApi getCountryUrlInUse], RI_API_VERSION, target]];
    
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                     parameters:nil
                                                 httpMethodPost:YES
                                                      cacheType:RIURLCacheNoCache
                                                      cacheTime:RIURLCacheDefaultTime
                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary* jsonObject){
                                                       [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                           NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                           
                                                           if(VALID_NOTEMPTY(metadata, NSDictionary))
                                                           {
                                                               NSArray *data = [metadata objectForKey:@"data"];
                                                               if(VALID_NOTEMPTY(data, NSArray))
                                                               {
                                                                   RITeaserGrouping* teaserGrouping = [RITeaserGrouping parseTeaserGrouping:metadata
                                                                                                                                    country:configuration];
                                                                   if (VALID_NOTEMPTY(teaserGrouping, RITeaserGrouping)) {
                                                                       if (richBlock) {
                                                                           richBlock(teaserGrouping);
                                                                       }
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
                                                       } andFailureBlock:failureBlock];
                                                   }
                                                   failureBlock:^(RIApiResponse apiResponse,   NSDictionary* errorJsonObject, NSError *errorObject) {
                                                       
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

+ (NSDictionary*)parseTeaserGroupings:(NSArray*)teaserGroupingsJSONArray
                         country:(RICountryConfiguration*)country
{
    NSMutableDictionary* newTeaserGroupings = [NSMutableDictionary new];
    NSMutableDictionary* newRichTeaserGroupings = [NSMutableDictionary new];
    NSMutableDictionary* newFormTeaser = [NSMutableDictionary new];
    
    if (VALID_NOTEMPTY(teaserGroupingsJSONArray, NSArray)) {
        
        for (NSDictionary* teaserGroupingJSON in teaserGroupingsJSONArray) {
            
            if (VALID_NOTEMPTY(teaserGroupingJSON, NSDictionary)) {
                
                if ([teaserGroupingJSON objectForKey:@"has_data"]) {
                    NSNumber* hasData = [teaserGroupingJSON objectForKey:@"has_data"];
                    if ( [hasData boolValue]) {
                        
                        if ([[teaserGroupingJSON objectForKey:@"type"] isEqualToString:@"form_newsletter"]) {
                            RIForm* form_newsletter = [RIForm parseForm:[teaserGroupingJSON objectForKey:@"data"]];
                            [newFormTeaser setObject:form_newsletter forKey:@"form_newsletter"];
                        } else {
                            
                            RITeaserGrouping* newTeaserGrouping = [RITeaserGrouping parseTeaserGrouping:teaserGroupingJSON
                                                                                                country:country];
                            [newTeaserGroupings setObject:newTeaserGrouping forKey:[teaserGroupingJSON objectForKey:@"type"]];
                        }
                    } else {
                        if ([[teaserGroupingJSON objectForKey:@"type"] isEqualToString:@"top_sellers"]) {
                            [newRichTeaserGroupings setObject:teaserGroupingJSON forKey:[teaserGroupingJSON objectForKey:@"type"]];
                            
                        }
                    }
                }
            }
        }
    }

    if (VALID_NOTEMPTY(newRichTeaserGroupings, NSMutableDictionary)) {
        [newTeaserGroupings setObject:newRichTeaserGroupings forKey:@"richTeaserGroupings"];
        
    }
    if (VALID_NOTEMPTY(newFormTeaser, NSMutableDictionary)) {
        [newTeaserGroupings setObject:newFormTeaser forKey:@"formTeaser"];
        
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
    
    [RITeaserGrouping saveTeaserGrouping:newTeaserGrouping andContext:YES];
    
    return newTeaserGrouping;
}

+ (void)saveTeaserGrouping:(RITeaserGrouping *)teaserGrouping andContext:(BOOL)save
{
    for (RITeaserComponent *teaserComponent in teaserGrouping.teaserComponents) {
        [RITeaserComponent saveTeaserComponent:teaserComponent andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserGrouping];
    
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
}

@end
