//
//  RITeaserCategory.m
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaserCategory.h"
#import "RITeaserGroup.h"
#import "RISection.h"
#import "RITeaser.h"
#import "RITeaserImage.h"
#import "RITeaserProduct.h"
#import "RITeaserText.h"

@implementation RITeaserCategory

@dynamic homePageId;
@dynamic homePageTitle;
@dynamic homePageDefault;
@dynamic homePageLayout;
@dynamic md5;
@dynamic teaserGroups;

#pragma mark - Requests

+ (NSString *)loadTeaserCategoriesIntoDatabaseForCountry:(NSString*)countryUrl
                                        withSuccessBlock:(void (^)(id teaserCategories))successBlock
                                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_GET_TEASERS]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if(VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      NSArray *data = [metadata objectForKey:@"data"];
                                                                      if(VALID_NOTEMPTY(data, NSArray))
                                                                      {
                                                                          successBlock([RITeaserCategory parseTeaserCategories:data countryConfiguration:configuration]);
                                                                      }
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
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

+ (NSString*)getTeaserCategoriesWithSuccessBlock:(void (^)(id teaserCategories))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSString *operationID = nil;
    NSArray *allTeaserCategories = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RITeaserCategory class])];
    
    if (VALID_NOTEMPTY(allTeaserCategories, NSArray)) {
        successBlock(allTeaserCategories);
    } else {
        operationID = [RITeaserCategory loadTeaserCategoriesIntoDatabaseForCountry:[RIApi getCountryUrlInUse] withSuccessBlock:^(NSArray *teaserCategories) {
            if (VALID_NOTEMPTY(teaserCategories, NSArray)) {
                successBlock(teaserCategories);
            } else {
                failureBlock(RIApiResponseUnknownError, nil);
            }
        } andFailureBlock:failureBlock];
    }
    
    return operationID;
}

#pragma mark - Cancel operation

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString)) {
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
    }
}

#pragma mark - Parsers

+ (NSArray *)parseTeaserCategories:(NSArray *)teaserCategories
                     countryConfiguration:(RICountryConfiguration*)countryConfiguration
{
    NSMutableArray *returnArray = [NSMutableArray new];
    
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RITeaserCategory class])];
    
    for (NSDictionary *dic in teaserCategories) {
        RITeaserCategory *teaserCategory = [RITeaserCategory parseTeaserCategory:dic countryConfiguration:countryConfiguration];
        
        [RITeaserCategory saveTeaserCategory:teaserCategory];
        
        [returnArray addObject:teaserCategory];
    }
    
    return [returnArray copy];
}

+ (RITeaserCategory *)parseTeaserCategory:(NSDictionary *)json
                     countryConfiguration:(RICountryConfiguration*)countryConfiguration
{
    RITeaserCategory *newCategory = (RITeaserCategory*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserCategory class])];
    
    if ([json objectForKey:@"homepage_id"]) {
        newCategory.homePageId = [NSNumber numberWithInt:[[json objectForKey:@"homepage_id"] integerValue]];
    }
    
    if ([json objectForKey:@"homepage_title"]) {
        newCategory.homePageTitle = [json objectForKey:@"homepage_title"];
    }
    
    if ([json objectForKey:@"homepage_default"]) {
        newCategory.homePageDefault = [NSNumber numberWithInt:[[json objectForKey:@"homepage_default"] integerValue]];
    }
    
    if ([json objectForKey:@"homepage_layout"]) {
        newCategory.homePageLayout = [json objectForKey:@"homepage_layout"];
    }
    
    if ([json objectForKey:@"md5"]) {
        newCategory.md5 = [json objectForKey:@"md5"];
    }
    
    if ([json objectForKey:@"data"]) {
        
        NSArray *dataElements = [json objectForKey:@"data"];
        
        for (NSDictionary *dic in dataElements) {
            
            RITeaserGroup *group = [RITeaserGroup parseTeaserGroup:dic countryConfiguration:countryConfiguration];
            group.teaserCategory = newCategory;
            
            [newCategory addTeaserGroupsObject:group];
            
        }
    }
    
    return newCategory;
}

+ (void)saveTeaserCategory:(RITeaserCategory *)teaserCategory
{
    for (RITeaserGroup *teaserGroup in teaserCategory.teaserGroups) {
        [RITeaserGroup saveTeaserGroup:teaserGroup];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserCategory];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
