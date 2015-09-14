//
//  RIFormIndex.m
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFormIndex.h"
#import "RIForm.h"


@implementation RIFormIndex

@dynamic uid;
@dynamic url;
@dynamic form;

+ (NSString*)loadFormIndexesIntoDatabaseForCountry:(NSString*)countryUrl
                         countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                  deleteOldIndexes:(BOOL)deleteOldIndexes
                                  withSuccessBlock:(void (^)(id formIndexes))successBlock
                                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_FORMS_INDEX]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:countryUserAgentInjection
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  if (deleteOldIndexes) {
                                                                      [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIFormIndex class])];
                                                                  }
                                                                  successBlock([RIFormIndex parseFormIndexes:metadata]);
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

+ (NSString*)getFormWithIndexId:(NSString*)formIndexID
                   successBlock:(void (^)(RIFormIndex *formIndex))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
{
    NSArray* formIndexes = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIFormIndex class]) withPropertyName:@"uid" andPropertyValue:formIndexID];
    if(VALID_NOTEMPTY(formIndexes, NSArray))
    {
        RIFormIndex* lastForm = [formIndexes lastObject];
        //delete all but last
        for (RIFormIndex* formIndex in formIndexes) {
            if (formIndex != lastForm) {
                [[RIDataBaseWrapper sharedInstance] deleteObject:formIndex];
            }
        }
        successBlock(lastForm);
        return nil;
    } else {
        return [RIFormIndex loadFormIndexesIntoDatabaseForCountry:[RIApi getCountryUrlInUse] countryUserAgentInjection:[RIApi getCountryUserAgentInjection] deleteOldIndexes:YES withSuccessBlock:^(id formIndexes) {
            formIndexes = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIFormIndex class]) withPropertyName:@"uid" andPropertyValue:formIndexID];
            if(VALID_NOTEMPTY(formIndexes, NSArray))
            {
                successBlock([formIndexes objectAtIndex:0]);
            } else
            {
                failureBlock(RIApiResponseUnknownError, nil);
            }
        } andFailureBlock:failureBlock];
    }
}

+ (NSArray*)parseFormIndexes:(NSDictionary*)formIndexesJSON;
{
    NSMutableArray* newFormIndexes = [NSMutableArray new];
    
    NSArray* data = [formIndexesJSON objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(data, NSArray)) {
        
        for (NSDictionary* formIndexJSON in data) {
            
            if (VALID_NOTEMPTY(formIndexJSON, NSDictionary)) {
                
                RIFormIndex* formIndex = [RIFormIndex parseFormIndex:formIndexJSON];
                [RIFormIndex saveFormIndex:formIndex andContext:YES];
                [newFormIndexes addObject:formIndex];
            }
        }
    }
    return newFormIndexes;
}

+ (RIFormIndex*)parseFormIndex:(NSDictionary*)formIndexJSON;
{
    RIFormIndex* newFormIndex = (RIFormIndex*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFormIndex class])];
    
    if ([formIndexJSON objectForKey:@"type"]) {
        newFormIndex.uid = [formIndexJSON objectForKey:@"type"];
    }
    if ([formIndexJSON objectForKey:@"url"]) {
        newFormIndex.url = [formIndexJSON objectForKey:@"url"];
    }
    
    return newFormIndex;
}

+ (void)saveFormIndex:(RIFormIndex*)formIndex andContext:(BOOL)save;
{
    if (VALID_NOTEMPTY(formIndex.form, RIForm)) {
        [RIForm saveForm:formIndex.form andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:formIndex];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

@end
