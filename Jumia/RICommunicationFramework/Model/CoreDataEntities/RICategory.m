//
//  RICategory.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICategory.h"

@implementation RICategory

@dynamic label;
@dynamic vertical;
@dynamic urlKey;
@dynamic apiUrl;
@dynamic imageUrl;
@dynamic level;
@dynamic numberOfTimesSeen;
@dynamic children;
@dynamic parent;

+ (NSString *)loadCategoriesIntoDatabaseForCountry:(NSString *)country
                         countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                  withSuccessBlock:(void (^)(id categories))successBlock
                                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", country, RI_API_VERSION, RI_CATALOG_CATEGORIES]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:countryUserAgentInjection
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  NSArray* data = [metadata objectForKey:@"data"];
                                                                  if (VALID_NOTEMPTY(data, NSArray))
                                                                  {
                                                                      successBlock([RICategory parseCategories:data persistData:YES]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
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


+ (void)getCategoriesWithSuccessBlock:(void (^)(id categores))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSArray* databaseParentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"parent" andPropertyValue:nil];
    if(NOTEMPTY(databaseParentCategories))
    {
        if (VALID_NOTEMPTY(databaseParentCategories, NSArray)) {
            successBlock(databaseParentCategories);
        } else {
            failureBlock(RIApiResponseUnknownError, nil);
        }
    } else {
        [RICategory loadCategoriesIntoDatabaseForCountry:[RIApi getCountryUrlInUse] countryUserAgentInjection:[RIApi getCountryUserAgentInjection]withSuccessBlock:^(id categories) {
            
            NSArray* parentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"parent" andPropertyValue:nil];
            if (VALID_NOTEMPTY(parentCategories, NSArray)) {
                successBlock(parentCategories);
            } else {
                failureBlock(RIApiResponseUnknownError, nil);
            }
        } andFailureBlock:failureBlock];
    }
}

+ (void)getAllCategoriesWithSuccessBlock:(void (^)(id categores))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSArray* databaseCategories = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICategory class])];
    if(NOTEMPTY(databaseCategories))
    {
        if (VALID_NOTEMPTY(databaseCategories, NSArray)) {
            successBlock(databaseCategories);
        } else {
            failureBlock(RIApiResponseUnknownError, nil);
        }
    } else {
        [RICategory loadCategoriesIntoDatabaseForCountry:[RIApi getCountryUrlInUse] countryUserAgentInjection:[RIApi getCountryUserAgentInjection] withSuccessBlock:^(id categories) {
            
            NSArray* databaseCategories = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICategory class])];
            if (VALID_NOTEMPTY(databaseCategories, NSArray)) {
                successBlock(databaseCategories);
            } else {
                failureBlock(RIApiResponseUnknownError, nil);
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
                [RICategory saveCategory:category andContext:YES];
            }
            [newCategories addObject:category];
        }
    }
    
    return newCategories;
}

+ (NSString*)getTree:(NSString*)categoryId
{
//    NSString *categoryTree = @"";
//    if(VALID_NOTEMPTY(categoryId, NSString))
//    {
//        NSArray* savedCategoryArray = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"uid" andPropertyValue:categoryId];
//        
//        if(VALID_NOTEMPTY(savedCategoryArray, NSArray))
//        {
//            RICategory *savedCategory = [savedCategoryArray objectAtIndex:0];
//            categoryTree = savedCategory.label;
//            
//            RICategory *parentCategory = savedCategory.parent;
//            while (VALID_NOTEMPTY(parentCategory, RICategory))
//            {
//                categoryTree = [NSString stringWithFormat:@"%@,%@", parentCategory.label, categoryTree];
//                parentCategory = parentCategory.parent;
//            }
//        }
//    }
    return categoryId;
}

+ (NSString*)getCategoryName:(NSString*)categoryId
{
//    NSString *categoryName = categoryId;
//    if(VALID_NOTEMPTY(categoryId, NSString))
//    {
//        NSArray* savedCategoryArray = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"uid" andPropertyValue:categoryId];
//        
//        if(VALID_NOTEMPTY(savedCategoryArray, NSArray))
//        {
//            RICategory *savedCategory = [savedCategoryArray objectAtIndex:0];
//            categoryName = savedCategory.label;
//        }
//    }
    return categoryId;
}

+ (NSString*)getTopCategory:(RICategory*)seenCategory
{
    [RICategory seenCategory:seenCategory];
    
    RICategory *topCategory = nil;
    
    NSArray* databaseParentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICategory class]) withPropertyName:@"parent" andPropertyValue:nil];
    for(RICategory *category in databaseParentCategories)
    {
        if(ISEMPTY(topCategory))
        {
            topCategory = category;
        }
        else
        {
            if([topCategory.numberOfTimesSeen intValue] < [category.numberOfTimesSeen intValue])
            {
                topCategory = category;
            }
        }
    }
    
    return topCategory.label;
}

+ (void)seenCategory:(RICategory*)seenCategory
{
    if(VALID_NOTEMPTY(seenCategory, RICategory))
    {
        seenCategory.numberOfTimesSeen = [NSNumber numberWithInt:([seenCategory.numberOfTimesSeen intValue] + 1)];
    }
}

+ (RICategory *)parseCategory:(NSDictionary *)category
{
    return [RICategory parseCategory:category level:0];
}

+ (RICategory *)parseCategory:(NSDictionary *)category
                        level:(NSInteger)level
{
    RICategory* newCategory;
    
    newCategory = (RICategory*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICategory class])];
    
    newCategory.level = [NSNumber numberWithInteger:level];
    
    if ([category objectForKey:@"label"]) {
        newCategory.label = [category objectForKey:@"label"];
    }
    if ([category objectForKey:@"vertical"]) {
        newCategory.vertical = [category objectForKey:@"vertical"];
    }
    if ([category objectForKey:@"url_key"]) {
        newCategory.urlKey = [category objectForKey:@"url_key"];
    }
    if ([category objectForKey:@"api_url"]) {
        newCategory.apiUrl = [category objectForKey:@"api_url"];
    }
    if ([category objectForKey:@"image"]) {
        newCategory.imageUrl = [category objectForKey:@"image"];
    }
    
    newCategory.numberOfTimesSeen = [NSNumber numberWithInt:0];
    
    NSArray* childrenArray = [category objectForKey:@"children"];
    
    if (childrenArray && [childrenArray isKindOfClass:[NSArray class]]) {
        
        for (NSDictionary* childJSON in childrenArray) {
            
            if (VALID_NOTEMPTY(childJSON, NSDictionary)) {
                
                RICategory* child = [RICategory parseCategory:childJSON level:level+1];
                child.parent = newCategory;
                [newCategory addChildrenObject:child];
            }
        }
    }
    
    return newCategory;
}

+ (void)saveCategory:(RICategory *)category andContext:(BOOL)save
{
    for (RICategory* childCategory in category.children) {
        [RICategory saveCategory:childCategory andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:category];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}


@end
