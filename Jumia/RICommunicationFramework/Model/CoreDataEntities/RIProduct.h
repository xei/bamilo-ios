//
//  RIProduct.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RIBanner.h"
#import "RICatalog.h"


@class RIImage, RIProductSimple, RIVariation, RIBundle, RISeller;

/*
 * IMPORTANT NOTICE
 * If the order of the catalog sorting changes,
 * we've to change it in the push notifications as well
 */
typedef NS_ENUM(NSInteger, RICatalogSorting) {
    RICatalogSortingRating = 0,
    RICatalogSortingPopularity,
    RICatalogSortingNewest,
    RICatalogSortingPriceUp,
    RICatalogSortingPriceDown,
    RICatalogSortingName,
    RICatalogSortingBrand
};

@interface RIProduct : NSManagedObject

@property (nonatomic, retain) NSString * attributeCareLabel;
@property (nonatomic, retain) NSString * attributeColor;
@property (nonatomic, retain) NSString * attributeDescription;
@property (nonatomic, retain) NSString * attributeMainMaterial;
@property (nonatomic, retain) NSString * attributeSetId;
@property (nonatomic, retain) NSString * attributeShortDescription;
@property (nonatomic, retain) NSNumber * avr;
@property (nonatomic, retain) NSString * brand;
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
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * specialPrice;
@property (nonatomic, retain) NSString * specialPriceFormatted;
@property (nonatomic, retain) NSNumber * specialPriceEuroConverted;
@property (nonatomic, retain) NSNumber * sum;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSDate * favoriteAddDate;
@property (nonatomic, retain) NSDate * recentlyViewedDate;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) NSOrderedSet *productSimples;
@property (nonatomic, retain) NSOrderedSet *variations;
@property (nonatomic, retain) NSString* sizeGuideUrl;
@property (nonatomic, retain) NSNumber * reviewsTotal;

@property (nonatomic, retain) NSNumber * offersMinPrice;
@property (nonatomic, retain) NSNumber * offersMinPriceEuroConverted;
@property (nonatomic, retain) NSNumber * offersTotal;
@property (nonatomic, retain) NSString * offersMinPriceFormatted;
@property (nonatomic, retain) NSNumber *bucketActive;
@property (nonatomic, retain) NSString *shortSummary;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSNumber *numberOfTimesSeen;

//Not a coredata relationship
@property (nonatomic, retain) NSOrderedSet *categoryIds;
@property (nonatomic, retain) NSSet *relatedProducts;
@property (nonatomic, retain) NSSet *specifications;
@property (nonatomic, retain) RISeller *seller;
@property (nonatomic, retain) NSString *shareUrl;
@property (nonatomic, retain) NSString *priceRange;
@property (nonatomic, retain) NSString *vertical;
@property (nonatomic) BOOL fashion;

/**
 *  Method to load a product and all its details given his sku. This method uses getCompleteProductWithUrl:successBlock:andFailureBlock:
 *
 *  @param the product sku
 *  @param the parameter dictionary to be sent in the request
 *  @param the success block containing the obtained product
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCompleteProductWithSku:(NSString*)sku
                           successBlock:(void (^)(id product))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a product and all its details given his url
 *
 *  @param the product url
 *  @param the parameter dictionary to be sent in the request
 *  @param the success block containing the obtained product
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCompleteProductWithUrl:(NSString*)url
                      withRichParameter:(NSDictionary*)parameter
                           successBlock:(void (^)(id product))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

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
+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
                          sortingMethod:(RICatalogSorting)sortingMethod
                                   page:(NSInteger)page
                               maxItems:(NSInteger)maxItems
                                filters:(NSArray*)filters
                             filterPush:(NSString*)filterPush
                           successBlock:(void (^)(RICatalog *catalog))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a set of products given an url
 *
 *  @param the url to get the products
 *  @param the success block containing the obtained products, product count, filters and related categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getProductsWithFullUrl:(NSString*)url
                        successBlock:(void (^)(RICatalog *catalog))successBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to reload a set of products given their skus
 *
 *  @param an array of skus to be reloaded
 *  @param the success block containing the obtained products
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getUpdatedProductsWithSkus:(NSArray*)productSkus
                            successBlock:(void (^)(NSArray *products))successBlock
                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a the recently viewed products from coredata
 *
 *  @param the success block containing the recently viewed product
 *  @param the failure block containing the error message
 *
 */
