//
//  RICategory.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICategory.h"

@implementation RICategory

@dynamic apiUrl;
@dynamic name;
@dynamic uid;
@dynamic urlKey;
@dynamic children;
@dynamic parent;

+ (NSString *)loadCategoriesIntoDatabaseWithSuccessBlock:(void (^)(id categories))successBlock andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_CATALOG_CATEGORIES]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  NSArray* data = [metadata objectForKey:@"data"];
                                                                  if (VALID_NOTEMPTY(data, NSArray))
                                                                  {
                                                                      successBlock([RICategory parseCategories:data persistData:YES]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
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

+ (void)getCategoriesWithSuccessBlock:(void (^)(id categores))successBlock andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    NSArray* databaseParentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"parent" andPropertyValue:nil];
    if(NOTEMPTY(databaseParentCategories))
    {
        if (VALID_NOTEMPTY(databaseParentCategories, NSArray)) {
            successBlock(databaseParentCategories);
        } else {
            failureBlock(nil);
        }
    } else {
        [RICategory loadCategoriesIntoDatabaseWithSuccessBlock:^(id categories) {
            
            NSArray* parentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"parent" andPropertyValue:nil];
            if (VALID_NOTEMPTY(parentCategories, NSArray)) {
                successBlock(parentCategories);
            } else {
                failureBlock(nil);
            }
        } andFailureBlock:failureBlock];
    }
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (NSArray*)parseCategories:(NSArray*)categories
                persistData:(BOOL)persistData;
{
    if (persistData) {
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICategory class])];
    }
    
    NSMutableArray* newCategories = [NSMutableArray new];
    
    //test if array as another array inside
    NSArray* insideArray = [categories firstObject];
    if (VALID(insideArray, NSArray)) {
        categories = insideArray;
    }
    
    for (NSDictionary* categoryJSON in categories) {
        
        if (VALID_NOTEMPTY(categoryJSON, NSDictionary)) {
            
            RICategory* category = [RICategory parseCategory:categoryJSON];
            if (persistData) {
                [RICategory saveCategory:category];
            }
            [newCategories addObject:category];
        }
    }
    
    return newCategories;
}


+ (RICategory *)parseCategory:(NSDictionary *)category
{
    RICategory* newCategory;
    
    newCategory = (RICategory*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICategory class])];
    
    
    if ([category objectForKey:@"id_catalog_category"]) {
        newCategory.uid = [category objectForKey:@"id_catalog_category"];
    }
    if ([category objectForKey:@"name"]) {
        newCategory.name = [category objectForKey:@"name"];
    }
    if ([category objectForKey:@"url_key"]) {
        newCategory.urlKey = [category objectForKey:@"url_key"];
    }
    if ([category objectForKey:@"url"]) {
        newCategory.apiUrl = [category objectForKey:@"url"];
    }
    if ([category objectForKey:@"api_url"]) {
        newCategory.apiUrl = [category objectForKey:@"api_url"];
    }
    
    NSArray* childrenArray = [category objectForKey:@"children"];
    
    if (childrenArray && [childrenArray isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary* childJSON in childrenArray) {
            
            if (VALID_NOTEMPTY(childJSON, NSDictionary)) {
                
                RICategory* child = [RICategory parseCategory:childJSON];
                child.parent = newCategory;
                [newCategory addChildrenObject:child];
            }
        }
    }
    
    return newCategory;
}

+ (void)saveCategory:(RICategory *)category
{
    for (RICategory* childCategory in category.children) {
        [RICategory saveCategory:childCategory];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:category];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}


@end
