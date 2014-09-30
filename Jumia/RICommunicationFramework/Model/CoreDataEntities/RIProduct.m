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
@dynamic maxPriceFormatted;
@dynamic maxSavingPercentage;
@dynamic maxSpecialPrice;
@dynamic maxSpecialPriceFormatted;
@dynamic name;
@dynamic price;
@dynamic priceFormatted;
@dynamic sku;
@dynamic specialPrice;
@dynamic specialPriceFormatted;
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
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      successBlock([RIProduct parseProduct:metadata country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
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

+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
                          sortingMethod:(RICatalogSorting)sortingMethod
                                   page:(NSInteger)page
                               maxItems:(NSInteger)maxItems
                                filters:(NSArray*)filters
                           successBlock:(void (^)(NSArray *products, NSString* productCount, NSArray *filters, NSString *cateogryId, NSArray* categories))successBlock
                        andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    BOOL discountMode = NO;
    for (RIFilter* filter in filters) {
        for (RIFilterOption* filterOption in filter.options) {
            if (filterOption.discountOnly) {
                discountMode = YES;
                break;
            }
        }
    }
    if (discountMode) {
        NSString* countryUrl = [RIApi getCountryUrlInUse];
        NSString* endingUrl = [url stringByReplacingOccurrencesOfString:countryUrl withString:@""];
        endingUrl = [endingUrl stringByReplacingOccurrencesOfString:RI_API_VERSION withString:@""];
        url = [NSString stringWithFormat:@"%@%@special-price/%@", countryUrl, RI_API_VERSION, endingUrl];
    }
    
    NSString* fullUrl = [NSString stringWithFormat:@"%@?page=%d&maxitems=%d&%@&%@", url, page, maxItems, [RIProduct urlComponentForSortingMethod:sortingMethod], [RIFilter urlWithFiltersArray:filters]];
    return [RIProduct getProductsWithFullUrl:fullUrl
                                successBlock:successBlock
                             andFailureBlock:failureBlock];
}

+ (NSString *)getProductsWithFullUrl:(NSString*)url
                        successBlock:(void (^)(NSArray *products, NSString* productCount, NSArray *filters, NSString *cateogryId, NSArray* categories))successBlock
                     andFailureBlock:(void (^)(NSArray *error))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
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
                                                                      
                                                                      NSString* productCount = [metadata objectForKey:@"product_count"];
                                                                      
                                                                      NSString *categoryId = [metadata objectForKey:@"category_ids"];
                                                                      
                                                                      NSArray* results = [metadata objectForKey:@"results"];
                                                                      
                                                                      if (VALID_NOTEMPTY(results, NSArray)) {
                                                                          
                                                                          NSMutableArray* products = [NSMutableArray new];
                                                                          
                                                                          for (NSDictionary* productJSON in results) {
                                                                              
                                                                              RIProduct* product = [RIProduct parseProduct:productJSON country:configuration];
                                                                              [products addObject:product];
                                                                          }
                                                                          
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              successBlock(products, productCount, filtersArray, categoryId, categoriesArray);
                                                                          });
                                                                      }
                                                                  }
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

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (RIProduct *)parseProduct:(NSDictionary *)productJSON country:(RICountryConfiguration*)country
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
        if ([dataDic objectForKey:@"is_new"]) {
            newProduct.isNew = [NSNumber numberWithBool:[[dataDic objectForKey:@"is_new"] boolValue]];
        }
        if ([dataDic objectForKey:@"max_price"]) {
            newProduct.maxPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_price"] floatValue]];
            newProduct.maxPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxPrice country:country];
        }
        if ([dataDic objectForKey:@"price"]) {
            newProduct.price = [NSNumber numberWithFloat:[[dataDic objectForKey:@"price"] floatValue]];
            newProduct.priceFormatted = [RICountryConfiguration formatPrice:newProduct.price country:country];
        }
        if ([dataDic objectForKey:@"special_price"]) {
            newProduct.specialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"special_price"] floatValue]];
            newProduct.specialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.specialPrice country:country];
        }
        if ([dataDic objectForKey:@"max_special_price"]) {
            newProduct.maxSpecialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_special_price"] floatValue]];
            newProduct.maxSpecialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxSpecialPrice country:country];
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
                    
                    RIProductSimple* productSimple = [RIProductSimple parseProductSimple:simpleJSON country:country];
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
    
    newProduct.isFavorite = [NSNumber numberWithBool:[RIProduct productIsFavoriteInDatabase:newProduct]];
    
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