+ (void)getRecentlyViewedProductsWithSuccessBlock:(void (^)(NSArray *recentlyViewedProducts))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to add a product to recently viewed list (and save it in coredata)
 *
 *  @param the product to be added to the recently viewed list
 *
 */
+ (void)addToRecentlyViewed:(RIProduct*)product
               successBlock:(void (^)(RIProduct* product))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to remove a recentrly viewed product
 *
 *  @param the product to be removed from the recently viewed list
 *
 */
+ (void)removeFromRecentlyViewed:(RIProduct *)product;

/**
 *  Method to delete all recently viewed products from coredata
 */
+ (void)removeAllRecentlyViewedWithSuccessBlock:(void (^)(void))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to load a the favorite products from coredata
 *
 *  @param the success block containing the favorite products
 *  @param the failure block containing the error message
 *
 */
+ (void)getFavoriteProductsWithSuccessBlock:(void (^)(NSArray *favoriteProducts))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (void)getFavoriteProductsForPage:(NSInteger)page
                          maxItems:(NSInteger)maxItems
                      SuccessBlock:(void (^)(NSArray *favoriteProducts))successBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to add a product to favorites list (and save it in coredata)
 *
 *  @param the product to be added to the recently viewed list
 *
 */
+ (void)addToFavorites:(RIProduct*)product
          successBlock:(void (^)(void))successBlock
       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to remove a product from favorites list (and save it in coredata)
 *
 *  @param the product to be added to the recently viewed list
 *  @param the success block containing the favorite products list updated
 *
 */
+ (void)removeFromFavorites:(RIProduct*)product
               successBlock:(void (^)(void))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

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

+ (NSString*)urlComponentForSortingMethod:(RICatalogSorting)sortingMethod;

+ (NSString*)sortingName:(RICatalogSorting)sortingMethod;

+ (NSString *)getBundleWithSku:(NSString *)sku
                  successBlock:(void (^)(RIBundle* bundle))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (NSString*)getTopBrand:(RIProduct *)seenProduct;

@end

@interface RIProduct (CoreDataGeneratedAccessors)

- (void)insertObject:(RIImage *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImagesAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(RIImage *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray *)values;
- (void)addImagesObject:(RIImage *)value;
- (void)removeImagesObject:(RIImage *)value;
- (void)addImages:(NSOrderedSet *)values;
- (void)removeImages:(NSOrderedSet *)values;
- (void)insertObject:(RIProductSimple *)value inProductSimplesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromProductSimplesAtIndex:(NSUInteger)idx;
- (void)insertProductSimples:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeProductSimplesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInProductSimplesAtIndex:(NSUInteger)idx withObject:(RIProductSimple *)value;
- (void)replaceProductSimplesAtIndexes:(NSIndexSet *)indexes withProductSimples:(NSArray *)values;
- (void)addProductSimplesObject:(RIProductSimple *)value;
- (void)removeProductSimplesObject:(RIProductSimple *)value;
- (void)addProductSimples:(NSOrderedSet *)values;
- (void)removeProductSimples:(NSOrderedSet *)values;
- (void)insertObject:(RIVariation *)value inVariationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromVariationsAtIndex:(NSUInteger)idx;
- (void)insertVariations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeVariationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInVariationsAtIndex:(NSUInteger)idx withObject:(RIVariation *)value;
- (void)replaceVariationsAtIndexes:(NSIndexSet *)indexes withVariations:(NSArray *)values;
- (void)addVariationsObject:(RIVariation *)value;
- (void)removeVariationsObject:(RIVariation *)value;
- (void)addVariations:(NSOrderedSet *)values;
- (void)removeVariations:(NSOrderedSet *)values;


@end

@interface RIBundle : NSObject

@property (strong, nonatomic) NSString *bundleId;
@property (strong, nonatomic) NSArray *bundleProducts;

@end
