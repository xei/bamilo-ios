//
//  RIProduct.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIBanner.h"
#import "RICatalog.h"
#import "RIRecentlyViewedProductSku.h"
#import "RICatalogSorting.h"


@class RIImage, RIProductSimple, RIVariation, RIBundle, Seller, RIUndefinedSearchTerm;
@protocol TrackableProductProtocol;

@interface RIProduct : NSObject <TrackableProductProtocol>

@property (nonatomic, retain) NSString * attributeCareLabel;
@property (nonatomic, retain) NSString * attributeColor;
@property (nonatomic, retain) NSString * attributeDescription;
@property (nonatomic, retain) NSString * attributeMainMaterial;
@property (nonatomic, retain) NSString * attributeSetId;
@property (nonatomic, retain) NSString * attributeShortDescription;
@property (nonatomic, retain) NSNumber * avr;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSString * maxPriceFormatted;
@property (nonatomic, retain) NSNumber * maxPriceEuroConverted;
@property (nonatomic, retain) NSString * maxSavingPercentage;
@property (nonatomic, retain) NSNumber * maxSpecialPrice;
@property (nonatomic, retain) NSString * maxSpecialPriceFormatted;
@property (nonatomic, retain) NSNumber * maxSpecialPriceEuroConverted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * priceFormatted;
@property (nonatomic, retain) NSNumber * priceEuroConverted;
@property (nonatomic, retain) NSNumber * shopFirst;
@property (nonatomic, retain) NSString * shopFirstOverlayText;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber *specialPrice;
@property (nonatomic, retain) NSString *specialPriceFormatted;
@property (nonatomic, retain) NSNumber *specialPriceEuroConverted;
@property (nonatomic, retain) NSNumber *sum;
@property (nonatomic, retain) NSString *targetString;
@property (nonatomic, retain) NSNumber *isNew;
@property (nonatomic, retain) NSDate *favoriteAddDate;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *productSimples;
@property (nonatomic, retain) NSArray *variations;
@property (nonatomic, retain) NSString *sizeGuideUrl;
@property (nonatomic, retain) NSNumber *reviewsTotal;
@property (nonatomic, retain) NSString *richRelevanceParameter;
@property (nonatomic, retain) NSString *richRelevanceTitle;
@property (nonatomic, retain) NSNumber *offersMinPrice;
@property (nonatomic, retain) NSNumber *offersMinPriceEuroConverted;
@property (nonatomic, retain) NSNumber *offersTotal;
@property (nonatomic, retain) NSString *offersMinPriceFormatted;
@property (nonatomic, retain) NSNumber *bucketActive;
@property (nonatomic, retain) NSString *shortSummary;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic) BOOL preOrder;
@property (nonatomic, strong) NSString* categoryName;
@property (nonatomic, strong) NSString* categoryUrlKey;
@property (nonatomic, retain) NSArray *categoryIds;
@property (nonatomic, retain) NSSet *relatedProducts;
@property (nonatomic, retain) NSOrderedSet *specifications;
@property (nonatomic, retain) Seller *seller;
@property (nonatomic, retain) NSString *shareUrl;
@property (nonatomic, retain) NSString *priceRange;
@property (nonatomic, retain) NSString *vertical;
@property (nonatomic) BOOL fashion;
@property (nonatomic, retain) NSString *brandId;
@property (nonatomic, retain) NSString *brandImage;
@property (nonatomic, retain) NSString *brand;
@property (nonatomic, retain) NSString *brandTarget;
@property (nonatomic, retain) NSString *brandUrlKey;
@property (nonatomic) BOOL hasStock;
@property (nonatomic) BOOL freeShippingPossible;

@property (nonatomic) BOOL isInWishList;
@property (nonatomic, retain) NSNumber *payablePrice;

/**
 *  Method to load a product and all its details given his sku. This method uses getCompleteProductWithUrl:successBlock:andFailureBlock:
 *
 *  @param the product sku
 *  @param the success block containing the obtained product
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCompleteProductWithSku:(NSString*)sku successBlock:(void (^)(id product))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a product and all its details given his url
 *
 *  @param the product target
 *  @param the parameter dictionary to be sent in the request
 *  @param the success block containing the obtained product
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCompleteProductWithTargetString:(NSString*)targetString withRichParameter:(NSDictionary*)parameter successBlock:(void (^)(id product))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a set of products given a base product url, the sorting method and the paging info
 *   This method calls getProductsWithFullUrl:successBlock:andFailureBlock:
 *
 *  @param the catalog base url
 *  @param the sorting method to be used
 *  @param the page that is being requested
 *  @param the max number of products per page
 *  @param the filters array
 *  @param the filter type (used for push notifications)
 *  @param the filter value (used for push notifications)
 *  @param the success block containing the obtained products, productCount, filters and related categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
//+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
//                          sortingMethod:(RICatalogSortingEnum)sortingMethod
//                                   page:(NSInteger)page
//                               maxItems:(NSInteger)maxItems
//                                filters:(NSArray*)filters
//                             filterPush:(NSString*)filterPush
//                           successBlock:(void (^)(RICatalog *catalog))successBlock
//                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error, RIUndefinedSearchTerm *undefSearchTerm))failureBlock;

/**
 *  Method to load a set of products given an url
 *
 *  @param the url to get the products
 *  @param the success block containing the obtained products, product count, filters and related categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
//+ (NSString *)getProductsWithFullUrl:(NSString*)url
//                        successBlock:(void (^)(RICatalog *catalog))successBlock
//                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error, RIUndefinedSearchTerm *undefSearchTerm))failureBlock;

/**
 *  Method to load a the favorite products from coredata
 *
 *  @param the success block containing the favorite products
 *  @param the failure block containing the error message
 *
 */
+ (void)getFavoriteProductsWithSuccessBlock:(void (^)(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (void)getFavoriteProductsForPage:(NSInteger)page maxItems:(NSInteger)maxItems SuccessBlock:(void (^)(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to add a product to favorites list (and save it in coredata)
 *
 *  @param the product to be added to the recently viewed list
 *
 */
//+ (void)addToFavorites:(RIProduct*)product successBlock:(void (^)(RIApiResponse apiResponse, NSArray *success))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to remove a product from favorites list (and save it in coredata)
 *
 *  @param the product to be added to the recently viewed list
 *  @param the success block containing the favorite products list updated
 *
 */
//+ (void)removeFromFavorites:(RIProduct*)product successBlock:(void (^)(RIApiResponse apiResponse, NSArray *success))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a the recently viewed products from coredata
 *
 *  @param the success block containing the recently viewed product
 *  @param the failure block containing the error message
 *
 */
+ (void)getRecentlyViewedProductsWithSuccessBlock:(void (^)(NSArray *recentlyViewedProducts))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;


/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 *  Method to parse an RIProduct given a JSON object
 *
 *  @return the parsed RIProduct
 */
+ (RIProduct *)parseProduct:(NSDictionary *)productJSON country:(RICountryConfiguration*)country;

+ (NSString *)getBundleWithSku:(NSString *)sku successBlock:(void (^)(RIBundle* bundle))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (NSString*)getTopBrand:(RIProduct *)seenProduct;

+ (NSString *)getRichRelevanceRecommendationFromTarget:(NSString *)rrTargetString successBlock:(void (^)(NSSet *recommendationProducts, NSString *title))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

@end


@interface RIBundle : NSObject

@property (strong, nonatomic) NSString *bundleId;
@property (strong, nonatomic) NSArray *bundleProducts;

@end
