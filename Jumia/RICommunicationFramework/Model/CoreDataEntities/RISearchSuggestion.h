//
//  RISearchSuggestion.h
//  Comunication Project
//
//  Created by Pedro Lopes on 22/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RIProduct.h"

@interface RISearchType : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;

@end

@interface RISearchTypeProduct : NSObject

@property (strong, nonatomic) NSString *sku;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *maxPrice;
@property (strong, nonatomic) NSString *maxPriceEuroConverted;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *priceFormatted;
@property (strong, nonatomic) NSString *priceEuroConverted;
@property (strong, nonatomic) NSNumber *maxPercentageSaving;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray *imagesArray;

@end

@interface RIFeaturedBox : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray *products;

@end

@interface RIBrand : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *url;

@end

@interface RIFeaturedBrandBox : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *brands;

@end

@interface RIUndefinedSearchTerm : NSObject

@property (strong, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *noticeMessage;
@property (strong, nonatomic) RISearchType *searchType;
@property (strong, nonatomic) RIFeaturedBox *featuredBox;
@property (strong, nonatomic) RIFeaturedBrandBox *featuredBrandBox;

@end

@interface RISearchSuggestion : NSManagedObject

@property (nonatomic, retain) NSString * item;
@property (nonatomic, retain) NSNumber * relevance;
@property (nonatomic, assign) BOOL isRecentSearch;
@property (nonatomic, assign) NSDate *date;

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
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to request results for a given query
 *
 * @param the query for which we want the results
 * @param the page number
 * @param the max items
 * @param the sorting method
 * @param the filters that are used
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 *
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getResultsForSearch:(NSString *)query
                             page:(NSString *)page
                         maxItems:(NSString *)maxItems
                    sortingMethod:(RICatalogSorting)sortingMethod
                          filters:(NSArray*)filters
                     successBlock:(void (^)(NSArray *results, NSArray *filters, NSNumber *productCount, RIBanner *banner))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm))failureBlock;

/**
 * Method to put a recent search in top
 *
 * @param the recent search
 */
+ (void)putRecentSearchInTop:(RISearchSuggestion *)search;

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
