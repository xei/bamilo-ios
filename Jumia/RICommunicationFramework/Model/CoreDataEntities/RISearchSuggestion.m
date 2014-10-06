//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"
#import "RIFilter.h"

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

+ (void)deleteSearchSuggestionByQuery:(NSString *)query
{
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    
    for (RISearchSuggestion *tempSearch in searches) {
        if ([tempSearch.item isEqualToString:query]) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:tempSearch];
            [[RIDataBaseWrapper sharedInstance] saveContext];
            
            break;
        }
    }
}

+ (void)saveSearchSuggestionOnDB:(NSString *)query
                  isRecentSearch:(BOOL)isRecentSearch
{
    if(VALID_NOTEMPTY(query, NSString))
    {
        if ([RISearchSuggestion checkIfSuggestionsExistsOnDB:query])
        {
            [RISearchSuggestion deleteSearchSuggestionByQuery:query];
        }
        
        RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
        
        newSearchSuggestion.item = query;
        newSearchSuggestion.relevance = @(0);
        newSearchSuggestion.isRecentSearch = isRecentSearch;
        newSearchSuggestion.date = [NSDate date];
        
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
                [[RIDataBaseWrapper sharedInstance] saveContext];
            }

            [[RIDataBaseWrapper sharedInstance] insertManagedObject:newSearchSuggestion];
            [[RIDataBaseWrapper sharedInstance] saveContext];
        }
    }
}

+ (NSString*)getSuggestionsForQuery:(NSString *)query
                       successBlock:(void (^)(NSArray *suggestions))successBlock
                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_SEARCH_SUGGESTIONS]]
                                                            parameters:[NSDictionary dictionaryWithObject:query forKey:@"q"]
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSMutableArray *suggestions = [[NSMutableArray alloc] init];
                                                              
                                                              // Add recent search suggestions
                                                              NSMutableArray *databaseSuggesions = [NSMutableArray new];
                                                              
                                                              NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
                                                              
                                                              for (RISearchSuggestion *tempSearch in searches)
                                                              {
                                                                  if ([[tempSearch.item lowercaseString] rangeOfString:[query lowercaseString]].location != NSNotFound)
                                                                  {
                                                                      [databaseSuggesions addObject:tempSearch];
                                                                  }
                                                              }
                                                              
                                                              if(VALID_NOTEMPTY(databaseSuggesions, NSMutableArray))
                                                              {
                                                                  [suggestions addObjectsFromArray:[databaseSuggesions copy]];
                                                              }
                                                              
                                                              // Add request search suggestions
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSArray *requestSuggestions = [RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"suggestions"]];
                                                                  if(VALID_NOTEMPTY(requestSuggestions, NSArray))
                                                                  {
                                                                      if (!VALID_NOTEMPTY(databaseSuggesions, NSMutableArray))
                                                                      {
                                                                          [suggestions addObjectsFromArray:requestSuggestions];
                                                                      }
                                                                      else
                                                                      {
                                                                          for (RISearchSuggestion *requestSuggestion in requestSuggestions)
                                                                          {
                                                                              for (RISearchSuggestion *databaseSuggesion in databaseSuggesions)
                                                                              {
                                                                                  if (![databaseSuggesion.item isEqualToString:requestSuggestion.item])
                                                                                  {
                                                                                      [suggestions addObject:requestSuggestion];
                                                                                  }
                                                                              }
                                                                          }
                                                                      }
                                                                  }
                                                              }
                                                              
                                                              successBlock([suggestions copy]);
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

