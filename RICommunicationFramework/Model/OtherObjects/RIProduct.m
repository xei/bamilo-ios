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
#import "RICategory.h"
#import "RIBanner.h"
#import "RISpecification.h"
#import "RITarget.h"
#import "RISearchSuggestion.h"
#import "Bamilo-Swift.h"

@implementation RIBundle

+ (RIBundle *)parseRIBundle:(NSDictionary *)bundleJSON country:(RICountryConfiguration*)country {
    RIBundle *newBundle = [[RIBundle alloc] init];
    
    NSDictionary *dataDic = [bundleJSON objectForKey:@"bundle_entity"];
    
    if (VALID_NOTEMPTY(dataDic, NSDictionary)) {
        
        if([dataDic objectForKey:@"id"])
        {
            newBundle.bundleId = [dataDic objectForKey:@"id"];
        }
        
        if([dataDic objectForKey:@"products"])
        {
            NSArray* bundleProductsArray = [dataDic objectForKey:@"products"];
            if (VALID_NOTEMPTY(bundleProductsArray, NSArray)) {
                NSMutableArray* newBundleProducts = [NSMutableArray new];
                for (NSDictionary* productJSON in bundleProductsArray) {
                    if (VALID_NOTEMPTY(productJSON, NSDictionary)) {
                        RIProduct *product = [RIProduct parseProduct:productJSON country:country];
                        [newBundleProducts addObject:product];
                    }
                }
                newBundle.bundleProducts = [newBundleProducts copy];
            }
        }
    }
    
    return newBundle;
}

@end

@implementation RIProduct
@synthesize attributeCareLabel;
@synthesize attributeColor;
@synthesize attributeDescription;
@synthesize attributeMainMaterial;
@synthesize attributeSetId;
@synthesize attributeShortDescription;
@synthesize avr;
@synthesize descriptionString;
@synthesize maxPrice;
@synthesize maxPriceFormatted;
@synthesize maxPriceEuroConverted;
@synthesize maxSavingPercentage;
@synthesize maxSpecialPrice;
@synthesize maxSpecialPriceFormatted;
@synthesize maxSpecialPriceEuroConverted;
@synthesize name;
@synthesize price;
@synthesize priceFormatted;
@synthesize priceEuroConverted;
@synthesize sku;
@synthesize specialPrice;
@synthesize specialPriceFormatted;
@synthesize specialPriceEuroConverted;
@synthesize sum;
@synthesize targetString;
@synthesize shopFirst;
@synthesize shopFirstOverlayText;
@synthesize isNew;
@synthesize favoriteAddDate;
@synthesize images;
@synthesize productSimples;
@synthesize variations;
@synthesize sizeGuideUrl;
@synthesize reviewsTotal;
@synthesize offersMinPrice;
@synthesize offersMinPriceEuroConverted;
@synthesize offersMinPriceFormatted;
@synthesize offersTotal;
@synthesize bucketActive;
@synthesize shortSummary;
@synthesize summary;
@synthesize richRelevanceParameter;
@synthesize richRelevanceTitle;

@synthesize categoryIds;
@synthesize relatedProducts;
@synthesize specifications;
@synthesize seller;
@synthesize shareUrl;
@synthesize priceRange;
@synthesize vertical;
@synthesize fashion;
@synthesize preOrder;
@synthesize brandId;
@synthesize brandImage;
@synthesize brand;
@synthesize brandTarget;
@synthesize brandUrlKey;

@synthesize hasStock;
@synthesize freeShippingPossible;

- (NSNumber *)getPayablePrice {
    return price;
}

- (BOOL)getIsInWishList {
    return favoriteAddDate != nil;
}

+ (NSString *)getCompleteProductWithSku:(NSString*)sku successBlock:(void (^)(id product))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock {
    NSString *finalTargetString = [RITarget getTargetString:PRODUCT_DETAIL node:sku];
    return [RIProduct getCompleteProductWithTargetString:finalTargetString
                                       withRichParameter:nil
                                            successBlock:^(id product) {
                                                successBlock(product);
                                            } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                                failureBlock(apiResponse, error);
                                            }];
}

