//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"
#import "RITarget.h"
#import "RIAlgolia.h"

@implementation RISearchType

@end

@implementation RISearchTypeProduct

@end

@implementation RIFeaturedBox

@end

@implementation RIBrand

@end

@implementation RIFeaturedBrandBox

@end

@implementation RIUndefinedSearchTerm

@end

@implementation RISearchSuggestion

@dynamic item;
@dynamic relevance;
@dynamic isRecentSearch;
@dynamic date;
@dynamic targetString;
@dynamic queryString;

+ (void)deleteSearchSuggestionByTargetString:(NSString *)targetString
{
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    
    for (RISearchSuggestion *tempSearch in searches) {
        if ([tempSearch.targetString isEqualToString:targetString]) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:tempSearch];
            [[RIDataBaseWrapper sharedInstance] saveContext];
            
            break;
        }
    }
}

+ (RISearchSuggestion *)getSearchSuggestionWithQuery:(NSString *)query isRecentSearch:(BOOL)isRecentSearch andContext:(BOOL)save
{
    RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
    newSearchSuggestion.item = query;
    newSearchSuggestion.relevance = @(0);
    newSearchSuggestion.isRecentSearch = isRecentSearch;
    newSearchSuggestion.date = [NSDate date];
    return newSearchSuggestion;
}

+ (void)saveSearchSuggestionOnDB:(RISearchSuggestion *)searchSuggestion
                  isRecentSearch:(BOOL)isRecentSearch andContext:(BOOL)save
{
    if(VALID_NOTEMPTY(searchSuggestion.item, NSString))
    {
        if ([RISearchSuggestion checkIfSuggestionsExistsOnDB:searchSuggestion.targetString])
        {
            [RISearchSuggestion deleteSearchSuggestionByTargetString:searchSuggestion.targetString];
        }
        
        [searchSuggestion setIsRecentSearch:isRecentSearch];
        [searchSuggestion setDate:[NSDate date]];
        
        // The limit for recent search is 5, if there is > 5 it's necessary to delete the old one
        if (isRecentSearch)
        {
            NSMutableArray *searches = [[[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])] mutableCopy];
            
            if (searches.count > 4)
            {
                [searches sortUsingComparator:^(RISearchSuggestion *obj1, RISearchSuggestion *obj2)
                 {
                     NSComparisonResult result = [obj1.date compare:obj2.date];
                     
                     switch (result)
                     {
                         case NSOrderedAscending: return (NSComparisonResult)NSOrderedDescending; break;
                         case NSOrderedDescending: return (NSComparisonResult)NSOrderedAscending; break;
                         case NSOrderedSame: return (NSComparisonResult)NSOrderedSame; break;
                             
                         default: return (NSComparisonResult)NSOrderedSame; break;
                     }
                 }];
                
                [[RIDataBaseWrapper sharedInstance] deleteObject:[searches lastObject]];
                if (save) {
                    [[RIDataBaseWrapper sharedInstance] saveContext];
                }
                
            }

            [[RIDataBaseWrapper sharedInstance] insertManagedObject:searchSuggestion];
            if (save) {
                [[RIDataBaseWrapper sharedInstance] saveContext];
            }
        }
    }
}

