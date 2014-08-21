//
//  RIProduct.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIProduct.h"
#import "RIImage.h"
#import "RIProductSimple.h"
#import "RIVariation.h"
#import "RIFilter.h"
#import "RICategory.h"

@implementation RIProduct

@dynamic activatedAt;
@dynamic attributeCareLabel;
@dynamic attributeColor;
@dynamic attributeDescription;
@dynamic attributeMainMaterial;
@dynamic attributeSetId;
@dynamic attributeShortDescription;
@dynamic avr;
@dynamic brand;
@dynamic descriptionString;
@dynamic idCatalogConfig;
@dynamic maxPrice;
@dynamic maxSavingPercentage;
@dynamic maxSpecialPrice;
@dynamic name;
@dynamic price;
@dynamic sku;
@dynamic specialPrice;
@dynamic sum;
@dynamic url;
@dynamic isNew;
@dynamic isFavorite;
@dynamic recentlyViewedDate;
@dynamic images;
@dynamic productSimples;
@dynamic variations;

@synthesize categoryIds;

+ (NSString *)getCompleteProductWithUrl:(NSString*)url
                           successBlock:(void (^)(id product))successBlock
                        andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock([RIProduct parseProduct:metadata]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
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

+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
                          sortingMethod:(RICatalogSorting)sortingMethod
                                   page:(NSInteger)page
                               maxItems:(NSInteger)maxItems
                                filters:(NSArray*)filters
                           successBlock:(void (^)(NSArray *products, NSArray *filters, NSArray* categories))successBlock
                        andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    NSString* fullUrl = [NSString stringWithFormat:@"%@?page=%d&maxitems=%d&%@&%@", url, page, maxItems, [RIProduct urlComponentForSortingMethod:sortingMethod], [RIFilter urlWithFiltersArray:filters]];
    return [RIProduct getProductsWithFullUrl:fullUrl
                                successBlock:successBlock
                             andFailureBlock:failureBlock];
}

+ (NSString *)getProductsWithFullUrl:(NSString*)url
                        successBlock:(void (^)(NSArray *products, NSArray *filters, NSArray* categories))successBlock
                     andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  
                                                                  NSArray* filtersJSON = [metadata objectForKey:@"filters"];
                                                                  
                                                                  NSArray* filtersArray;
                                                                  
                                                                  if (VALID_NOTEMPTY(filtersJSON, NSArray)) {
                                                                      
                                                                      filtersArray = [RIFilter parseFilters:filtersJSON];
                                                                      
                                                                  }
                                                                  
                                                                  NSArray* categoriesJSON = [metadata objectForKey:@"categories"];
                                                                  
                                                                  NSArray* categoriesArray;
                                                                  
                                                                  if (VALID_NOTEMPTY(categoriesJSON, NSArray)) {
                                                                      
                                                                      categoriesArray = [RICategory parseCategories:categoriesJSON persistData:NO];
                                                                      
                                                                  }
                                                                  
                                                                  NSArray* results = [metadata objectForKey:@"results"];
                                                                  
                                                                  if (VALID_NOTEMPTY(results, NSArray)) {
                                                                      
                                                                      NSMutableArray* products = [NSMutableArray new];
                                                                      
                                                                      for (NSDictionary* productJSON in results) {
                                                                          
                                                                          RIProduct* product = [RIProduct parseProduct:productJSON];
                                                                          [products addObject:product];
                                                                      }
                                                                      
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(products, filtersArray, categoriesArray);
                                                                      });
                                                                  }
                                                              }
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

