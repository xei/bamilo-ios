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

/**
 * Method to save a search suggestions on core data
 *
 * @param the query to be saved on core data
 */
+ (void)saveSearchSuggestionOnDB:(NSString *)query;

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
 * Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end