+ (NSString *)getSuggestionsForQuery:(NSString *)query
                       successBlock:(void (^)(NSArray *suggestions))successBlock
                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
       if([RICountryConfiguration getCurrentConfiguration].suggesterProviderEnum == ALGOLIA &&
           VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].algoliaAppId, NSString) &&
           VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].algoliaApiKey, NSString))
    {
        __block NSLock *searchLock = [NSLock new];
        __block NSArray *outsideBlockProductsResultsArray;
        __block NSArray *outsideBlockShopInShopResultsArray;
        [[RIAlgolia sharedInstance] getSearchResultsForQuery:[query stringByReplacingOccurrencesOfString:@" " withString:@"+"] onFirstStepSuccess:^(NSArray *productsResults, NSArray *shopInShopResults) {
            
            [searchLock lock];
            NSMutableArray *productsSuggestionArray = [NSMutableArray new];
            for (NSDictionary *item in productsResults) {
                RISearchSuggestion *suggestion = [RISearchSuggestion parseSearchSuggestion:item forTextQuery:query];
                suggestion.targetString = [RITarget getTargetString:PRODUCT_DETAIL node:[item objectForKey:@"value"]];
                [productsSuggestionArray addObject:suggestion];
            }
            NSMutableArray *shopInShopSuggestionArray = [NSMutableArray new];
            for (NSDictionary *item in shopInShopResults) {
                RISearchSuggestion *suggestion = [RISearchSuggestion parseSearchSuggestion:item forTextQuery:query];
                suggestion.targetString = [RITarget getTargetString:SHOP_IN_SHOP node:[item objectForKey:@"value"]];
                [shopInShopSuggestionArray addObject:suggestion];
            }
            outsideBlockProductsResultsArray = [productsSuggestionArray copy];
            outsideBlockShopInShopResultsArray = [shopInShopSuggestionArray copy];
            if (VALID_NOTEMPTY(productsSuggestionArray, NSMutableArray) || VALID_NOTEMPTY(shopInShopSuggestionArray, NSMutableArray)) {
                successBlock([[productsSuggestionArray arrayByAddingObjectsFromArray:[shopInShopSuggestionArray copy]] copy]);
            }else{
                failureBlock(RIApiResponseAPIError, nil);
            }
            [searchLock unlock];
            
        } onSecondStepSuccess:^(NSArray *categoryResults) {
            
            [searchLock lock];
            NSMutableArray *categoryArray = [NSMutableArray new];
            for (NSDictionary *item in categoryResults) {
                RISearchSuggestion *suggestion = [RISearchSuggestion parseSearchSuggestion:item forTextQuery:query];
                suggestion.targetString = [RITarget getTargetString:CATALOG_CATEGORY node:[item objectForKey:@"value"]];
                [categoryArray addObject:suggestion];
            }
            successBlock([[outsideBlockShopInShopResultsArray arrayByAddingObjectsFromArray:[categoryArray copy] ] arrayByAddingObjectsFromArray:[outsideBlockProductsResultsArray copy]]);
            [searchLock unlock];
        } onError:^(NSString *error) {
            failureBlock(RIApiResponseAPIError, @[error]);
        }];
        return nil;
    }else{
        
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_SEARCH_SUGGESTIONS,[query stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
        return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                                parameters:nil
                                                                httpMethod:HttpVerbGET
                                                                 cacheType:RIURLCacheNoCache
                                                                 cacheTime:RIURLCacheNoTime
                                                        userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                              successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                                  
                                                                  // Add request search suggestions
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      NSArray *shopInShopSuggestions = VALID_VALUE([RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"shops"] forTextQuery:query], NSArray);
                                                                      NSArray *categoriesSuggestions = VALID_VALUE([RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"categories"] forTextQuery:query], NSArray);
                                                                      NSArray *productsSuggestions = VALID_VALUE([RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"products"] forTextQuery:query], NSArray);
                                                                      NSArray *queriesSuggestions = VALID_VALUE([RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"queries"] forTextQuery:query], NSArray);
                                                                      if (VALID_NOTEMPTY(shopInShopSuggestions, NSArray) || VALID_NOTEMPTY(categoriesSuggestions, NSArray) || VALID_NOTEMPTY(productsSuggestions, NSArray) || VALID_NOTEMPTY(queriesSuggestions, NSArray)) {
                                                                          successBlock([[[shopInShopSuggestions?:[NSArray new] arrayByAddingObjectsFromArray:[categoriesSuggestions copy]] arrayByAddingObjectsFromArray:[productsSuggestions copy]] arrayByAddingObjectsFromArray:[queriesSuggestions copy]]);
                                                                      }else{
                                                                          failureBlock(RIApiResponseAPIError, nil);
                                                                      }
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
}

