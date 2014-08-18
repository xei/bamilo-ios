//
//  RIProduct.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIImage, RIProductSimple, RIVariation;

typedef NS_ENUM(NSInteger, RICatalogSorting) {
    RICatalogSortingPopularity = 0,
    RICatalogSortingRating,
    RICatalogSortingNewest,
    RICatalogSortingPriceUp,
    RICatalogSortingPriceDown,
    RICatalogSortingName,
    RICatalogSortingBrand
};

@interface RIProduct : NSManagedObject

@property (nonatomic, retain) NSString * activatedAt;
@property (nonatomic, retain) NSString * attributeCareLabel;
@property (nonatomic, retain) NSString * attributeColor;
@property (nonatomic, retain) NSString * attributeDescription;
@property (nonatomic, retain) NSString * attributeMainMaterial;
@property (nonatomic, retain) NSString * attributeSetId;
@property (nonatomic, retain) NSString * attributeShortDescription;
@property (nonatomic, retain) NSNumber * avr;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSString * idCatalogConfig;
@property (nonatomic, retain) NSNumber * maxPrice;
@property (nonatomic, retain) NSString * maxSavingPercentage;
@property (nonatomic, retain) NSNumber * maxSpecialPrice;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) NSNumber * specialPrice;
@property (nonatomic, retain) NSNumber * sum;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSOrderedSet *images;
@property (nonatomic, retain) NSOrderedSet *productSimples;
@property (nonatomic, retain) NSOrderedSet *variations;

//Not a coredata relationship
@property (nonatomic, retain) NSOrderedSet *categoryIds;

/**
 *  Method to load a product given his url
 *
 *  @param the product url
 *  @param the success block containing the obtained product
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getProductWithUrl:(NSString *)url
                   successBlock:(void (^)(id product))successBlock
                andFailureBlock:(void (^)(NSArray *error))failureBlock;

/**
 *  Method to load a set of products given a base product url, the sorting method and the paging info
 *   This method calls getProductsWithFullUrl:successBlock:andFailureBlock:
 *
 *  @param the catalog base url
 *  @param the sorting method to be used
 *  @param the page that is being requested
 *  @param the max number of products per page
 *  @param the filters array
 *  @param the success block containing the obtained products
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
                          sortingMethod:(RICatalogSorting)sortingMethod
                                   page:(NSInteger)page
                               maxItems:(NSInteger)maxItems
                                filters:(NSArray*)filters
                           successBlock:(void (^)(NSArray *products, NSArray *filters))successBlock
                        andFailureBlock:(void (^)(NSArray *error))failureBlock;

/**
 *  Method to load a set of products given an url
 *
 *  @param the url to get the products
 *  @param the success block containing the obtained products
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getProductsWithFullUrl:(NSString*)url
                        successBlock:(void (^)(NSArray *products, NSArray *filters))successBlock
                     andFailureBlock:(void (^)(NSArray *error))failureBlock;

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
+ (RIProduct *)parseProduct:(NSDictionary *)productJSON;

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