+ (RIProduct *)parseProduct:(NSDictionary *)productJSON;
{
    RIProduct* newProduct = (RIProduct*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIProduct class])];
    
    NSDictionary *dataDic = [productJSON objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(dataDic, NSDictionary)) {
        if ([dataDic objectForKey:@"sku"]) {
            newProduct.sku = [dataDic objectForKey:@"sku"];
        }
        if ([dataDic objectForKey:@"name"]) {
            newProduct.name = [dataDic objectForKey:@"name"];
        }
        if ([dataDic objectForKey:@"url"]) {
            newProduct.url = [dataDic objectForKey:@"url"];
        }
        if ([dataDic objectForKey:@"description"]) {
            newProduct.descriptionString = [dataDic objectForKey:@"description"];
        }
        if ([dataDic objectForKey:@"brand"]) {
            newProduct.brand = [dataDic objectForKey:@"brand"];
        }
        if ([dataDic objectForKey:@"max_price"]) {
                newProduct.maxPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_price"] floatValue]];
        }
        if ([dataDic objectForKey:@"price"]) {
            newProduct.price = [NSNumber numberWithFloat:[[dataDic objectForKey:@"price"] floatValue]];
        }
        if ([dataDic objectForKey:@"special_price"]) {
            newProduct.specialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"special_price"] floatValue]];
        }
        if ([dataDic objectForKey:@"max_special_price"]) {
            newProduct.maxSpecialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_special_price"] floatValue]];
        }
        if ([dataDic objectForKey:@"max_saving_percentage"]) {
            newProduct.maxSavingPercentage = [dataDic objectForKey:@"max_saving_percentage"];
        }
        
        if ([dataDic objectForKey:@"ratings_total"]) {
            NSDictionary *ratingsDic = [dataDic objectForKey:@"ratings_total"];
            if (VALID_NOTEMPTY(ratingsDic, NSDictionary)) {
                if ([ratingsDic objectForKey:@"avr"]) {
                    newProduct.avr = [ratingsDic objectForKey:@"avr"];
                }
                if ([ratingsDic objectForKey:@"sum"]) {
                    newProduct.sum = [ratingsDic objectForKey:@"sum"];
                }
            }
        }
        
        if ([dataDic objectForKey:@"id_catalog_config"]) {
            newProduct.idCatalogConfig = [dataDic objectForKey:@"id_catalog_config"];
        }
        if ([dataDic objectForKey:@"activated_at"]) {
            newProduct.activatedAt = [dataDic objectForKey:@"activated_at"];
        }
        if ([dataDic objectForKey:@"attributes"]) {
            NSDictionary* attributes = [dataDic objectForKey:@"attributes"];
            if (VALID_NOTEMPTY(attributes, NSDictionary)) {
                if ([attributes objectForKey:@"description"]) {
                    newProduct.attributeDescription = [attributes objectForKey:@"description"];
                }
                if ([attributes objectForKey:@"main_material"]) {
                    newProduct.attributeMainMaterial = [attributes objectForKey:@"main_material"];
                }
                if ([attributes objectForKey:@"color"]) {
                    newProduct.attributeColor = [attributes objectForKey:@"color"];
                }
                if ([attributes objectForKey:@"care_label"]) {
                    newProduct.attributeCareLabel = [attributes objectForKey:@"care_label"];
                }
                if ([attributes objectForKey:@"short_description"]) {
                    newProduct.attributeShortDescription = [attributes objectForKey:@"short_description"];
                }
            }
        }
        if ([dataDic objectForKey:@"attribute_set_id"]) {
            newProduct.attributeSetId = [dataDic objectForKey:@"attribute_set_id"];
        }
        if ([dataDic objectForKey:@"categories"]) {
            newProduct.categoryIds = [NSOrderedSet orderedSetWithArray:[dataDic objectForKey:@"categories"]];
        }
        
        if ([dataDic objectForKey:@"simples"]) {
            NSArray* productSimplesJSON = [dataDic objectForKey:@"simples"];
            for (NSDictionary* simpleJSON in productSimplesJSON) {
                if (VALID_NOTEMPTY(simpleJSON, NSDictionary)) {
                    
                    RIProductSimple* productSimple = [RIProductSimple parseProductSimple:simpleJSON];
                    productSimple.product = newProduct;
                    [newProduct addProductSimplesObject:productSimple];
                }
            }
        }
        
        if ([dataDic objectForKey:@"variations"]) {
            NSDictionary* variationsJSON = [dataDic objectForKey:@"variations"];
            if (VALID_NOTEMPTY(variationsJSON, NSDictionary)) {
                
                [variationsJSON enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    RIVariation* variation = [RIVariation parseVariation:obj];
                    variation.sku = key;
                    variation.product = newProduct;
                    [newProduct addVariationsObject:variation];
                }];
            }
        }
        
        if ([dataDic objectForKey:@"image_list"]) {
            NSArray* imageListJSON = [dataDic objectForKey:@"image_list"];
            
            for (NSDictionary* imageJSON in imageListJSON) {
                if (VALID_NOTEMPTY(imageJSON, NSDictionary)) {
                    
                    RIImage* image = [RIImage parseImage:imageJSON];
                    image.product = newProduct;
                    [newProduct addImagesObject:image];
                }
            }
            
        } else {
            
            //in catalog request, we have images out of the data dictionary
            NSArray* imagesJSONArray = [productJSON objectForKey:@"images"];
            if (imagesJSONArray && [imagesJSONArray isKindOfClass:[NSArray class]]) {
                
                for (NSDictionary* imageJSON in imagesJSONArray) {
                    if (VALID_NOTEMPTY(imageJSON, NSDictionary)) {
                        
                        RIImage* image = [RIImage parseImage:imageJSON];
                        image.product = newProduct;
                        [newProduct addImagesObject:image];
                    }
                }
            }
        }
    }
    return newProduct;
}

