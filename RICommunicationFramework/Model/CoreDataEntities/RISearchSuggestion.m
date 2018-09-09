//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"
#import "RITarget.h"

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

+ (void)deleteSearchSuggestionByTargetString:(NSString *)targetString {
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    for (RISearchSuggestion *tempSearch in searches) {
        if ([tempSearch.targetString isEqualToString:targetString]) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:tempSearch];
            [[RIDataBaseWrapper sharedInstance] saveContext];
            
            break;
        }
    }
}

+ (RISearchSuggestion *)getSearchSuggestionWithQuery:(NSString *)query isRecentSearch:(BOOL)isRecentSearch andContext:(BOOL)save {
    RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
    newSearchSuggestion.item = query;
    newSearchSuggestion.relevance = @(0);
    newSearchSuggestion.isRecentSearch = isRecentSearch;
    newSearchSuggestion.date = [NSDate date];
    return newSearchSuggestion;
}

+ (void)saveSearchSuggestionOnDB:(RISearchSuggestion *)searchSuggestion isRecentSearch:(BOOL)isRecentSearch andContext:(BOOL)save {
    if(VALID_NOTEMPTY(searchSuggestion.item, NSString)) {    
        if ([RISearchSuggestion checkIfSuggestionsExistsOnDB:searchSuggestion.targetString]) {
            [RISearchSuggestion deleteSearchSuggestionByTargetString:searchSuggestion.targetString];
        }
        [searchSuggestion setIsRecentSearch:isRecentSearch];
        [searchSuggestion setDate:[NSDate date]];
        //The limit for recent search is 5, if there is > 5 it's necessary to delete the old one
        if (isRecentSearch) {
            NSMutableArray *searches = [[[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])] mutableCopy];
            
            if (searches.count > 4) {
                [searches sortUsingComparator:^(RISearchSuggestion *obj1, RISearchSuggestion *obj2) {
                     NSComparisonResult result = [obj1.date compare:obj2.date];
                     switch (result) {
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

#pragma mark - Get Recent searches

+ (NSArray *)getRecentSearches {
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    
    if (0 == searches.count) {
        return nil;
    } else {
        NSMutableArray *array = [NSMutableArray new];
        
        for (RISearchSuggestion *suggestion in searches) {
            if (suggestion.isRecentSearch) {
                [array addObject:suggestion];
            }
        }
        if (array.count > 1) {
            [array sortUsingComparator:^(RISearchSuggestion *obj1, RISearchSuggestion *obj2) {
                 NSComparisonResult result = [obj1.date compare:obj2.date];
                 
                 switch (result) {
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

+ (void)deleteAllSearches {
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RISearchSuggestion class])];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)putRecentSearchInTop:(RISearchSuggestion *)search {
    search.date = [NSDate date];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID {
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Private methods

+ (BOOL)checkIfSuggestionsExistsOnDB:(NSString *)targetString {
    BOOL suggestionExists = false;
    NSArray* searchSuggestions = [RISearchSuggestion getSearchSuggestionsOnDBForTargetString:targetString];
    if(VALID_NOTEMPTY(searchSuggestions, NSArray)) {
        suggestionExists = true;
    }
    return suggestionExists;
}

+ (NSArray *)getSearchSuggestionsOnDBForTargetString:(NSString*)targetString {
    return [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RISearchSuggestion class]) withPropertyName:@"targetString" andPropertyValue:targetString];
}

+ (NSArray*) parseSearchSuggestions:(NSArray*)jsonObject forTextQuery:(NSString *)textQuery {
    NSMutableArray *suggestions = [[NSMutableArray alloc] init];
    
    if(VALID_NOTEMPTY(jsonObject, NSArray)) {
        for(NSDictionary *suggestionObject in jsonObject) {
            if(VALID_NOTEMPTY(suggestionObject, NSDictionary)) {
                [suggestions addObject:[RISearchSuggestion parseSearchSuggestion:suggestionObject forTextQuery:textQuery]];
            }
        }
    }
    return [suggestions copy];
}

+ (RISearchSuggestion *)parseSearchSuggestion:(NSDictionary*)jsonObject forTextQuery:(NSString *)textQuery {
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

+ (RIUndefinedSearchTerm *)parseUndefinedSearchTerm:(NSDictionary *)json {
    if (NOTEMPTY(json)) {
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
                            product.priceFormatted = [RICountryConfiguration formatPrice:[NSNumber  numberWithLongLong:[product.price longLongValue]]
                                                                                 country:[RICountryConfiguration getCurrentConfiguration]];
                        } else if ([productDic objectForKey:@"price"]) {
                            product.price = [productDic objectForKey:@"price"];
                            product.priceFormatted = [RICountryConfiguration formatPrice:[NSNumber numberWithLongLong:[product.price longLongValue]]
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