+ (NSString *)getCompleteProductWithTargetString:(NSString*)targetString
                               withRichParameter:(NSDictionary*)parameter
                                    successBlock:(void (^)(id product))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock {
    NSString *richParam = [NSMutableString new];
    if (VALID_NOTEMPTY(parameter, NSDictionary) && [parameter objectForKey:@"rich_parameter"]) {
        richParam = [RITarget getURLStringforTargetString:[parameter objectForKey:@"rich_parameter"]];
    }
    
    NSString * url =  [RITarget getURLStringforTargetString:targetString];
    url = [NSString stringWithFormat:@"%@/%@",url,richParam];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      RIProduct* newProduct = [RIProduct parseProduct:metadata country:configuration];
                                                                      if (VALID_NOTEMPTY(newProduct, RIProduct) && VALID_NOTEMPTY(newProduct.sku, NSString)) {
                                                                          if ([metadata objectForKey:@"recommended_products"]) {
                                                                              [RIProduct getRichRelevanceRecommendation:[metadata objectForKey:@"recommended_products"] successBlock:^(id recommendationProducts, NSString *title) {
                                                                                  newProduct.relatedProducts = recommendationProducts;
                                                                                  successBlock(newProduct);
                                                                              } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
                                                                                  successBlock(newProduct);
                                                                              }];
                                                                          } else {
                                                                              successBlock(newProduct);
                                                                          }
                                                                      } else {
                                                                          failureBlock(apiResponse, nil);
                                                                      }
                                                                  } else {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, errorMessages);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if (NOTEMPTY(errorJsonObject)) {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if (NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (void)getRichRelevanceRecommendation:(NSDictionary*)recomendedJsonObject
                          successBlock:(void (^)(NSSet *recommendationProducts, NSString *title))successBlock
                       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    [RIProduct getRichRelevanceRecommendationFromTarget:[recomendedJsonObject objectForKey:@"target"] successBlock:successBlock andFailureBlock:failureBlock];
}

+ (NSString *)getRichRelevanceRecommendationFromTarget:(NSString *)rrTargetString
                                          successBlock:(void (^)(NSSet *recommendationProducts, NSString *title))successBlock
                                       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSURL *url = [NSURL URLWithString:[RITarget getURLStringforTargetString:rrTargetString]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary* jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary *recommendedMetadata = VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"metadata"], NSDictionary);
                                                                  NSArray *data = VALID_NOTEMPTY_VALUE([recommendedMetadata objectForKey:@"data"], NSArray);
                                                                  NSSet *productsSet = VALID_NOTEMPTY_VALUE([RIProduct parseRichRelevanceProducts:data country:configuration], NSSet);
                                                                  NSString *title = VALID_NOTEMPTY_VALUE([recommendedMetadata objectForKey:@"title"], NSString);
                                                                  if (productsSet) {
                                                                      successBlock(productsSet, title);
                                                                  } else {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if (NOTEMPTY(errorJsonObject)) {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

//+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
//                          sortingMethod:(RICatalogSortingEnum)sortingMethod
//                                   page:(NSInteger)page
//                               maxItems:(NSInteger)maxItems
//                                filters:(NSArray*)filters
//                             filterPush:(NSString*)filterPush
//                           successBlock:(void (^)(RICatalog *catalog))successBlock
//                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error, RIUndefinedSearchTerm *undefSearchTerm))failureBlock
//{
//    NSString* fullUrl = @"";
//    NSString *filtersString = [BaseSearchFilterItem urlWithFiltersArray:filters];
//    
//
//    NSString *sortingString = [RICatalogSorting urlComponentForSortingMethod:sortingMethod];
//    if (sortingString.length) {
//        sortingString = [NSString stringWithFormat:@"/%@", sortingString];
//    }
//    
//    if(filtersString.length) {
//        fullUrl = [NSString stringWithFormat:@"%@/page/%ld/maxitems/%ld%@%@", url, (long)page, (long)maxItems, sortingString, [NSString stringWithFormat:@"/%@" ,filtersString]];
//    } else {
//        fullUrl = [NSString stringWithFormat:@"%@/page/%ld/maxitems/%ld%@", url, (long)page, (long)maxItems, sortingString];
//    }
//    
//    if (filterPush.length) {
//        fullUrl = [NSString stringWithFormat:@"%@/%@", fullUrl, filterPush];
//    }
//    
//    return [RIProduct getProductsWithFullUrl:fullUrl successBlock:successBlock andFailureBlock:failureBlock];
//}
//
//+ (NSString *)getProductsWithFullUrl:(NSString*)url
//                        successBlock:(void (^)(RICatalog *catalog))successBlock
//                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error,  RIUndefinedSearchTerm *undefSearchTerm))failureBlock
//{
//    url = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *finalURL = [NSURL URLWithString:url];
//    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:finalURL
//                                                            parameters:nil
//                                                            httpMethod:HttpVerbGET
//                                                             cacheType:RIURLCacheDBCache
//                                                             cacheTime:RIURLCacheDefaultTime
//                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
//                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
//                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
//                                                                  
//                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
//                                                                  if (metadata) {
//                                                                      RICatalog *catalog = [RICatalog parseCatalog:metadata forCountryConfiguration:configuration];
//                                                                      
//                                                                      if (catalog.products.count) {
//                                                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                                                              successBlock(catalog);
//                                                                          });
//                                                                      } else {
//                                                                          failureBlock(RIApiResponseAPIError, nil, nil);
//                                                                      }
//                                                                  } else {
//                                                                      failureBlock(RIApiResponseAPIError, nil, nil);
//                                                                  }
//                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
//                                                                  failureBlock(apiResponse, nil, nil);
//                                                              }];
//                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
//                                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                                  if ([errorJsonObject objectForKey:@"metadata"]) {
//                                                                      failureBlock(apiResponse, nil, [RISearchSuggestion parseUndefinedSearchTerm:[errorJsonObject objectForKey:@"metadata"]]);
//                                                                  } else {
//                                                                      if(errorJsonObject) {
//                                                                          failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject], nil);
//                                                                      } else if(errorObject) {
//                                                                          NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
//                                                                          failureBlock(apiResponse, errorArray, nil);
//                                                                      } else {
//                                                                          failureBlock(apiResponse, nil, nil);
//                                                                      }
//                                                                  }
//                                                              });
//                                                          }];
//}

+ (void)getRecentlyViewedProductsWithSuccessBlock:(void (^)(NSArray *recentlyViewedProducts))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    [RIRecentlyViewedProductSku getRecentlyViewedProductSkusWithSuccessBlock:^(NSArray *recentlyViewedProductSkus) {
        if (VALID_NOTEMPTY(recentlyViewedProductSkus, NSArray)) {
            [RIProduct getUpdatedProductsWithRecentlyViewedProductSkus:recentlyViewedProductSkus successBlock:successBlock andFailureBlock:failureBlock];
        } else {
            successBlock(nil);
        }
    }];
}

+ (NSString *)getUpdatedProductsWithRecentlyViewedProductSkus:(NSArray*)recentlyViewedProductSkus
                                                 successBlock:(void (^)(NSArray *products))successBlock
                                              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_PROD_VALIDATE]];
    
    NSMutableDictionary* parametersDictionary = [NSMutableDictionary new];
    NSMutableArray* parametersArray = [NSMutableArray new];
    for (int i = 0; i < recentlyViewedProductSkus.count; i++) {
        RIRecentlyViewedProductSku* recentlyViewedProductSku = [recentlyViewedProductSkus objectAtIndex:i];
        [parametersArray addObject:recentlyViewedProductSku.productSku];
    }
    NSString* key = [NSString stringWithFormat:@"products[]"];
    [parametersDictionary setObject:parametersArray forKey:key];
    
    
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:[parametersDictionary copy]
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if (metadata) {
                                                                      NSArray* valid = [metadata objectForKey:@"valid"];
                                                                      if (valid.count) {
                                                                          NSMutableArray* validProducts = [NSMutableArray new];
                                                                          for (NSDictionary* validProductJSON in valid) {
                                                                              RIProduct* validProduct = [RIProduct parseProduct:validProductJSON country:configuration];
                                                                              [validProducts addObject:validProduct];
                                                                          }
                                                                          
                                                                          [RIRecentlyViewedProductSku resetRecentlyViewedWithProducts:validProducts successBlock:^(NSArray *productsArray) {
                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                  successBlock(validProducts);
                                                                              });
                                                                          } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                                                                              failureBlock(RIApiResponseAPIError, nil);
                                                                          }];
                                                                      } else {
                                                                          failureBlock(RIApiResponseAPIError, nil);
                                                                      }
                                                                  } else {
                                                                      failureBlock(RIApiResponseAPIError, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID {
    if(operationID.length)
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (RIProduct *)parseProduct:(NSDictionary *)productJSON country:(RICountryConfiguration*)country {
    RIProduct* newProduct = [[RIProduct alloc] init];
    
    NSDictionary *dataDic = [productJSON copy];
    
    if (dataDic) {
        if ([dataDic objectForKey:@"sku"]) {
            newProduct.sku = [dataDic objectForKey:@"sku"];
        }
        
        if ([dataDic objectForKey:@"title"]) {
            newProduct.name = [dataDic objectForKey:@"title"];
        } else if ([dataDic objectForKey:@"name"]) {
            newProduct.name = [dataDic objectForKey:@"name"];
        }
        if ([dataDic objectForKey:@"target"]) {
            newProduct.targetString = [dataDic objectForKey:@"target"];
        }
        if ([dataDic objectForKey:@"click_request"]) {
            newProduct.richRelevanceParameter = [dataDic objectForKey:@"click_request"];
        }
        if ([dataDic objectForKey:@"description"]) {
            newProduct.descriptionString = [dataDic objectForKey:@"description"];
        }
        if ([dataDic objectForKey:@"category_name"]) {
            newProduct.categoryName = [dataDic objectForKey:@"category_name"];
        }
        if ([dataDic objectForKey:@"category_url_key"]) {
            newProduct.categoryUrlKey = [dataDic objectForKey:@"category_url_key"];
        }
        
        if([dataDic objectForKey:@"bucket_active"]){
            newProduct.bucketActive = [NSNumber numberWithBool:[[dataDic objectForKey:@"bucket_active"] boolValue]];
        }
        
        if([dataDic objectForKey:@"summary"]){
            NSDictionary *summary = [dataDic objectForKey:@"summary"];
            if(VALID_NOTEMPTY(summary, NSDictionary)){
                if([summary objectForKey:@"short_description"]){
                    newProduct.shortSummary = [summary objectForKey:@"short_description"];
                }
                
                if([summary objectForKey:@"description"]){
                    newProduct.summary = [summary objectForKey:@"description"];
                }
                
            }
        }
        
        if ([dataDic objectForKey:@"is_new"]) {
            newProduct.isNew = [NSNumber numberWithBool:[[dataDic objectForKey:@"is_new"] boolValue]];
        }
        
        if ([dataDic objectForKey:@"shop_first"]) {
            newProduct.shopFirst = [NSNumber numberWithBool:[[dataDic objectForKey:@"shop_first"] boolValue]];
            if ([dataDic objectForKey:@"shop_first_overlay"]) {
                newProduct.shopFirstOverlayText = [dataDic objectForKey:@"shop_first_overlay"];
            }
        } else {
            newProduct.shopFirst = false;
        }
        
        if ([dataDic objectForKey:@"max_price"]) {
            newProduct.maxPrice = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"max_price"] longLongValue]];
            newProduct.maxPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxPrice country:country];
        }
        
        if ([dataDic objectForKey:@"max_price_converted"]) {
            newProduct.maxPriceEuroConverted = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"max_price_converted"] longLongValue]];
        }
        
        if ([dataDic objectForKey:@"price"]) {
            newProduct.price = [NSNumber numberWithLong:[[dataDic objectForKey:@"price"] longValue]];
            newProduct.priceFormatted = [RICountryConfiguration formatPrice:newProduct.price country:country];
        }
        
        if ([dataDic objectForKey:@"price_converted"]) {
            newProduct.priceEuroConverted = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"price_converted"] longLongValue]];
        }
        
        if ([dataDic objectForKey:@"price_range"]) {
            newProduct.priceRange = [[dataDic objectForKey:@"price_range"] numbersToPersian];
        }
        
        if ([dataDic objectForKey:@"special_price"]) {
            newProduct.specialPrice = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"special_price"] longLongValue]];
            newProduct.specialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.specialPrice country:country];
        }
        
        if ([dataDic objectForKey:@"special_price_converted"]) {
            newProduct.specialPriceEuroConverted = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"special_price_converted"] longLongValue]];
        }
        
        if ([dataDic objectForKey:@"max_special_price"]) {
            newProduct.maxSpecialPrice = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"max_special_price"] longLongValue]];
            newProduct.maxSpecialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxSpecialPrice country:country];
        }
        
        if ([dataDic objectForKey:@"max_special_price_converted"]) {
            newProduct.maxSpecialPriceEuroConverted = [NSNumber numberWithLongLong:[[dataDic objectForKey:@"max_special_price_converted"] longLongValue]];
        }
        
        if ([dataDic objectForKey:@"max_saving_percentage"]) {
            newProduct.maxSavingPercentage = [NSString stringWithFormat:@"%@", [dataDic objectForKey:@"max_saving_percentage"]];
        }
        
        if ([dataDic objectForKey:@"free_shipping_possible"]) {
            newProduct.freeShippingPossible = [[dataDic objectForKey:@"free_shipping_possible"] boolValue];
        } else {
            newProduct.freeShippingPossible = NO;
        }
        
        if ([dataDic objectForKey:@"rating_reviews_summary"]) {
            NSDictionary *ratingsDic = [dataDic objectForKey:@"rating_reviews_summary"];
            if (VALID_NOTEMPTY(ratingsDic, NSDictionary)) {
                if (VALID_NOTEMPTY([ratingsDic objectForKey:@"average"], NSNumber)) {
                    newProduct.avr = [ratingsDic objectForKey:@"average"];
                }
                if (VALID_NOTEMPTY([ratingsDic objectForKey:@"ratings_total"], NSNumber)) {
                    newProduct.sum = [ratingsDic objectForKey:@"ratings_total"];
                }
                if (VALID_NOTEMPTY([ratingsDic objectForKey:@"reviews_total"], NSNumber)) {
                    newProduct.reviewsTotal = [ratingsDic objectForKey:@"reviews_total"];
                }
            }
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
            newProduct.categoryIds = [[dataDic objectForKey:@"categories"] componentsSeparatedByString:@"|"];
        }
        
        if ([dataDic objectForKey:@"size_guide"]) {
            NSString* sizeGuideUrl = [dataDic objectForKey:@"size_guide"];
            if (VALID_NOTEMPTY(sizeGuideUrl, NSString)) {
                newProduct.sizeGuideUrl = sizeGuideUrl;
            }
        }
        
        __block NSString* variationKey = @"";
        NSDictionary* uniques = [dataDic objectForKey:@"uniques"];
        if (VALID_NOTEMPTY(uniques, NSDictionary)) {
            NSDictionary *attributes = [uniques objectForKey:@"attributes"];
            if (VALID_NOTEMPTY(attributes, NSDictionary)) {
                [attributes enumerateKeysAndObjectsUsingBlock:^(id key, NSString* obj, BOOL *stop) {
                    if (VALID_NOTEMPTY(obj, NSString)) {
                        variationKey = obj;
                    }
                }];
            }
        }
        
        if ([dataDic objectForKey:@"share_url"]) {
            if (VALID_NOTEMPTY([dataDic objectForKey:@"share_url"], NSString)) {
                newProduct.shareUrl = [dataDic objectForKey:@"share_url"];
            }
        }
        
        if ([dataDic objectForKey:@"simples"]) {
            NSMutableArray* productSimplesMutableArray = [NSMutableArray new];
            NSArray* productSimplesJSON = [dataDic objectForKey:@"simples"];
            for (NSDictionary* simpleJSON in productSimplesJSON) {
                if (VALID_NOTEMPTY(simpleJSON, NSDictionary)) {
                    
                    RIProductSimple* productSimple = [RIProductSimple parseProductSimple:simpleJSON country:country variationKey:variationKey];
                    [productSimplesMutableArray addObject:productSimple];
                }
            }
            newProduct.productSimples = [productSimplesMutableArray copy];
        }
        
        if([dataDic objectForKey:@"specifications"]){
            NSArray* specificationsJSON = [dataDic objectForKey:@"specifications"];
            
            NSMutableOrderedSet* newSpecifications = [NSMutableOrderedSet new];
            for (NSDictionary *specifJSON in specificationsJSON){
                if(VALID_NOTEMPTY(specifJSON, NSDictionary)){
                    
                    RISpecification *newSpecification = [RISpecification parseSpecification:specifJSON];
                    [newSpecifications addObject:newSpecification];
                }
            }
            newProduct.specifications = [newSpecifications copy];
        }
        
        if ([dataDic objectForKey:@"variations"]) {
            NSDictionary* variationsJSON = [dataDic objectForKey:@"variations"];
            if (VALID_NOTEMPTY(variationsJSON, NSArray)) {
                NSMutableArray* variationsMutableArray = [NSMutableArray new];
                for (NSDictionary *varDictionary in variationsJSON) {
                    RIVariation* variation = [RIVariation parseVariation:varDictionary];
                    [variationsMutableArray addObject:variation];
                }
                newProduct.variations = [variationsMutableArray copy];
            }
        }
        
        NSMutableArray* imagesMutableArray = [NSMutableArray new];
        if ([dataDic objectForKey:@"image_list"]) {
            NSArray* imageListJSON = [dataDic objectForKey:@"image_list"];
            
            for (NSDictionary* imageJSON in imageListJSON) {
                if (VALID_NOTEMPTY(imageJSON, NSDictionary)) {
                    
                    RIImage* image = [RIImage parseImage:imageJSON];
                    [imagesMutableArray addObject:image];
                }
            }
        } else if ([dataDic objectForKey:@"image"]) {
            //a related item only has one image url, inside the data dictionary
            NSDictionary* imageDic = [NSDictionary dictionaryWithObject:[dataDic objectForKey:@"image"] forKey:@"image"];
            RIImage* image = [RIImage parseImage:imageDic];
            [imagesMutableArray addObject:image];
        } else if ([dataDic objectForKey:@"image_url"]) {
            NSMutableDictionary* imageDict = [NSMutableDictionary new];
            [imageDict setObject:[dataDic objectForKey:@"image_url"] forKey:@"url"];
            RIImage* image = [RIImage parseImage:imageDict];
            [imagesMutableArray addObject:image];
        }
        newProduct.images = [imagesMutableArray copy];
        
        if ([dataDic objectForKey:@"seller_entity"]) {
            NSDictionary* sellerJSON = [dataDic objectForKey:@"seller_entity"];
            if (VALID_NOTEMPTY(sellerJSON, NSDictionary)) {
                newProduct.seller = [Seller parseToSellerWithDic:sellerJSON];
            }
        }
        
        if ([dataDic objectForKey:@"is_wishlist"] && [[dataDic objectForKey:@"is_wishlist"] integerValue] == 1) {
            newProduct.favoriteAddDate = [NSDate new];
        }else{
            newProduct.favoriteAddDate = nil;
        }
        
        if ([dataDic objectForKey:@"offers"]) {
            NSDictionary* offersJSON = [dataDic objectForKey:@"offers"];
            if (offersJSON) {
                if ([offersJSON objectForKey:@"min_price"]) {
                    newProduct.offersMinPrice = [NSNumber numberWithLongLong:[[offersJSON objectForKey:@"min_price"] longLongValue]];
                    newProduct.offersMinPriceFormatted = [RICountryConfiguration formatPrice:newProduct.offersMinPrice country:country];
                }
                if ([offersJSON objectForKey:@"min_price_converted"]) {
                    newProduct.offersMinPriceEuroConverted = [NSNumber numberWithLongLong:[[offersJSON objectForKey:@"min_price_converted"] longLongValue]];
                }
                if ([offersJSON objectForKey:@"total"]) {
                    newProduct.offersTotal = [NSNumber numberWithInteger:[[offersJSON objectForKey:@"total"] integerValue]];
                }
            }
        }
        
        if (VALID_NOTEMPTY([dataDic objectForKey:@"vertical"], NSString)) {
            NSString *vertical = [dataDic objectForKey:@"vertical"];
            if ([vertical isEqualToString:@"fashion"]) {
                newProduct.fashion = YES;
            }
            newProduct.vertical = vertical;
        }
        
        if ([dataDic objectForKey:@"recommended_products"] || [dataDic objectForKey:@"related_products"]) {
            
            NSArray* relatedProductsArray = Nil;
            
            if ([dataDic objectForKey:@"recommended_products"]) {
                NSDictionary* recommended = [dataDic objectForKey:@"recommended_products"];
                if ([recommended objectForKey:@"has_data"]) {
                    if ([recommended objectForKey:@"title"]) {
                        newProduct.richRelevanceTitle = [recommended objectForKey:@"title"];
                    }
                    relatedProductsArray = [recommended objectForKey:@"data"];
                }
            } else if ([dataDic objectForKey:@"related_products"]) {
                relatedProductsArray = [dataDic objectForKey:@"related_products"];
            }
            
            newProduct.relatedProducts = [RIProduct parseRichRelevanceProducts:relatedProductsArray country:country];
        }
        
        if ([dataDic objectForKey:@"pre_order"]) {
            newProduct.preOrder = YES;
        }
        
        if (VALID_NOTEMPTY([dataDic objectForKey:@"brand"], NSString)) {
            newProduct.brand = [dataDic objectForKey:@"brand"];
        }
        
        if ([dataDic objectForKey:@"brand_entity"]) {
            NSDictionary *brandEntityDictionary = [dataDic objectForKey:@"brand_entity"];
            if (VALID_NOTEMPTY(brandEntityDictionary, NSDictionary)) {
                if ([brandEntityDictionary objectForKey:@"id"]) {
                    newProduct.brandId = [brandEntityDictionary objectForKey:@"id"];
                }
                
                if ([brandEntityDictionary objectForKey:@"image"]) {
                    newProduct.brandImage = [brandEntityDictionary objectForKey:@"image"];
                }
                
                if ([brandEntityDictionary objectForKey:@"name"]) {
                    newProduct.brand = [brandEntityDictionary objectForKey:@"name"];
                }
                
                if ([brandEntityDictionary objectForKey:@"target"]) {
                    newProduct.brandTarget = [brandEntityDictionary objectForKey:@"target"];
                }
                
                if ([brandEntityDictionary objectForKey:@"url_key"]) {
                    newProduct.brandUrlKey = [brandEntityDictionary objectForKey:@"url_key"];
                }
            }
        }
        
        if ([dataDic objectForKey:@"category_entity"]) {
            NSDictionary *categoryEntityDictionary = [dataDic objectForKey:@"category_entity"];
            
            if ([categoryEntityDictionary objectForKey:@"name"] && newProduct.categoryName == nil) {
                newProduct.categoryName = [categoryEntityDictionary objectForKey:@"name"];
            }
            
            if ([categoryEntityDictionary objectForKey:@"url_key"] && newProduct.categoryUrlKey == nil) {
                newProduct.categoryUrlKey = [categoryEntityDictionary objectForKey:@"url_key"];
            }
        }
    }
    
    return newProduct;
}