+ (NSString *)getResultsForSearch:(NSString *)query
                             page:(NSString *)page
                         maxItems:(NSString *)maxItems
                    sortingMethod:(RICatalogSortingEnum)sortingMethod
                          filters:(NSArray*)filters
                     successBlock:(void (^)(RICatalog *catalog))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm))failureBlock {
    

    NSString *tempUrl = [NSString stringWithFormat:@"%@%@search/find/", [RIApi getCountryUrlInUse], RI_API_VERSION];
    NSString *sortingString = [RICatalogSorting urlComponentForSortingMethod:sortingMethod];

    
    if (sortingString.length) {
        sortingString = [NSString stringWithFormat:@"/%@", sortingString];
    }
    
    NSString *filtersString = [BaseSearchFilterItem urlWithFiltersArray:filters];
    if(filtersString.length) {
        if(NSNotFound == [@"q" rangeOfString:filtersString].location) {
            tempUrl = [NSString stringWithFormat:@"%@q/%@/page/%@/maxitems/%@%@/%@/", tempUrl, query, page, maxItems,
                       sortingString, filtersString];
        } else {
            tempUrl = [NSString stringWithFormat:@"%@/page/%@/maxitems/%@%@/%@/", tempUrl, page, maxItems,
                          sortingString, filtersString];
        }
    } else {
        tempUrl = [NSString stringWithFormat:@"%@q/%@/page/%@/maxitems/%@%@/", tempUrl, query, page, maxItems,
                   sortingString];
    }
    

    tempUrl = [tempUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:tempUrl];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  RICatalog *catalog = [RICatalog parseCatalog:metadata forCountryConfiguration:configuration];
                                                                  if (catalog && catalog.products.count != 0) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(catalog);
                                                                      });
                                                                  } else {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          failureBlock(apiResponse, nil, nil);
                                                                      });
                                                                  }
                                                                  
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      failureBlock(apiResponse, nil, nil);
                                                                  });
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  if ([errorJsonObject objectForKey:@"metadata"]) {
                                                                      failureBlock(apiResponse, nil, [RISearchSuggestion parseUndefinedSearchTerm:[errorJsonObject objectForKey:@"metadata"]]);
                                                                  } else {
                                                                      if(errorJsonObject) {
                                                                          failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject], nil);
                                                                      } else if(errorObject) {
                                                                          NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                          failureBlock(apiResponse, errorArray, nil);
                                                                      } else {
                                                                          failureBlock(apiResponse, nil, nil);
                                                                      }
                                                                  }
                                                              });
                                                          }];
    
}

#pragma mark - Get Recent searches

+ (NSArray *)getRecentSearches
{
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    
    if (0 == searches.count)
    {
        return nil;
    }
    else
    {
        NSMutableArray *array = [NSMutableArray new];
        
        for (RISearchSuggestion *suggestion in searches)
        {
            if (suggestion.isRecentSearch)
            {
                [array addObject:suggestion];
            }
        }
        
        if (array.count > 1)
        {
            [array sortUsingComparator:^(RISearchSuggestion *obj1, RISearchSuggestion *obj2)
             {
                 NSComparisonResult result = [obj1.date compare:obj2.date];
                 
                 switch (result)
                 {
                     case NSOrderedAscending: return (NSComparisonResult)NSOrderedDescending; break;
                     case NSOrderedDescending: return (NSComparisonResult)NSOrderedAscending; break;
                     case NSOrderedSame: return (NSComparisonResult)NSOrderedSame; break;
                         
                     default: return (NSComparisonResult)NSOrderedSame; break;
                 }
             }];
        }
        
        return [array copy];
    }
}

+ (void)deleteAllSearches
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)putRecentSearchInTop:(RISearchSuggestion *)search
{
    search.date = [NSDate date];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Private methods

+ (BOOL)checkIfSuggestionsExistsOnDB:(NSString *)targetString
{
    BOOL suggestionExists = false;
    NSArray* searchSuggestions = [RISearchSuggestion getSearchSuggestionsOnDBForTargetString:targetString];
    if(VALID_NOTEMPTY(searchSuggestions, NSArray))
    {
        suggestionExists = true;
    }
    return suggestionExists;
}

+ (NSArray *)getSearchSuggestionsOnDBForTargetString:(NSString*)targetString
{
    return [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RISearchSuggestion class]) withPropertyName:@"targetString" andPropertyValue:targetString];
}

