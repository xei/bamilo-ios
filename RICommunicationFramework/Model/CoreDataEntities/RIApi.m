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
#import "RIExternalCategory.h"
#import "RIFormIndex.h"
//#import "RITeaserCategory.h"
#import "RITeaserGrouping.h"
#import "RIImageResolution.h"
#import "RICountry.h"
#import "RICountryConfiguration.h"
#import "RIStaticBlockIndex.h"
#import "RICustomer.h"
#import "RILanguage.h"

@implementation RIApi

@dynamic countryUrl;
@dynamic countryIso;
@dynamic countryName;
@dynamic countryFlag;
@dynamic countryUserAgentInjection;
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
    NSString *flag;
    NSString *countryUserAgentInjection;
    
    if (ISEMPTY(country))
    {
        NSArray* apiArrayFromCoreData = [[RIDataBaseWrapper sharedInstance]allEntriesOfType:NSStringFromClass([RIApi class])];
        if(VALID_NOTEMPTY(apiArrayFromCoreData, NSArray))
        {
            RIApi* api = [apiArrayFromCoreData firstObject];
            url = api.countryUrl;
            countryIso = api.countryIso;
            name = api.countryName;
            flag = api.countryFlag;
            countryUserAgentInjection = api.countryUserAgentInjection;
        }
    }
    else
    {
        //save customer information so the app will remember him if he returns to the current
        //country
        [RICustomer getCustomerWithSuccessBlock:^(id customer){
        
            [[NSUserDefaults standardUserDefaults] setObject:[RICustomer toJSON:customer]
                                forKey:[NSString stringWithFormat:@"customer_%@",[RIApi getCountryIsoInUse]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages){
        }];
        
        [[RIDataBaseWrapper sharedInstance] resetApplicationModel];
        url = country.url;
        countryIso = country.countryIso;
        name = country.name;
        flag = country.flag;
        countryUserAgentInjection = country.userAgentInjection;
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, RI_API_VERSION, RI_API_INFO]]
                                                            parameters:nil httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:countryUserAgentInjection
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSMutableDictionary* metadata = [[NSMutableDictionary alloc] initWithDictionary:[jsonObject objectForKey:@"metadata"]];
                                                              
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  
                                                                  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                                  NSString *installedVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
//                                                                  NSString *installedBundleShortVersion = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
                                                                  NSString *lastAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
                                                                  if (!VALID(lastAppVersion, NSString) || ![installedVersion isEqualToString:lastAppVersion]) {
                                                                      [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIApi class])];
                                                                      [[NSUserDefaults standardUserDefaults] setObject:installedVersion forKey:@"appVersion"];
                                                                  }
                                                                  
                                                                  // insert the country url
                                                                  [metadata addEntriesFromDictionary:@{ @"countryUrl" : url }];
                                                                  
                                                                  RIApi* newApi = [RIApi parseApi:metadata
                                                                                       countryIso:countryIso
                                                                                      countryName:name
                                                                                      countryFlag:flag
                                                                        countryUserAgentInjection:countryUserAgentInjection];
                                                                  
                                                                  BOOL hasUpdate = NO;
                                                                  BOOL isUpdateMandatory = NO;
                                                                  
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
                                                                          
                                                                          if ([newSection.name isEqualToString:@"configurations"] && NO == hasDownloadedFacebookConfigs) {
                                                                              
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
                                                                              
                                                                              [RIApi requestSectionContent:newSection forCountry:url countryUserAgentInjection:countryUserAgentInjection deleteOldContent:reloadAPI successBlock:^() {
                                                                                  
                                                                              } andFailureBlock:^(RIApiResponse apiResponse,  id error) {
                                                                                  
                                                                              }];
                                                                          }
                                                                      }
                                                                      
                                                                      //save new api in coredata
                                                                      [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIApi class])];
                                                                      [RIApi saveApi:newApi andContext:YES];
                                                                      
                                                                      NSString* customer = [NSString stringWithFormat:@"customer_%@",newApi.countryIso];
                                                                      NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:customer];
                                                                      if (VALID_NOTEMPTY(dict,NSDictionary)) {
                                                                          [RICustomer parseCustomerWithJson:dict
                                                                                              plainPassword:[dict objectForKeyedSubscript:@"plain_password"]
                                                                                              loginMethod:[dict objectForKeyedSubscript:@"login_method"]];
                                                                      }
                                                                      
                                                                  }
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kCheckRedirectInfoNotification object:nil];
#warning Disabled app update for now
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

+ (NSString *)getCountryFlagInUse;
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return @"";
    } else {
        RIApi *api = [apiArray firstObject];
        return api.countryFlag;
    }
}

+ (NSString *)getCountryUserAgentInjection;
{
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    if (0 == apiArray.count) {
        return @"";
    } else {
        RIApi *api = [apiArray firstObject];
        return api.countryUserAgentInjection;
    }
}