+ (NSSet *)parseRichRelevanceProducts:(NSArray *)jsonObject country:(RICountryConfiguration*)country
{
    if (VALID_NOTEMPTY(jsonObject, NSArray)) {
        NSMutableSet *newRelatedProducts = [NSMutableSet new];
        for (NSDictionary* relatedProductJSON in jsonObject) {
            if (VALID_NOTEMPTY(relatedProductJSON, NSDictionary)) {
                RIProduct* relatedProduct = [RIProduct parseProduct:relatedProductJSON country:country];
                [newRelatedProducts addObject:relatedProduct];
            }
        }
        return [newRelatedProducts copy];
    }
    return nil;
}
    
#pragma mark - Favorites

+ (void)getFavoriteProductsWithSuccessBlock:(void (^)(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages))successBlock
                            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    [RIProduct getFavoriteProductsForPage:-1 maxItems:-1 SuccessBlock:successBlock andFailureBlock:failureBlock];
}

+ (void)getFavoriteProductsForPage:(NSInteger)page
                          maxItems:(NSInteger)maxItems
                      SuccessBlock:(void (^)(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages))successBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_WISHLIST];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (page != -1) {
        [parameters setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    }
    if (maxItems != -1) {
        [parameters setObject:[NSString stringWithFormat:@"%ld",(long)maxItems] forKey:@"per_page"];
    }
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                     parameters:parameters
                                                     httpMethod:HttpVerbPOST
                                                      cacheType:RIURLCacheNoCache
                                                      cacheTime:RIURLCacheDefaultTime
                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                       if (VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary)) {
                                                           NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                           NSInteger currentPage = 1;
                                                           NSInteger totalPages = 1;
                                                           if (VALID_NOTEMPTY([metadata objectForKey:@"pagination"], NSDictionary)) {
                                                               
                                                               if (VALID_NOTEMPTY([[metadata objectForKey:@"pagination"] objectForKey:@"current_page"], NSNumber)) {
                                                                   currentPage = [(NSNumber *)[[metadata objectForKey:@"pagination"] objectForKey:@"current_page"] integerValue];
                                                               }
                                                               if (VALID_NOTEMPTY([[metadata objectForKey:@"pagination"] objectForKey:@"total_pages"], NSNumber)) {
                                                                   totalPages = [(NSNumber *)[[metadata objectForKey:@"pagination"] objectForKey:@"total_pages"] integerValue];
                                                               }
                                                           }
                                                           if (VALID_NOTEMPTY([metadata objectForKey:@"products"], NSArray)) {
                                                               NSArray *productsArray = [metadata objectForKey:@"products"];
                                                               NSMutableArray *favoriteProducts = [NSMutableArray new];
                                                               for (NSDictionary *productDict in productsArray) {
                                                                   if (VALID_NOTEMPTY(productDict, NSDictionary)) {
                                                                       RIProduct *product = [RIProduct parseProduct:productDict country:[RICountryConfiguration getCurrentConfiguration]];
                                                                       if (VALID_NOTEMPTY(product, RIProduct)) {
                                                                           [favoriteProducts addObject:product];
                                                                       }
                                                                   }
                                                               }
                                                               if (VALID(favoriteProducts, NSArray) && successBlock) {
                                                                   successBlock(favoriteProducts, currentPage, totalPages);
                                                                   return;
                                                               }
                                                           } else {
                                                               if (successBlock) {
                                                                   successBlock([[NSArray alloc] init], 1, 0);
                                                                   return;
                                                               }
                                                           }
                                                       }
                                                       if (failureBlock) {
                                                           failureBlock(RIApiResponseUnknownError, nil);
                                                       }
                                                       
                                                   } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                       if (errorObject) {
                                                           failureBlock(apiResponse, [NSArray arrayWithObject:[errorObject localizedDescription]]);
                                                       }else{
                                                           failureBlock(apiResponse, nil);
                                                       }
                                                   }];
}