+ (NSString *)getResultsForSearch:(NSString *)query
                             page:(NSString *)page
                         maxItems:(NSString *)maxItems
                    sortingMethod:(RICatalogSorting)sortingMethod
                          filters:(NSArray*)filters
                     successBlock:(void (^)(NSArray *results, NSArray *filters, NSNumber *productCount))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm))failureBlock
{
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    BOOL discountMode = NO;
    for (RIFilter* filter in filters)
    {
        for (RIFilterOption* filterOption in filter.options)
        {
            if (filterOption.discountOnly)
            {
                discountMode = YES;
                break;
            }
        }
    }
    
    NSString *tempUrl = [NSString stringWithFormat:@"%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION];
    if (discountMode)
    {
        tempUrl = [NSString stringWithFormat:@"%@search/special-price/", tempUrl];
    }
    else
    {
        tempUrl = [NSString stringWithFormat:@"%@search/", tempUrl];
    }
    
    NSString *filtersString = [RIFilter urlWithFiltersArray:filters];
    if(VALID_NOTEMPTY(filtersString, NSString))
    {
        if(NSNotFound == [@"q" rangeOfString:filtersString].location)
        {
            tempUrl = [NSString stringWithFormat:@"%@?setDevice=mobileApi&q=%@&page=%@&maxitems=%@&%@&%@", tempUrl, query, page, maxItems,
                       [RIProduct urlComponentForSortingMethod:sortingMethod], filtersString];
        }
        else
        {
            tempUrl = [NSString stringWithFormat:@"%@?setDevice=mobileApi&page=%@&maxitems=%@&%@&%@", tempUrl, page, maxItems,
                          [RIProduct urlComponentForSortingMethod:sortingMethod], filtersString];
        }
    }
    else
    {
        tempUrl = [NSString stringWithFormat:@"%@?setDevice=mobileApi&q=%@&page=%@&maxitems=%@&%@", tempUrl, query, page, maxItems,
                   [RIProduct urlComponentForSortingMethod:sortingMethod]];
    }

    NSURL *url = [NSURL URLWithString:tempUrl];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                  NSDictionary *results = [metadata objectForKey:@"results"];
                                                                  
                                                                  NSNumber *productCountValue = [NSNumber numberWithInt:0];
                                                                  id productCount = [metadata objectForKey:@"product_count"];
                                                                  if(VALID_NOTEMPTY(productCount, NSNumber))
                                                                  {
                                                                      productCountValue = productCount;
                                                                  }
                                                                  else if(VALID_NOTEMPTY(productCount, NSString))
                                                                  {
                                                                      NSString *productCountStirng = productCount;
                                                                      productCountValue = [NSNumber numberWithInt:[productCountStirng intValue]];
                                                                  }
                                                                  
                                                                  NSArray* filtersJSON = [metadata objectForKey:@"filters"];
                                                                  
                                                                  NSArray* filtersArray;
                                                                  
                                                                  if (VALID_NOTEMPTY(filtersJSON, NSArray)) {
                                                                      
                                                                      filtersArray = [RIFilter parseFilters:filtersJSON];
                                                                      
                                                                  }

                                                                  NSMutableArray *temp = [NSMutableArray new];
                                                                  
                                                                  for (NSDictionary *dic in results) {
                                                                      [temp addObject:[RIProduct parseProduct:dic country:configuration]];
                                                                  }
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      successBlock([temp copy], filtersArray, productCountValue);
                                                                  });
                                                                  
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      failureBlock(apiResponse, nil, nil);
                                                                  });
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  if ([errorJsonObject objectForKey:@"metadata"])
                                                                  {
                                                                      failureBlock(apiResponse, nil, [RISearchSuggestion parseUndefinedSearchTerm:[errorJsonObject objectForKey:@"metadata"]]);
                                                                  }
                                                                  else
                                                                  {
                                                                      if(NOTEMPTY(errorJsonObject))
                                                                      {
                                                                          failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject], nil);
                                                                      }
                                                                      else if(NOTEMPTY(errorObject))
                                                                      {
                                                                          NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                          failureBlock(apiResponse, errorArray, nil);
                                                                      }
                                                                      else
                                                                      {
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

+ (BOOL)checkIfSuggestionsExistsOnDB:(NSString *)query
{
    BOOL suggestionExists = false;
    NSArray* searchSuggestions = [RISearchSuggestion getSearchSuggestionsOnDBForQuery:query];
    if(VALID_NOTEMPTY(searchSuggestions, NSArray))
    {
        suggestionExists = true;
    }
    return suggestionExists;
}


+ (NSArray *)getSearchSuggestionsOnDBForQuery:(NSString*)query
{
    return [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RISearchSuggestion class]) withPropertyName:@"item" andPropertyValue:query];
}

