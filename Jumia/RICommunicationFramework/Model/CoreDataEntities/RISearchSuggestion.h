//
//  RISearchSuggestion.h
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RISearchSuggestion : NSManagedObject

@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSNumber * relevance;
@property (nonatomic, assign) BOOL isRecentSearch;

/**
 * Method to save a search suggestions on core data
 *
 * @param the query to be saved on core data
 * @param boolean if it's recent search
 */
+ (void)saveSearchSuggestionOnDB:(NSString *)query
                  isRecentSearch:(BOOL)isRecentSearch;

/**
 * Method to request a set of search suggestions
 *
 * @param the query for which we want the suggestions
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getSuggestionsForQuery:(NSString *)query
                        successBlock:(void (^)(NSArray *suggestions))successBlock
                     andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to request results for a given query
 *
 * @param the query for which we want the results
 * @param the page number
 * @param the max items
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 *
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getResultsForSearch:(NSString *)query
                             page:(NSString *)page
                         maxItems:(NSString *)maxItems
                     successBlock:(void (^)(NSArray *results))successBlock
                  andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 * Method to get the recent searches
 *
 * @return an array with the searches
 */
+ (NSArray *)getRecentSearches;

/**
 * Method to delete all searches
 */
+ (void)deleteAllSearches;

@end