+ (void)addToFavorites:(RIProduct*)product
          successBlock:(void (^)(RIApiResponse apiResponse, NSArray *success))successBlock
       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock {
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_TO_WISHLIST];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:product.sku forKey:@"sku"];
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                     parameters:parameters
                                                     httpMethod:HttpVerbPOST
                                                      cacheType:RIURLCacheNoCache
                                                      cacheTime:RIURLCacheDefaultTime
                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                       if (VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary)) {
                                                           NSDictionary *messages = [jsonObject objectForKey:@"messages"];
                                                           if (VALID_NOTEMPTY([messages objectForKey:@"success"], NSArray)) {
                                                               NSArray *success = [messages objectForKey:@"success"];
                                                               if (VALID_NOTEMPTY([success valueForKey:@"message"], NSArray)) {
                                                                   NSArray *successMessage = [success valueForKey:@"message"];
                                                                   successBlock(apiResponse, successMessage);
                                                                   return;
                                                               }
                                                               
                                                           }
                                                       }
                                                       successBlock(apiResponse, nil);
                                                       
                                                   } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                       if (errorObject) {
                                                           failureBlock(apiResponse, [NSArray arrayWithObject:[errorObject localizedDescription]]);
                                                       }else{
                                                           if (VALID_NOTEMPTY([errorJsonObject objectForKey:@"messages"], NSDictionary)) {
                                                               NSDictionary *messages = [errorJsonObject objectForKey:@"messages"];
                                                               if (VALID_NOTEMPTY([messages objectForKey:@"error"], NSArray)) {
                                                                   NSArray *error = [messages objectForKey:@"error"];
                                                                   if (VALID_NOTEMPTY([error valueForKey:@"message"], NSArray)) {
                                                                       NSArray *errorMessage = [error valueForKey:@"message"];
                                                                       failureBlock(apiResponse, errorMessage);
                                                                       return;
                                                                   }
                                                                   
                                                               }
                                                           }
                                                           failureBlock(apiResponse, nil);
                                                       }
                                                   }];
}