+ (NSArray*) parseSearchSuggestions:(NSArray*)jsonObject
{
    NSMutableArray *suggestions = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(jsonObject, NSArray))
    {
        for(NSDictionary *suggestionObject in jsonObject)
        {
            if(VALID_NOTEMPTY(suggestionObject, NSDictionary))
            {
                [suggestions addObject:[RISearchSuggestion parseSearchSuggestion:suggestionObject]];
            }
        }
    }
    return [suggestions copy];
}

+ (RISearchSuggestion *)parseSearchSuggestion:(NSDictionary*)jsonObject
{
    RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
    
    if ([jsonObject objectForKey:@"item"]) {
        newSearchSuggestion.item = [jsonObject objectForKey:@"item"];
    }
    
    if ([jsonObject objectForKey:@"relevance"]) {
        newSearchSuggestion.relevance = [jsonObject objectForKey:@"relevance"];
    }
    
    return newSearchSuggestion;
}

#pragma mark - Parse undefined term

+ (RIUndefinedSearchTerm *)parseUndefinedSearchTerm:(NSDictionary *)json
{
    NSDictionary *data = [json objectForKey:@"data"];
    
    if (NOTEMPTY(data))
    {
        RIUndefinedSearchTerm *undefinedSearchTerm = [[RIUndefinedSearchTerm alloc] init];
        
        if ([data objectForKey:@"error_message"]) {
            undefinedSearchTerm.errorMessage = [data objectForKey:@"error_message"];
        }
        
        if ([data objectForKey:@"notice_message"]) {
            undefinedSearchTerm.noticeMessage = [data objectForKey:@"notice_message"];
        }
        
        if ([data objectForKey:@"search_tips"]) {
            NSDictionary *searchTipsDic = [data objectForKey:@"search_tips"];
            
            RISearchType *searchType = [[RISearchType alloc] init];
            
            if ([searchTipsDic objectForKey:@"text"]) {
                searchType.text = [searchTipsDic objectForKey:@"text"];
            }
            
            if ([searchTipsDic objectForKey:@"title"]) {
                searchType.title = [searchTipsDic objectForKey:@"title"];
            }
            
            undefinedSearchTerm.searchType = searchType;
        }
        
        if ([data objectForKey:@"featured_box"]) {
            if ([[data objectForKey:@"featured_box"] isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = [data objectForKey:@"featured_box"];
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
                        
                        if ([productDic objectForKey:@"max_savings_percentage"]) {
                            product.maxPercentageSaving = [productDic objectForKey:@"max_savings_percentage"];
                        }
                        
                        if ([productDic objectForKey:@"price"]) {
                            product.price = [productDic objectForKey:@"price"];
                            product.priceFormatted = [RICountryConfiguration formatPrice:[NSNumber numberWithFloat:[product.price floatValue]]
                                                                                 country:[RICountryConfiguration getCurrentConfiguration]];
                        }
                        
                        if ([productDic objectForKey:@"brand"]) {
                            product.brand = [productDic objectForKey:@"brand"];
                        }
                        
                        if ([productDic objectForKey:@"url"]) {
                            product.url = [productDic objectForKey:@"url"];
                        }
                        
                        if ([productDic objectForKey:@"image"]) {
                            NSArray *productImages = [productDic objectForKey:@"image"];
                            NSMutableArray *tempImagesArray = [NSMutableArray new];
                            
                            for (NSDictionary *dic in productImages) {
                                if ([dic objectForKey:@"url"]) {
                                    [tempImagesArray addObject:[dic objectForKey:@"url"]];
                                }
                            }
                            
                            product.imagesArray = [tempImagesArray copy];
                        }
                        
                        [tempArray addObject:product];
                    }
                    
                    featuredBox.products = [tempArray copy];
                }
                
                undefinedSearchTerm.featuredBox = featuredBox;
            }
        }
        
        if ([data objectForKey:@"featured_brandbox"]) {
            if ([[data objectForKey:@"featured_brandbox"] isKindOfClass:[NSArray class]]) {
                NSArray *tempArray = [data objectForKey:@"featured_brandbox"];
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
                        
                        if ([dic objectForKey:@"url"]) {
                            brand.url = [dic objectForKey:@"url"];
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
