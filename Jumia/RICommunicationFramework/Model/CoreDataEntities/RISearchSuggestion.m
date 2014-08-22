//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"
#import "RIProduct.h"

@implementation RISearchSuggestion

@dynamic item;
@dynamic relevance;
@dynamic isRecentSearch;

+ (void)saveSearchSuggestionOnDB:(NSString *)query
                  isRecentSearch:(BOOL)isRecentSearch
{
    if(VALID_NOTEMPTY(query, NSString) && ![RISearchSuggestion checkIfSuggestionsExistsOnDB:query])
    {
        RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
        
        newSearchSuggestion.item = query;
        newSearchSuggestion.relevance = 0;
        newSearchSuggestion.isRecentSearch = isRecentSearch;
        
        // The limit for recent search is 5, if there is > 5 it's necessary to delete the old one
        if (isRecentSearch)
        {
            NSMutableArray *searches = [[[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RISearchSuggestion class])] mutableCopy];
            
            if (searches.count > 4)
            {
                [[RIDataBaseWrapper sharedInstance] deleteObject:[searches objectAtIndex:0]];
                [[RIDataBaseWrapper sharedInstance] saveContext];
                [searches removeObjectAtIndex:0];
            }
            
            newSearchSuggestion.relevance = 0;
            
            [searches insertObject:newSearchSuggestion
                           atIndex:0];
            
            for (NSInteger i = 0 ; i < searches.count ; i++)
            {
                RISearchSuggestion *suggestionToAdd = (RISearchSuggestion *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
                RISearchSuggestion *suggestion = [searches objectAtIndex:i];
                
                suggestionToAdd.item = suggestion.item;
                suggestionToAdd.relevance = @(i);
                suggestionToAdd.isRecentSearch = suggestion.isRecentSearch;
                
                [[RIDataBaseWrapper sharedInstance] insertManagedObject:suggestionToAdd];
                [[RIDataBaseWrapper sharedInstance] deleteObject:suggestion];
            }
            
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
                  andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
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
                                                                  failureBlock(nil);
                                                              }];
                                                              
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
                 NSInteger value1 = [obj1.relevance integerValue];
                 NSInteger value2 = [obj2.relevance integerValue];
                 
                 if (value1 > value2)
                 {
                     return (NSComparisonResult)NSOrderedDescending;
                 }
                 
                 if (value1 < value2)
                 {
                     return (NSComparisonResult)NSOrderedAscending;
                 }
                 
                 return (NSComparisonResult)NSOrderedSame;
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

+ (BOOL) checkIfSuggestionsExistsOnDB:(NSString *)query
{
    BOOL suggestionExists = false;
    NSArray* searchSuggestions = [RISearchSuggestion getSearchSuggestionsOnDBForQuery:query];
    if(VALID_NOTEMPTY(searchSuggestions, NSArray))
    {
        suggestionExists = true;
    }
    return suggestionExists;
}


+ (NSArray *) getSearchSuggestionsOnDBForQuery:(NSString*)query
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

+ (RISearchSuggestion*) parseSearchSuggestion:(NSDictionary*)jsonObject
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

@end