//+ (void)removeFromFavorites:(RIProduct*)product
//               successBlock:(void (^)(RIApiResponse apiResponse, NSArray *success))successBlock
//            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
//{
//    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_FOM_WISHLIST];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObject:product.sku forKey:@"sku"];
//    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
//                                                     parameters:parameters httpMethod:HttpVerbDELETE
//                                                      cacheType:RIURLCacheNoCache
//                                                      cacheTime:RIURLCacheDefaultTime
//                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
//                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
//                                                       if (VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary)) {
//                                                           NSDictionary *messages = [jsonObject objectForKey:@"messages"];
//                                                           if (VALID_NOTEMPTY([messages objectForKey:@"success"], NSArray)) {
//                                                               NSArray *success = [messages objectForKey:@"success"];
//                                                               if (VALID_NOTEMPTY([success valueForKey:@"message"], NSArray)) {
//                                                                   NSArray *successMessage = [success valueForKey:@"message"];
//                                                                   successBlock(apiResponse, successMessage);
//                                                                   return;
//                                                               }
//                                                               
//                                                           }
//                                                       }
//                                                       successBlock(apiResponse, nil);
//                                                       
//                                                   } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
//                                                       if (errorObject) {
//                                                           failureBlock(apiResponse, [NSArray arrayWithObject:[errorObject localizedDescription]]);
//                                                       }else{
//                                                           if (VALID_NOTEMPTY([errorJsonObject objectForKey:@"messages"], NSDictionary)) {
//                                                               NSDictionary *messages = [errorJsonObject objectForKey:@"messages"];
//                                                               if (VALID_NOTEMPTY([messages objectForKey:@"error"], NSArray)) {
//                                                                   NSArray *error = [messages objectForKey:@"error"];
//                                                                   if (VALID_NOTEMPTY([error valueForKey:@"message"], NSArray)) {
//                                                                       NSArray *errorMessage = [error valueForKey:@"message"];
//                                                                       failureBlock(apiResponse, errorMessage);
//                                                                       return;
//                                                                   }
//                                                                   
//                                                               }
//                                                           }
//                                                           failureBlock(apiResponse, nil);
//                                                       }
//                                                   }];
//}

