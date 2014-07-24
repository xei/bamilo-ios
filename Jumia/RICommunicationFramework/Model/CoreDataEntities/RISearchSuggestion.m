//
//  RISearchSuggestion.m
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RISearchSuggestion.h"


@implementation RISearchSuggestion

@dynamic item;
@dynamic relevance;

+ (void)saveSearchSuggestionOnDB:(NSString *)query
{
    if(VALID_NOTEMPTY(query, NSString) && ![RISearchSuggestion checkIfSuggestionsExistsOnDB:query])
    {
        RISearchSuggestion *newSearchSuggestion = (RISearchSuggestion*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISearchSuggestion class])];
        
        newSearchSuggestion.item = query;
        newSearchSuggestion.relevance = 0;
        
        [[RIDataBaseWrapper sharedInstance] insertManagedObject:newSearchSuggestion];
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
}

+ (NSString*)getSuggestionsForQuery:(NSString *)query
                       successBlock:(void (^)(NSArray *suggestions))successBlock
                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_SEARCH_SUGGESTIONS]]
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
