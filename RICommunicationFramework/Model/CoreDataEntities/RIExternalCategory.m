//
//  RIExternalCategory.m
//  Jumia
//
//  Created by Jose Mota on 18/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "RIExternalCategory.h"
#import "RITarget.h"

@implementation RIExternalCategory

@dynamic label;
@dynamic position;
@dynamic targetString;
@dynamic imageUrl;
@dynamic level;
@dynamic urlKey;
@dynamic children;
@dynamic parent;

+ (void)getExternalCategoryWithSuccessBlock:(void (^)(RIExternalCategory *externalCategory))successBlock
                                            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
{
    NSArray* databaseParentCategories = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIExternalCategory class]) withPropertyName:@"parent" andPropertyValue:nil];
    if (databaseParentCategories.count > 0) {
        successBlock([databaseParentCategories firstObject]);
    }else{
        [self loadExternalCategoryIntoDatabaseForCountry:[RIApi getCountryUrlInUse]
                               countryUserAgentInjection:[RIApi getCountryUserAgentInjection]
                                        withSuccessBlock:successBlock andFailureBlock:failureBlock];
    }
}

+ (NSString *)loadExternalCategoryIntoDatabaseForCountry:(NSString *)countryUrl
                               countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                        withSuccessBlock:(void (^)(RIExternalCategory *externalCategory))successBlock
                                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIExternalCategory class])];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", countryUrl, RI_API_VERSION, RI_API_EXTERNAL_LINKS]]
                                                            parameters:nil httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:countryUserAgentInjection
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary *metadata = VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"metadata"], NSDictionary);
                                                              
                                                              successBlock([RIExternalCategory parseExternalCategory:metadata andPersist:YES]);
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
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

+ (RIExternalCategory *)parseExternalCategory:(NSDictionary *)externalCategoryJSON andPersist:(BOOL)persist
{
    RIExternalCategory* newExternalCategory = nil;
    if (persist) {
        newExternalCategory = (RIExternalCategory*)[[RIDataBaseWrapper sharedInstance] managedObjectOfType:NSStringFromClass([RIExternalCategory class])];
    }else{
        newExternalCategory = (RIExternalCategory*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIExternalCategory class])];
    }
    
    [newExternalCategory setLabel:VALID_NOTEMPTY_VALUE([externalCategoryJSON objectForKey:@"label"], NSString)];
    [newExternalCategory setPosition:VALID_NOTEMPTY_VALUE([externalCategoryJSON objectForKey:@"position"], NSNumber)];
    if (VALID_NOTEMPTY([externalCategoryJSON objectForKey:@"external_links"], NSArray))
    {
        [newExternalCategory setLevel:@0];
        for (NSDictionary *externalLinkJSON in [externalCategoryJSON objectForKey:@"external_links"]) {
            RIExternalCategory *child = [RIExternalCategory parseExternalCategory:externalLinkJSON andPersist:persist];
            [child setParent:newExternalCategory];
        }
    }else{
        [newExternalCategory setLevel:@1];
        NSString *targetString = VALID_NOTEMPTY_VALUE([externalCategoryJSON objectForKey:@"external_link_ios"], NSString);
        if (VALID_NOTEMPTY_VALUE(targetString, NSString)) {
            [newExternalCategory setTargetString:[RITarget getTargetString:EXTERNAL_LINK node:targetString]];
        }
        [newExternalCategory setImageUrl:VALID_NOTEMPTY_VALUE([externalCategoryJSON objectForKey:@"image"], NSString)];
    }
    
    return newExternalCategory;
}

@end
