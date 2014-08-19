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

@dynamic countryUrl;
@dynamic actionName;
@dynamic curVersion;
@dynamic minVersion;
@dynamic sections;

+ (NSString *)startApiWithCountry:(RICountry *)country
                     successBlock:(void (^)(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory))successBlock
                  andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    NSString *url;
    
    if (ISEMPTY(country))
    {
        NSArray* apiArrayFromCoreData = [[RIDataBaseWrapper sharedInstance]allEntriesOfType:NSStringFromClass([RIApi class])];
        if(VALID_NOTEMPTY(apiArrayFromCoreData, NSArray))
        {
            RIApi* api = [apiArrayFromCoreData firstObject];
            url = api.countryUrl;
        }
    } else
    {
        [[RIDataBaseWrapper sharedInstance] resetApplicationModel];
        url = country.url;
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, RI_API_VERSION, RI_API_INFO]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSMutableDictionary* metadata = [[NSMutableDictionary alloc] initWithDictionary:[jsonObject objectForKey:@"metadata"]];
                                                              
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  
                                                                  // insert the country url
                                                                  [metadata addEntriesFromDictionary:@{ @"countryUrl" : url }];
                                                                  
                                                                  RIApi* newApi = [RIApi parseApi:metadata];
                                                                  
                                                                  BOOL hasUpdate = NO;
                                                                  BOOL isUpdateMandatory = NO;
                                                                  
                                                                  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                                  NSString *installedVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
                                                                  if(VALID_NOTEMPTY(installedVersion, NSString))
                                                                  {
                                                                      CGFloat installedVersionNumber = [installedVersion floatValue];
                                                                      if(installedVersionNumber < [newApi.minVersion floatValue])
                                                                      {
                                                                          hasUpdate = YES;
                                                                          isUpdateMandatory = YES;
                                                                      }
                                                                      else if(installedVersionNumber < [newApi.curVersion floatValue])
                                                                      {
                                                                          hasUpdate = YES;
                                                                      }
                                                                  }
                                                                  
                                                                  if(!isUpdateMandatory)
                                                                  {
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
                                                                              
                                                                              [RIApi requestSectionContent:newSection forCountry:url successBlock:^() {
                                                                                  
                                                                              } andFailureBlock:^(id error) {
                                                                                  
                                                                              }];
                                                                          }
                                                                      }
                                                                      
                                                                      //save new api in coredata
                                                                      [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIApi class])];
                                                                      [RIApi saveApi:newApi];
                                                                  }
                                                                  
                                                                  successBlock(newApi, hasUpdate, isUpdateMandatory);
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

#pragma mark - Verify if there is API stored

+ (BOOL)checkIfHaveCountrySelected
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Get country code

+ (NSString *)getCountryUrlInUse
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return @"";
    } else {
        RIApi *api = [apiArray firstObject];
        return api.countryUrl;
    }
}

#pragma mark - Parser

+ (RIApi *)parseApi:(NSDictionary*)api;
{
    RIApi* newApi = (RIApi*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIApi class])];
    
    if ([api objectForKey:@"action_name"]) {
        newApi.actionName = [api objectForKey:@"action_name"];
    }
    
    if ([api objectForKey:@"countryUrl"]) {
        newApi.countryUrl = [api objectForKey:@"countryUrl"];
    }
    
    NSDictionary *versionInfo = [api objectForKey:@"version"];
    if (VALID_NOTEMPTY(versionInfo, NSDictionary))
    {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSDictionary *bundleVersionInfo = [versionInfo objectForKey:bundleIdentifier];
        
        if(VALID_NOTEMPTY(bundleVersionInfo, NSDictionary))
        {
            newApi.curVersion = [bundleVersionInfo objectForKey:@"cur_version"];
            newApi.minVersion = [bundleVersionInfo objectForKey:@"min_version"];
        }
    }
    
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
                   forCountry:(NSString*)url
                 successBlock:(void (^)(void))successBlock
              andFailureBlock:(void (^)(NSArray* errorMessages))failureBlock
{
    if ([section.name isEqualToString:@"categories"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICategory loadCategoriesIntoDatabaseForCountry:url withSuccessBlock:^(id categories) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            successBlock();
        } andFailureBlock:^(NSArray* errorMessages) {
            failureBlock(errorMessages);
        }];
    } else if ([section.name isEqualToString:@"forms"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIFormIndex loadFormIndexesIntoDatabaseForCountry:url withSuccessBlock:^(id formIndexes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            successBlock();
        } andFailureBlock:^(NSArray *errorMessage) {
            failureBlock(errorMessage);
        }];
    }
    else if ([section.name isEqualToString:@"teasers"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RITeaserCategory loadTeaserCategoriesIntoDatabaseForCountry:url withSuccessBlock:^(id teasers) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            successBlock();
        } andFailureBlock:^(NSArray *errorMessage) {
            failureBlock(errorMessage);
        }];
    }
    else if ([section.name isEqualToString:@"imageresolutions"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIImageResolution loadImageResolutionsIntoDatabaseForCountry:url withSuccessBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(NSArray *errorMessage) {
            
        }];
    }
    else if ([section.name isEqualToString:@"countryconfs"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICountry loadCountryConfigurationForCountry:url withSuccessBlock:^(RICountryConfiguration *configuration) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(NSArray *errorMessages) {
            
        }];
    }
    else if ([section.name isEqualToString:@"static_blocks"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIStaticBlockIndex loadStaticBlockIndexesIntoDatabaseForCountry:url withSuccessBlock:^(id staticBlockIndexes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(NSArray *errorMessage) {
            
        }];
    }
}

@end