+ (RIApi *)getApiInformation {
    NSArray *apiArray = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIApi class])];
    
    RIApi *apiInformation = nil;
    if(apiArray.count) {
        apiInformation = [apiArray firstObject];
    }
    return apiInformation;
}

#pragma mark - Parser

+ (RIApi *)parseApi:(NSDictionary*)api
        countryIso:(NSString *)countryIso
        countryName:(NSString *)countryName
        countryFlag:(NSString *)countryFlag
countryUserAgentInjection:(NSString*)countryUserAgentInjection {
    RIApi* newApi = (RIApi*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIApi class])];
    
    if (countryIso.length) {
        newApi.countryIso = countryIso;
    }
    
    if (countryName.length) {
        newApi.countryName = countryName;
    }
    
    if (countryFlag.length) {
        newApi.countryFlag = countryFlag;
    }

    if (countryUserAgentInjection.length) {
        newApi.countryUserAgentInjection = countryUserAgentInjection;
    }
    
    if ([api objectForKey:@"countryUrl"]) {
        newApi.countryUrl = [api objectForKey:@"countryUrl"];
    }
    
    NSDictionary *versionInfo = [api objectForKey:@"version"];
    if (versionInfo.count) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSDictionary *bundleVersionInfo = [versionInfo objectForKey:bundleIdentifier];
        
        if(bundleVersionInfo.count) {
            newApi.curVersion = [bundleVersionInfo objectForKey:@"cur_version"];
            newApi.minVersion = [bundleVersionInfo objectForKey:@"min_version"];
        }
    }
    
    NSArray* data = [api objectForKey:@"data"];
    
    if (data.count) {
        for (NSDictionary* sectionJSON in data) {
            if (sectionJSON.count) {
                RISection* section = [RISection parseSection:sectionJSON];
                section.api = newApi;
                [newApi addSectionsObject:section];
            }
        }
    }
    
    return newApi;
}

+ (void)saveApi:(RIApi*)api andContext:(BOOL)save {
    for (RISection* section in api.sections) {
        [RISection saveSection:section andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:api];
    
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
}

+ (void)requestSectionContent:(RISection*)section
                   forCountry:(NSString*)url
    countryUserAgentInjection:(NSString*)countryUserAgentInjection
             deleteOldContent:(BOOL)deleteOldContent
                 successBlock:(void (^)(void))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray* errorMessages))failureBlock
{
    if ([section.name isEqualToString:@"categories"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICategory loadCategoriesIntoDatabaseForCountry:url countryUserAgentInjection:countryUserAgentInjection withSuccessBlock:^(id categories) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSideMenuShouldReload object:nil];
            successBlock();
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray* errorMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            failureBlock(apiResponse, errorMessages);
        }];
    } else if ([section.name isEqualToString:@"forms"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIFormIndex loadFormIndexesIntoDatabaseForCountry:url countryUserAgentInjection:countryUserAgentInjection deleteOldIndexes:deleteOldContent withSuccessBlock:^(id formIndexes) {
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
                                     countryUserAgentInjection:countryUserAgentInjection
                                              withSuccessBlock:^(NSDictionary *teaserGroupings, BOOL richTeaserGrouping) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kHomeShouldReload object:nil];
                                                  
                                                  if ([teaserGroupings objectForKey:@"richTeaserGroupings"]) {
                                                      [RITeaserGrouping getTeaserRichRelevance:[teaserGroupings objectForKey:@"richTeaserGroupings"]
                                                                                  successBlock:^(RITeaserGrouping *richTeaserGrouping) {
                                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kHomeShouldReload object:nil];
                                                                                  }
                                                                               andFailureBlock:failureBlock];
                                                  }
                                                  successBlock();
                                              } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
                                                  failureBlock(apiResponse, error);
                                              }];
    }
    else if ([section.name isEqualToString:@"imageresolutions"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIImageResolution loadImageResolutionsIntoDatabaseForCountry:url countryUserAgentInjection:countryUserAgentInjection withSuccessBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
    else if ([section.name isEqualToString:@"configurations"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RICountry loadCountryConfigurationForCountry:url userAgentInjection:countryUserAgentInjection withSuccessBlock:^(RICountryConfiguration *configuration) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
    else if ([section.name isEqualToString:@"static_blocks"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIStaticBlockIndex loadStaticBlockIndexesIntoDatabaseForCountry:url countryUserAgentInjection:countryUserAgentInjection withSuccessBlock:^(id staticBlockIndexes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
        }];
    }
    else if ([section.name isEqualToString:@"externallinks"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestStartedNotificationName object:nil];
        [RIExternalCategory loadExternalCategoryIntoDatabaseForCountry:url countryUserAgentInjection:countryUserAgentInjection  withSuccessBlock:^(RIExternalCategory *externalCategory) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            successBlock();
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RISectionRequestEndedNotificationName object:nil];
            failureBlock(apiResponse, errorMessage);
        }];
    }
}

@end