+ (NSArray*) parseSearchSuggestions:(NSArray*)jsonObject forTextQuery:(NSString *)textQuery
{
    NSMutableArray *suggestions = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(jsonObject, NSArray))
    {
        for(NSDictionary *suggestionObject in jsonObject)
        {
            if(VALID_NOTEMPTY(suggestionObject, NSDictionary))
            {
                [suggestions addObject:[RISearchSuggestion parseSearchSuggestion:suggestionObject forTextQuery:textQuery]];
            }
        }
    }
    return [suggestions copy];
}

+ (RISearchSuggestion *)parseSearchSuggestion:(NSDictionary*)jsonObject forTextQuery:(NSString *)textQuery
{
    RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
    
    [newSearchSuggestion setItem:VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"sub_string"], NSString)];
    if (!newSearchSuggestion.item && VALID_NOTEMPTY([jsonObject objectForKey:@"name"], NSString)) {
        newSearchSuggestion.item = [jsonObject objectForKey:@"name"];
    } else if (VALID_NOTEMPTY([jsonObject objectForKey:@"item"], NSString)) {
        newSearchSuggestion.item = [jsonObject objectForKey:@"item"];
    }
    
    [newSearchSuggestion setTargetString:VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"target"], NSString)];
    [newSearchSuggestion setRelevance:VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"relevance"], NSNumber)];
    [newSearchSuggestion setQueryString:textQuery];
    
    return newSearchSuggestion;
}

#pragma mark - Parse undefined term