+ (NSDate*)productIsFavoriteInDatabase:(RIProduct*)product
{
    NSArray* productsWithVariable = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIProduct class]) withPropertyName:@"sku" andPropertyValue:product.sku];
    
    for (RIProduct* possibleProduct in productsWithVariable) {
        if (VALID_NOTEMPTY(possibleProduct.favoriteAddDate, NSDate)) {
            return possibleProduct.favoriteAddDate;
        }
    }
    
    return nil;
}


+ (NSString *)getBundleWithSku:(NSString *)sku
                  successBlock:(void (^)(RIBundle* bundle))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_BUNDLE, sku];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      successBlock([RIBundle parseRIBundle:metadata country:configuration]);
                                                                  } else {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (NSString*)getTopBrand:(RIProduct *)seenProduct
{
    [RIProduct seenProduct:seenProduct];
    
    NSMutableDictionary *brandsDictionary = [NSMutableDictionary new];
    NSString *topBrand = nil;
    NSArray* databaseBrands = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIRecentlyViewedProductSku class]) withPropertyName:@"brand"];
    for(RIRecentlyViewedProductSku *recentlyViewedProductSku in databaseBrands)
    {
        if(ISEMPTY(topBrand))
        {
            topBrand = recentlyViewedProductSku.brand;
            [brandsDictionary setObject:recentlyViewedProductSku.numberOfTimesSeen forKey:recentlyViewedProductSku.brand];
        }
        else
        {
            if (VALID_NOTEMPTY([brandsDictionary objectForKey:recentlyViewedProductSku.brand], NSNumber)) {
                NSNumber *sum = [NSNumber numberWithLongLong:[[brandsDictionary objectForKey:recentlyViewedProductSku.brand] longLongValue] + [recentlyViewedProductSku.numberOfTimesSeen longValue]];
                [brandsDictionary setObject:sum forKey:recentlyViewedProductSku.brand];
            }else{
                [brandsDictionary setObject:recentlyViewedProductSku.numberOfTimesSeen forKey:recentlyViewedProductSku.brand];
            }
            if([brandsDictionary[topBrand] longLongValue] < [brandsDictionary[recentlyViewedProductSku.brand] longLongValue])
            {
                topBrand = recentlyViewedProductSku.brand;
            }
        }
    }
    
    return topBrand;
}

+ (void)seenProduct:(RIProduct *)seenProduct
{
    if(VALID_NOTEMPTY(seenProduct, RIProduct))
    {
        NSArray* databaseProds = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIRecentlyViewedProductSku class]) withPropertyName:@"productSku" andPropertyValue:seenProduct.sku];
        RIRecentlyViewedProductSku *recentlyViewedProductSku = [databaseProds firstObject];
        
        if (NO == VALID_NOTEMPTY(recentlyViewedProductSku.numberOfTimesSeen, NSNumber)) {
            recentlyViewedProductSku.numberOfTimesSeen = [NSNumber numberWithInt:0];
        }
        recentlyViewedProductSku.numberOfTimesSeen = [NSNumber numberWithInt:([recentlyViewedProductSku.numberOfTimesSeen intValue] + 1)];
    }
}

- (BOOL)hasStock {
    for (RIProductSimple *simple in self.productSimples) {
        if (![simple.quantity isEqualToString:@"0"]) {
            return YES;
        }
    }
    return NO;
}

@end