+ (NSString*)urlComponentForSortingMethod:(RICatalogSorting)sortingMethod
{
    NSString* urlComponent = @"";
    
    switch (sortingMethod) {
        case RICatalogSortingRating:
            urlComponent = @"sort=rating&dir=desc";
            break;
        case RICatalogSortingNewest:
            urlComponent = @"sort=newest&dir=desc";
            break;
        case RICatalogSortingPriceUp:
            urlComponent = @"sort=price&dir=asc";
            break;
        case RICatalogSortingPriceDown:
            urlComponent = @"sort=price&dir=desc";
            break;
        case RICatalogSortingName:
            urlComponent = @"sort=name&dir=asc";
            break;
        case RICatalogSortingBrand:
            urlComponent = @"sort=brand&dir=asc";
            break;
        default: //RICatalogSortingPopularity
            break;
    }
    
    return urlComponent;
}

#pragma mark - Recently Viewed

+ (void)getRecentlyViewedProductsWithSuccessBlock:(void (^)(NSArray *recentlyViewedProducts))successBlock
                                  andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    NSArray* recentlyViewedProducts = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIProduct class]) withPropertyName:@"recentlyViewedDate"];
    
    if (VALID(recentlyViewedProducts, NSArray) && successBlock) {
        
        //reverse array
        NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:recentlyViewedProducts.count];
        NSEnumerator *enumerator = [recentlyViewedProducts reverseObjectEnumerator];
        for (id element in enumerator) {
            [reversedArray addObject:element];
        }
        successBlock(reversedArray);
    } else if (failureBlock) {
        failureBlock(nil);
    }
}

