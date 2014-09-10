//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"
#import "RIProduct.h"

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

+ (void)saveSearchSuggestionOnDB:(NSString *)query
                  isRecentSearch:(BOOL)isRecentSearch
{
    if(VALID_NOTEMPTY(query, NSString) && ![RISearchSuggestion checkIfSuggestionsExistsOnDB:query])
    {
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
        else
        {
            [[RIDataBaseWrapper sharedInstance] insertManagedObject:newSearchSuggestion];
            [[RIDataBaseWrapper sharedInstance] saveContext];
        }
    }
}

+ (NSString*)getSuggestionsForQuery:(NSString *)query
                       successBlock:(void (^)(NSArray *suggestions))successBlock
                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_SEARCH_SUGGESTIONS]]
                                                            parameters:[NSDictionary dictionaryWithObject:query forKey:@"q"]
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSMutableArray *suggestions = [[NSMutableArray alloc] init];
                                                              
                                                              // Add recent search suggestions
                                                              NSArray* suggestionsForQuery = [RISearchSuggestion getSearchSuggestionsOnDBForQuery:query];
                                                              if(VALID_NOTEMPTY(suggestionsForQuery, NSArray))
                                                              {
                                                                  [suggestions addObjectsFromArray:suggestionsForQuery];
                                                              }
                                                              
                                                              // Add request search suggestions
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSArray *requestSuggestions = [RISearchSuggestion parseSearchSuggestions:[metadata objectForKey:@"suggestions"]];
                                                                  if(VALID_NOTEMPTY(requestSuggestions, NSArray))
                                                                  {
                                                                      [suggestions addObjectsFromArray:requestSuggestions];
                                                                  }
                                                              }
                                                              
                                                              successBlock([suggestions copy]);
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

+ (NSString *)getResultsForSearch:(NSString *)query
                             page:(NSString *)page
                         maxItems:(NSString *)maxItems
                     successBlock:(void (^)(NSArray *results))successBlock
                  andFailureBlock:(void (^)(NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm))failureBlock
{
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *tempString = [NSString stringWithFormat:@"%@%@/search?setDevice=mobileApi&q=%@&page=%@&maxitems=%@", [RIApi getCountryUrlInUse], RI_API_VERSION, query, page, maxItems];
    NSURL *url = [NSURL URLWithString:tempString];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary *metadata = jsonObject[@"metadata"];
                                                                  NSDictionary *results = metadata[@"results"];
                                                                  
                                                                  NSMutableArray *temp = [NSMutableArray new];
                                                                  
                                                                  for (NSDictionary *dic in results) {
                                                                      [temp addObject:[RIProduct parseProduct:dic country:configuration]];
                                                                  }
                                                                  
                                                                  successBlock([temp copy]);
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if ([errorJsonObject objectForKey:@"metadata"])
                                                              {
                                                                  failureBlock(nil, [RISearchSuggestion parseUndefinedSearchTerm:[errorJsonObject objectForKey:@"metadata"]]);
                                                              }
                                                              else
                                                              {
                                                                  if(NOTEMPTY(errorJsonObject))
                                                                  {
                                                                      failureBlock([RIError getErrorMessages:errorJsonObject], nil);
                                                                  }
                                                                  else if(NOTEMPTY(errorObject))
                                                                  {
                                                                      NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                      failureBlock(errorArray, nil);
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(nil, nil);
                                                                  }
                                                              }
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
    RIUndefinedSearchTerm *undefinedSearchTerm = [[RIUndefinedSearchTerm alloc] init];
    
    return undefinedSearchTerm;
}

@end