+ (RIUndefinedSearchTerm *)parseUndefinedSearchTerm:(NSDictionary *)json
{
    if (NOTEMPTY(json))
    {
        RIUndefinedSearchTerm *undefinedSearchTerm = [[RIUndefinedSearchTerm alloc] init];
        
        if ([json objectForKey:@"error_message"]) {
            undefinedSearchTerm.errorMessage = [json objectForKey:@"error_message"];
        }
        
        if ([json objectForKey:@"notice_message"]) {
            undefinedSearchTerm.noticeMessage = [json objectForKey:@"notice_message"];
        }
        
//        if ([json objectForKey:@"search_tips"]) {
//            NSDictionary *searchTipsDic = [json objectForKey:@"search_tips"];
//            
//            RISearchType *searchType = [[RISearchType alloc] init];
//            
//            if ([searchTipsDic objectForKey:@"text"]) {
//                searchType.text = [searchTipsDic objectForKey:@"text"];
//            }
//            
//            if ([searchTipsDic objectForKey:@"title"]) {
//                searchType.title = [searchTipsDic objectForKey:@"title"];
//            }
//            
//            undefinedSearchTerm.searchType = searchType;
//        }
        
        if ([json objectForKey:@"featured_box"]) {
            if ([[json objectForKey:@"featured_box"] isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = [json objectForKey:@"featured_box"];
                NSDictionary *featuredBoxDic = [tempArray firstObject];
                
                RIFeaturedBox *featuredBox = [[RIFeaturedBox alloc] init];
                
                if ([featuredBoxDic objectForKey:@"title"]) {
                    featuredBox.title = [featuredBoxDic objectForKey:@"title"];
                }
                
                if ([featuredBoxDic objectForKey:@"label"]) {
                    featuredBox.label = [featuredBoxDic objectForKey:@"label"];
                }
                
                if ([featuredBoxDic objectForKey:@"url"]) {
                    featuredBox.url = [featuredBoxDic objectForKey:@"url"];
                }
                
                if ([featuredBoxDic objectForKey:@"products"]) {
                    NSArray *productsArray = [featuredBoxDic objectForKey:@"products"];
                    NSMutableArray *tempArray = [NSMutableArray new];
                    
                    for (NSDictionary *productDic in productsArray) {
                        RISearchTypeProduct *product = [[RISearchTypeProduct alloc] init];
                        
                        if ([productDic objectForKey:@"sku"]) {
                            product.sku = [productDic objectForKey:@"sku"];
                        }
                        
                        if ([productDic objectForKey:@"name"]) {
                            product.name = [productDic objectForKey:@"name"];
                        }
                        
                        if ([productDic objectForKey:@"max_price"]) {
                            product.maxPrice = [productDic objectForKey:@"max_price"];
                        }
                        
                        if ([productDic objectForKey:@"max_price_converted"]) {
                            product.maxPriceEuroConverted = [productDic objectForKey:@"max_price_converted"];
                        }
                        
                        if ([productDic objectForKey:@"max_savings_percentage"]) {
                            product.maxPercentageSaving = [productDic objectForKey:@"max_savings_percentage"];
                        }
                        
                        if ([productDic objectForKey:@"special_price"]) {
                            product.price = [productDic objectForKey:@"special_price"];
                            product.priceFormatted = [RICountryConfiguration formatPrice:[NSNumber  numberWithLong:[product.price longLongValue]]
                                                                                 country:[RICountryConfiguration getCurrentConfiguration]];
                        } else if ([productDic objectForKey:@"price"]) {
                            product.price = [productDic objectForKey:@"price"];
                            product.priceFormatted = [RICountryConfiguration formatPrice:[NSNumber numberWithLong:[product.price longLongValue]]
                                                                                 country:[RICountryConfiguration getCurrentConfiguration]];
                        }
                                                
                        if ([productDic objectForKey:@"price_converted"]) {
                            product.priceEuroConverted = [productDic objectForKey:@"price_converted"];
                        }
                        
                        if ([productDic objectForKey:@"brand"]) {
                            product.brand = [productDic objectForKey:@"brand"];
                        }
                        
                        if ([productDic objectForKey:@"target"]) {
                            product.targetString = [productDic objectForKey:@"target"];
                        }
                        
                        if ([productDic objectForKey:@"image"]) {
                            product.image = [productDic objectForKey:@"image"];
                        }
                        
                        [tempArray addObject:product];
                    }
                    
                    featuredBox.products = [tempArray copy];
                }
                
                undefinedSearchTerm.featuredBox = featuredBox;
            }
        }
        
        if ([json objectForKey:@"featured_brandbox"]) {
            if ([[json objectForKey:@"featured_brandbox"] isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = [json objectForKey:@"featured_brandbox"];
                NSDictionary *featuredBrandBoxDic = [tempArray firstObject];
                
                RIFeaturedBrandBox *featuredBrandBox = [[RIFeaturedBrandBox alloc] init];
                
                if ([featuredBrandBoxDic objectForKey:@"title"]) {
                    featuredBrandBox.title = [featuredBrandBoxDic objectForKey:@"title"];
                }
                
                if ([featuredBrandBoxDic objectForKey:@"brands"]) {
                    NSArray *brandsArray = [featuredBrandBoxDic objectForKey:@"brands"];
                    NSMutableArray *tempBrandsArray = [NSMutableArray new];
                    
                    for (NSDictionary *dic in brandsArray) {
                        RIBrand *brand = [[RIBrand alloc] init];
                        
                        if ([dic objectForKey:@"name"]) {
                            brand.name = [dic objectForKey:@"name"];
                        }
                        
                        if ([dic objectForKey:@"image"]) {
                            if (![[dic objectForKey:@"image"] isKindOfClass:[NSNull class]]) {
                                brand.image = [dic objectForKey:@"image"];
                            }
                        } else {
                            brand.image = @"";
                        }
                        
                        if ([dic objectForKey:@"target"]) {
                            brand.targetString = [dic objectForKey:@"target"];
                        }
                        
                        [tempBrandsArray addObject:brand];
                    }
                    
                    featuredBrandBox.brands = [tempBrandsArray copy];
                }
                
                undefinedSearchTerm.featuredBrandBox = featuredBrandBox;
            }
        }
        
        return undefinedSearchTerm;
    }
    else
    {
        return nil;
    }
}

@end
