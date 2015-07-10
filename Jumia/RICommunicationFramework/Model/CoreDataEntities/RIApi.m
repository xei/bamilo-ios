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
//#import "RITeaserCategory.h"
#import "RITeaserGrouping.h"
#import "RIImageResolution.h"
#import "RICountry.h"
#import "RICountryConfiguration.h"
#import "RIStaticBlockIndex.h"

@implementation RIApi

@dynamic countryUrl;
@dynamic actionName;
@dynamic countryIso;
@dynamic countryName;
@dynamic curVersion;
@dynamic minVersion;
@dynamic sections;

+ (NSString *)startApiWithCountry:(RICountry *)country
                        reloadAPI:(BOOL)reloadAPI
                     successBlock:(void (^)(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSString *url;
    NSString *countryIso;
    NSString *name;
    
    if (ISEMPTY(country))
    {
        NSArray* apiArrayFromCoreData = [[RIDataBaseWrapper sharedInstance]allEntriesOfType:NSStringFromClass([RIApi class])];
        if(VALID_NOTEMPTY(apiArrayFromCoreData, NSArray))
        {
            RIApi* api = [apiArrayFromCoreData firstObject];
            url = api.countryUrl;
            countryIso = api.countryIso;
            name = api.countryName;
        }
    }
    else
    {
        [[RIDataBaseWrapper sharedInstance] resetApplicationModel];
        url = country.url;
        countryIso = country.countryIso;
        name = country.name;
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
                                                                  
                                                                  RIApi* newApi = [RIApi parseApi:metadata
                                                                                       countryIso:countryIso
                                                                                      countryName:name];
                                                                  
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

                                                                          //$$$ FORCE UPDATE CAN REMOVE THIS
                                                                          BOOL hasDownloadedFacebookConfigs = NO;
                                                                          if(NO == ISEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsHasDownloadedFacebookConfigs]))
                                                                          {
                                                                              hasDownloadedFacebookConfigs = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsHasDownloadedFacebookConfigs];
                                                                          }
                                                                          
                                                                          if ([newSection.name isEqualToString:@"countryconfs"] && NO == hasDownloadedFacebookConfigs) {
                                                                              
                                                                              sectionNeedsDownload = YES;
                                                                          } else {
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
                                                                          }
                                                                          
                                                                          if (sectionNeedsDownload) {
                                                                              
                                                                              [RIApi requestSectionContent:newSection forCountry:url deleteOldContent:reloadAPI successBlock:^() {
                                                                                  
                                                                              } andFailureBlock:^(RIApiResponse apiResponse,  id error) {
                                                                                  
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

+ (NSString *)getCountryIsoInUse
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return @"";
    } else {
        RIApi *api = [apiArray firstObject];
        return api.countryIso;
    }
}

+ (NSString *)getCountryNameInUse;
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return @"";
    } else {
        RIApi *api = [apiArray firstObject];
        return api.countryName;
    }
}

+ (RIApi *)getApiInformation
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    RIApi *apiInformation = nil;
    if(VALID_NOTEMPTY(apiArray, NSArray))
    {
        apiInformation = [apiArray firstObject];
    }
    return apiInformation;
}

#pragma mark - Parser

+ (RIApi *)parseApi:(NSDictionary*)api
         countryIso:(NSString *)countryIso
        countryName:(NSString *)countryName
{
    RIApi* newApi = (RIApi*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIApi class])];
    
    if ([api objectForKey:@"action_name"])
    {
        newApi.actionName = [api objectForKey:@"action_name"];
    }
    
    if (VALID_NOTEMPTY(countryIso, NSString))
    {
        newApi.countryIso = countryIso;
    }
    
    if (VALID_NOTEMPTY(countryName, NSString))
    {
        newApi.countryName = countryName;
    }

    if ([api objectForKey:@"countryUrl"])
    {
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
    
    if (VALID_NOTEMPTY(data, NSArray))
    {
        for (NSDictionary* sectionJSON in data)
        {
            if (VALID_NOTEMPTY(sectionJSON, NSDictionary))
            {
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
             deleteOldContent:(BOOL)deleteOldContent
                 successBlock:(void (^)(void))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray* errorMessages))failureBlock
{
    if ([section.name isEqualToString:@"categories"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICategory loadCategoriesIntoDatabaseForCountry:url withSuccessBlock:^(id categories) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSideMenuShouldReload object:nil];
            successBlock();
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray* errorMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            failureBlock(apiResponse, errorMessages);
        }];
    } else if ([section.name isEqualToString:@"forms"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIFormIndex loadFormIndexesIntoDatabaseForCountry:url deleteOldIndexes:deleteOldContent withSuccessBlock:^(id formIndexes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            successBlock();
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            failureBlock(apiResponse, errorMessage);
        }];
    }
    else if ([section.name isEqualToString:@"home"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RITeaserGrouping loadTeasersIntoDatabaseForCountryUrl:url
                                              withSuccessBlock:^(NSArray *teaserGroupings) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kHomeShouldReload object:nil];
                                                  successBlock();
                                              } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
                                                  failureBlock(apiResponse, error);
                                              }];
    }
    else if ([section.name isEqualToString:@"imageresolutions"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIImageResolution loadImageResolutionsIntoDatabaseForCountry:url withSuccessBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
    else if ([section.name isEqualToString:@"countryconfs"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICountry loadCountryConfigurationForCountry:url withSuccessBlock:^(RICountryConfiguration *configuration) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
    else if ([section.name isEqualToString:@"static_blocks"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIStaticBlockIndex loadStaticBlockIndexesIntoDatabaseForCountry:url withSuccessBlock:^(id staticBlockIndexes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
}

@end