+ (void)addToRecentlyViewed:(RIProduct*)product
               successBlock:(void (^)(void))successBlock
            andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        RIProduct* productToDelete;
        
        for (RIProduct* recentProduct in recentlyViewedProducts) {
            
            if ([recentProduct.sku isEqualToString:product.sku]) {
                //same product, delete this one
                productToDelete = recentProduct;
                break;
            }
        }
        
        if (ISEMPTY(productToDelete) && recentlyViewedProducts.count >= 15) {
            //we've hit the limit, delete the older product
            for (RIProduct* recentProduct in recentlyViewedProducts) {
                
                if (ISEMPTY(productToDelete)) {
                    productToDelete = recentProduct;
                } else {
                    NSDate* oldestDate = [recentProduct.recentlyViewedDate earlierDate:productToDelete.recentlyViewedDate];
                    if ([oldestDate isEqualToDate:recentProduct.recentlyViewedDate]) {
                        productToDelete = recentProduct;
                    }
                }
            }
        }
        
        if (VALID_NOTEMPTY(productToDelete, RIProduct)) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:productToDelete];
        }
        
        //add the new product
        product.recentlyViewedDate = [NSDate date];
        [RIProduct saveProduct:product];
        
        if (successBlock) {
            successBlock();
        }
        
    } andFailureBlock:^(NSArray *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)removeAllRecentlyViewedWithSuccessBlock:(void (^)(void))successBlock
                                andFailureBlock:(void (^)(NSArray *))failureBlock;
{
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        for (RIProduct* product in recentlyViewedProducts) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:product];
            [[RIDataBaseWrapper sharedInstance] saveContext];
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } andFailureBlock:^(NSArray *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Favorites

+ (void)getFavoriteProductsWithSuccessBlock:(void (^)(NSArray *favoriteProducts))successBlock
                            andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    NSArray* productsWithVariable = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIProduct class]) withPropertyName:@"isFavorite"];
    NSMutableArray* favoriteProducts = [NSMutableArray new];
    for (RIProduct* product in productsWithVariable) {
        if (VALID_NOTEMPTY(product.isFavorite, NSNumber) && YES == [product.isFavorite boolValue]) {
            [favoriteProducts addObject:product];
        }
    }
    
    if (VALID(favoriteProducts, NSArray) && successBlock) {
        
        //reverse array
        NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:favoriteProducts.count];
        NSEnumerator *enumerator = [favoriteProducts reverseObjectEnumerator];
        for (id element in enumerator) {
            [reversedArray addObject:element];
        }
        successBlock(reversedArray);
    } else if (failureBlock) {
        failureBlock(nil);
    }
}

+ (void)addToFavorites:(RIProduct*)product
          successBlock:(void (^)(void))successBlock
       andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        
        BOOL alreadyFavorite = NO;
        
        for (RIProduct* favorite in favoriteProducts) {
            
            if ([favorite.sku isEqualToString:product.sku]) {
                //same product, don't need to add
                alreadyFavorite = YES;
                break;
            }
        }
        
        if (NO == alreadyFavorite) {
            //add the new product
            product.isFavorite = [NSNumber numberWithBool:YES];
            [RIProduct saveProduct:product];
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } andFailureBlock:^(NSArray *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)removeFromFavorites:(RIProduct*)product
               successBlock:(void (^)(NSArray* favoriteProducts))successBlock
            andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        
        RIProduct* productToDelete;
        NSMutableArray* updatedFavoritesList = [NSMutableArray new];
        
        for (RIProduct* favorite in favoriteProducts) {
            if ([favorite.sku isEqualToString:product.sku]) {
                //found product, delete it
                productToDelete = favorite;
            } else {
                //not the product we're looking for, add to updated list
                [updatedFavoritesList addObject:favorite];
            }
        }
        
        //remove the product
        if (VALID_NOTEMPTY(productToDelete, RIProduct)) {
            [[RIDataBaseWrapper sharedInstance] deleteObject:productToDelete];
            [[RIDataBaseWrapper sharedInstance] saveContext];
        }
        
        if (successBlock) {
            successBlock([updatedFavoritesList copy]);
        }
        
    } andFailureBlock:^(NSArray *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

#pragma mark - Save method

+ (void)saveProduct:(RIProduct *)product
{
    for (RIImage* image in product.images) {
        [RIImage saveImage:image];
    }
    for (RIProductSimple* productSimple in product.productSimples) {
        [RIProductSimple saveProductSimple:productSimple];
    }
    for (RIVariation* variation in product.variations) {
        [RIVariation saveVariation:variation];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:product];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
