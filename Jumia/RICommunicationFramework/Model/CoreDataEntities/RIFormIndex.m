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
@dynamic md5;
@dynamic url;
@dynamic form;

+ (NSString*)loadFormIndexesIntoDatabaseWithSuccessBlock:(void (^)(id formIndexes))successBlock
                                         andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_FORMS_INDEX]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  successBlock([RIFormIndex parseFormIndexes:metadata]);
                                                              } else {
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

+ (NSString*)getFormIndexesWithWithSuccessBlock:(void (^)(id formIndexes))successBlock
                                andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;
{
    NSArray* allFormIndexes = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIFormIndex class])];
    if(VALID_NOTEMPTY(allFormIndexes, NSArray))
    {
        successBlock(allFormIndexes);
        return nil;
    } else {
        return [RIFormIndex loadFormIndexesIntoDatabaseWithSuccessBlock:^(id formIndexes) {
            successBlock(formIndexes);
        } andFailureBlock:failureBlock];
    }
}

+ (NSArray*)parseFormIndexes:(NSDictionary*)formIndexesJSON;
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIFormIndex class])];
    
    NSMutableArray* newFormIndexes = [NSMutableArray new];
    
    NSArray* data = [formIndexesJSON objectForKey:@"data"];

    if (VALID_NOTEMPTY(data, NSArray)) {
        
        for (NSDictionary* formIndexJSON in data) {
            
            if (VALID_NOTEMPTY(formIndexJSON, NSDictionary)) {
                
                RIFormIndex* formIndex = [RIFormIndex parseFormIndex:formIndexJSON];
                [RIFormIndex saveFormIndex:formIndex];
                [newFormIndexes addObject:formIndex];
            }
        }
    }
    return newFormIndexes;
}

+ (RIFormIndex*)parseFormIndex:(NSDictionary*)formIndexJSON;
{
    RIFormIndex* newFormIndex = (RIFormIndex*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFormIndex class])];
    
    if ([formIndexJSON objectForKey:@"id"]) {
        newFormIndex.uid = [formIndexJSON objectForKey:@"id"];
    }
    if ([formIndexJSON objectForKey:@"md5"]) {
        newFormIndex.md5 = [formIndexJSON objectForKey:@"md5"];
    }
    if ([formIndexJSON objectForKey:@"url"]) {
        newFormIndex.url = [formIndexJSON objectForKey:@"url"];
    }
    
    return newFormIndex;
}

+ (void)saveFormIndex:(RIFormIndex*)formIndex;
{
    if (VALID_NOTEMPTY(formIndex.form, RIForm)) {
        [RIForm saveForm:formIndex.form];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:formIndex];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

@end