+ (NSString*)sortingName:(RICatalogSorting)sortingMethod
{
    NSString* sortingName = @"";
    
    switch (sortingMethod) {
        case RICatalogSortingRating:
            sortingName = @"Rating";
            break;
        case RICatalogSortingNewest:
            sortingName = @"Newest";
            break;
        case RICatalogSortingPriceUp:
            sortingName = @"Price up";
            break;
        case RICatalogSortingPriceDown:
            sortingName = @"Price down";
            break;
        case RICatalogSortingName:
            sortingName = @"Name";
            break;
        case RICatalogSortingBrand:
            sortingName = @"Brand";
            break;
        default: //RICatalogSortingPopularity
            break;
    }
    
    return sortingName;
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
    NSArray* allProducts = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIProduct class])];
    
    BOOL productExists = NO;
    for (RIProduct* currentProduct in allProducts) {
        if ([currentProduct.sku isEqualToString:product.sku]) {
            
            //found it, so just change the product by deleting the previous entry
            product.recentlyViewedDate = [NSDate date];
            product.isFavorite = currentProduct.isFavorite;
            [[RIDataBaseWrapper sharedInstance] deleteObject:currentProduct];
            [RIProduct saveProduct:product];
            productExists = YES;
            break;
        }
    }
    if (NO == productExists) {
        //did not find it, so save the product
        product.recentlyViewedDate = [NSDate date];
        [RIProduct saveProduct:product];
    }
    
    //now we need to check if there are more than 15 products
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        if (VALID_NOTEMPTY(recentlyViewedProducts, NSArray) && recentlyViewedProducts.count > 15) {
            
            //there are more than 15, we need to remove the oldest
            RIProduct* productToDelete = nil;
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
        
            if (VALID_NOTEMPTY(productToDelete, RIProduct)) {
                [RIProduct removeFromRecentlyViewed:productToDelete successBlock:^{
                    if (successBlock) {
                        successBlock();
                    }
                } andFailureBlock:^(NSArray *error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
                }];
            }
        }
    } andFailureBlock:^(NSArray *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)removeFromRecentlyViewed:(RIProduct *)product
{
    [[RIDataBaseWrapper sharedInstance] deleteObject:product];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)removeAllRecentlyViewedWithSuccessBlock:(void (^)(void))successBlock
                                andFailureBlock:(void (^)(NSArray *))failureBlock;
{
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        for (RIProduct* productToDelete in recentlyViewedProducts) {
            if (VALID_NOTEMPTY(productToDelete.isFavorite, NSNumber) && YES == [productToDelete.isFavorite boolValue]) {
                //has date, don't delete, just remove recentlyViewedDate
                productToDelete.recentlyViewedDate = nil;
            } else {
                //remove the product
                [[RIDataBaseWrapper sharedInstance] deleteObject:productToDelete];
            }
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

+ (void)removeFromRecentlyViewed:(RIProduct *)product
                    successBlock:(void (^)(void))successBlock
                 andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        for (RIProduct* currentProduct in recentlyViewedProducts) {
            if ([currentProduct.sku isEqualToString:product.sku]) {
                //found it
                
                if (VALID_NOTEMPTY(currentProduct.isFavorite, NSNumber) && YES == [currentProduct.isFavorite boolValue]) {
                    currentProduct.recentlyViewedDate = nil;
                } else {
                    [[RIDataBaseWrapper sharedInstance] deleteObject:currentProduct];
                }
                [[RIDataBaseWrapper sharedInstance] saveContext];
            }
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
    NSArray* allProducts = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIProduct class])];

    BOOL productExists = NO;
    for (RIProduct* currentProduct in allProducts) {
        if ([currentProduct.sku isEqualToString:product.sku]) {
            
            //found it
            currentProduct.isFavorite = [NSNumber numberWithBool:YES];
            [[RIDataBaseWrapper sharedInstance] saveContext];
            productExists = YES;
            break;
        }
    }
    
    if (NO == productExists) {
        product.isFavorite = [NSNumber numberWithBool:YES];
        [RIProduct saveProduct:product];
    }
    
    if (successBlock) {
        successBlock();
    }
}

+ (void)removeFromFavorites:(RIProduct*)product
               successBlock:(void (^)(void))successBlock
            andFailureBlock:(void (^)(NSArray *error))failureBlock;
{
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        
        for (RIProduct* currentProduct in favoriteProducts) {
            if ([currentProduct.sku isEqualToString:product.sku]) {
                //found it
                
                if (VALID_NOTEMPTY(currentProduct.recentlyViewedDate, NSDate)) {
                    //do not delete, just remove favorite variable
                    currentProduct.isFavorite = nil;
                } else {
                    [[RIDataBaseWrapper sharedInstance] deleteObject:product];
                }
                [[RIDataBaseWrapper sharedInstance] saveContext];
            }
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

+ (BOOL)productIsFavoriteInDatabase:(RIProduct*)product
{
    NSArray* productsWithVariable = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIProduct class]) withPropertyName:@"sku" andPropertyValue:product.sku];
    
    for (RIProduct* possibleProduct in productsWithVariable) {
        if (YES == [possibleProduct.isFavorite boolValue]) {
            return YES;
        }
    }
    
    return NO;
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
