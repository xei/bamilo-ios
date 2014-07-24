//
//  RIApi.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIApi.h"
#import "RISection.h"
#import "RICategory.h"
#import "RIFormIndex.h"
#import "RITeaserCategory.h"
#import "RIImageResolution.h"
#import "RICountry.h"
#import "RICountryConfiguration.h"
#import "RIStaticBlockIndex.h"

@implementation RIApi

@dynamic actionName;
@dynamic curMobVersion;
@dynamic curVersion;
@dynamic minMobVersion;
@dynamic minVersion;
@dynamic sections;

+ (NSString *)startApiWithSuccessBlock:(void (^)(id api))successBlock
                       andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_INFO]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  
                                                                  RIApi* newApi = [RIApi parseApi:metadata];
                                                                  
                                                                  //check coredata for api
                                                                  
                                                                  NSArray* apiArrayFromCoreData = [[RIDataBaseWrapper sharedInstance]allEntriesOfType:NSStringFromClass([RIApi class])];
                                                                  
                                                                  RIApi* oldApi = [apiArrayFromCoreData firstObject];
                                                                  
                                                                  for (RISection* newSection in newApi.sections) {
                                                                      
                                                                      BOOL sectionNeedsDownload = YES;
                                                                      
                                                                      if (VALID(oldApi, RIApi)) {
                                                                          for (RISection* oldSection in oldApi.sections) {
                                                                              
                                                                              if ([newSection.name isEqualToString:oldSection.name]) {
                                                                                  //found it
                                                                                  if ([newSection.md5 isEqualToString:oldSection.md5]) {
                                                                                      
                                                                                      sectionNeedsDownload = NO;
                                                                                  }
                                                                              }
                                                                          }
                                                                      }
                                                                      
                                                                      if (sectionNeedsDownload) {
                                                                          
                                                                          [RIApi requestSectionContent:newSection successBlock:^() {
                                                                              
                                                                          } andFailureBlock:^(id error) {
                                                                              
                                                                          }];
                                                                      }
                                                                  }
                                                                  
                                                                  //save new api in coredata
                                                                  
                                                                  [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIApi class])];
                                                                  [RIApi saveApi:newApi];
                                                                  
                                                                  successBlock(newApi);
                                                                  return;
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

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}


+ (RIApi *)parseApi:(NSDictionary*)api;
{
    RIApi* newApi = (RIApi*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIApi class])];
    
    if ([api objectForKey:@"action_name"]) {
        newApi.actionName = [api objectForKey:@"action_name"];
    }
    
    //VERSION STUFF IS MISSING FOR NOW
    
    NSArray* data = [api objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(data, NSArray)) {
        
        for (NSDictionary* sectionJSON in data) {
            
            if (VALID_NOTEMPTY(sectionJSON, NSDictionary)) {
                
                RISection* section = [RISection parseSection:sectionJSON];
                section.api = newApi;
                
                [newApi addSectionsObject:section];
            }
        }
    }
    
    return newApi;
}

+ (void)saveApi:(RIApi*)api
{
    for (RISection* section in api.sections) {
        [RISection saveSection:section];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:api];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)requestSectionContent:(RISection*)section
                 successBlock:(void (^)(void))successBlock
              andFailureBlock:(void (^)(NSArray* errorMessages))failureBlock
{
    if ([section.name isEqualToString:@"categories"])
    {
        [RICategory loadCategoriesIntoDatabaseWithSuccessBlock:^(id categories) {
            successBlock();
        } andFailureBlock:^(NSArray* errorMessages) {
            failureBlock(errorMessages);
        }];
    } else if ([section.name isEqualToString:@"forms"]) {
        [RIFormIndex loadFormIndexesIntoDatabaseWithSuccessBlock:^(id formIndexes) {
            successBlock();
        } andFailureBlock:^(NSArray *errorMessage) {
            failureBlock(errorMessage);
        }];
    }
    else if ([section.name isEqualToString:@"teasers"])
    {
        [RITeaserCategory loadTeaserCategoriesIntoDatabaseWithSuccessBlock:^(id teasers) {
            successBlock();
        } andFailureBlock:^(NSArray *errorMessage) {
            failureBlock(errorMessage);
        }];
    }
    else if ([section.name isEqualToString:@"imageresolutions"])
    {
        [RIImageResolution loadImageResolutionsIntoDatabaseWithSuccessBlock:^{
            
        } andFailureBlock:^(NSArray *errorMessage) {
            
        }];
    }
    else if ([section.name isEqualToString:@"countryconfs"])
    {
        [RICountry loadCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            
        } andFailureBlock:^(NSArray *errorMessages) {
            
        }];
    }
    else if ([section.name isEqualToString:@"static_blocks"])
    {
        [RIStaticBlockIndex loadStaticBlockIndexesIntoDatabaseWithSuccessBlock:^(id staticBlockIndexes) {
            
        } andFailureBlock:^(NSArray *errorMessage) {
            
        }];
    }
}

@end
