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
#import "RISeller.h"
#import "RIBanner.h"
#import "RISpecification.h"
#import "RITarget.h"
#import "RISearchSuggestion.h"

@implementation RIBundle

+ (RIBundle *)parseRIBundle:(NSDictionary *)bundleJSON country:(RICountryConfiguration*)country
{
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
@synthesize brand;
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

+ (NSString *)getCompleteProductWithSku:(NSString*)sku
                           successBlock:(void (^)(id product))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSString *finalTargetString = [NSString stringWithFormat:@"product_detail::%@",sku];
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
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSString *richParam = [NSMutableString new];
    if (VALID_NOTEMPTY(parameter, NSDictionary) && [parameter objectForKey:@"rich_parameter"]) {
        richParam = [RITarget getURLStringforTargetString:[parameter objectForKey:@"rich_parameter"]];
    }
    
    NSString * url =  [RITarget getURLStringforTargetString:targetString];
    url = [NSString stringWithFormat:@"%@/%@",url,richParam];
    url = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      if ([metadata objectForKey:@"recommended_products"]) {
                                                                          [self getRichRelevanceRecommendation:metadata successBlock:successBlock andFailureBlock:failureBlock];
                                                                      } else {
                                                                          RIProduct* newProduct = [RIProduct parseProduct:metadata country:configuration];
                                                                          if (VALID_NOTEMPTY(newProduct, RIProduct) && VALID_NOTEMPTY(newProduct.sku, NSString)) {
                                                                              successBlock(newProduct);
                                                                          } else {
                                                                              failureBlock(apiResponse, nil);
                                                                          }
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

+ (void)getRichRelevanceRecommendation:(NSDictionary*)metadata
                          successBlock:(void (^)(id productWithRecommendations))successBlock
                       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
{
    NSDictionary *recommendedProducts = [metadata objectForKey:@"recommended_products"];
    NSString *recommendedProductsTarget = [RITarget getURLStringforTargetString:[recommendedProducts objectForKey:@"target"]];
    NSURL *url = [NSURL URLWithString:recommendedProductsTarget];
    
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                     parameters:nil
                                                     httpMethod:HttpResponsePost
                                                      cacheType:RIURLCacheNoCache
                                                      cacheTime:RIURLCacheDefaultTime
                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary* jsonObject) {
                                                       [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                           NSDictionary *recommendedMetadata = [jsonObject objectForKey:@"metadata"];
                                                           
                                                           if (VALID_NOTEMPTY(recommendedMetadata, NSDictionary)) {
                                                               NSMutableDictionary *mutableMetadata =  [metadata mutableCopy];
                                                               
                                                               [mutableMetadata setObject:recommendedMetadata forKey:@"recommended_products"];
                                                               
                                                               NSDictionary *metadata = [mutableMetadata copy];
                                                               
                                                               RIProduct* newProduct = [RIProduct parseProduct:metadata country:configuration];
                                                               if (VALID_NOTEMPTY(newProduct, RIProduct) && VALID_NOTEMPTY(newProduct.sku, NSString)) {
                                                                   successBlock(newProduct);
                                                               } else {
                                                                   failureBlock(apiResponse, nil);
                                                               }
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

+ (NSString *)getProductsWithCatalogUrl:(NSString*)url
                          sortingMethod:(RICatalogSorting)sortingMethod
                                   page:(NSInteger)page
                               maxItems:(NSInteger)maxItems
                                filters:(NSArray*)filters
                             filterPush:(NSString*)filterPush
                           successBlock:(void (^)(RICatalog *catalog))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error, RIUndefinedSearchTerm *undefSearchTerm))failureBlock
{
    NSString* fullUrl = @"";
    NSString *filtersString = @"";

    if(VALID_NOTEMPTY(filterPush, NSString))
    {
        filtersString = filterPush;
    }
    else
    {        
        filtersString = [RIFilter urlWithFiltersArray:filters];
    }

    //sometimes the url of the product already has ? in it. yeah...
    NSString *sortingString = [RIProduct urlComponentForSortingMethod:sortingMethod];
    if (VALID_NOTEMPTY(sortingString, NSString)) {
        sortingString = [NSString stringWithFormat:@"/%@", sortingString];
    }
    
    if(VALID_NOTEMPTY(filtersString, NSString))
    {
        fullUrl = [NSString stringWithFormat:@"%@/page/%ld/maxitems/%ld%@%@", url, (long)page, (long)maxItems, sortingString, [NSString stringWithFormat:@"/%@" ,filtersString]];
    }
    else
    {
        fullUrl = [NSString stringWithFormat:@"%@/page/%ld/maxitems/%ld%@", url, (long)page, (long)maxItems, sortingString];
    }
    return [RIProduct getProductsWithFullUrl:fullUrl
                                successBlock:successBlock
                             andFailureBlock:failureBlock];
}

+ (NSString *)getProductsWithFullUrl:(NSString*)url
                        successBlock:(void (^)(RICatalog *catalog))successBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error,  RIUndefinedSearchTerm *undefSearchTerm))failureBlock
{
    url = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *finalURL = [NSURL URLWithString:url];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:finalURL
                                                            parameters:nil
                                                            httpMethod:HttpResponseGet
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      RICatalog *catalog = [RICatalog parseCatalog:metadata forCountryConfiguration:configuration];
                                                                      
                                                                      if (VALID_NOTEMPTY(catalog.products, NSArray)) {
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              successBlock(catalog);
                                                                          });
                                                                      }else
                                                                      {
                                                                          failureBlock(RIApiResponseAPIError, nil, nil);
                                                                      }
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(RIApiResponseAPIError, nil, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  if ([errorJsonObject objectForKey:@"metadata"])
                                                                  {
                                                                      failureBlock(apiResponse, nil, [RISearchSuggestion parseUndefinedSearchTerm:[errorJsonObject objectForKey:@"metadata"]]);
                                                                  }
                                                                  else
                                                                  {
                                                                      if(NOTEMPTY(errorJsonObject))
                                                                      {
                                                                          failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject], nil);
                                                                      }
                                                                      else if(NOTEMPTY(errorObject))
                                                                      {
                                                                          NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                          failureBlock(apiResponse, errorArray, nil);
                                                                      }
                                                                      else
                                                                      {
                                                                          failureBlock(apiResponse, nil, nil);
                                                                      }
                                                                  }
                                                              });
                                                          }];
}

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
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      NSArray* valid = [metadata objectForKey:@"valid"];
                                                                      
                                                                      if (VALID_NOTEMPTY(valid, NSArray)) {
                                                                          
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
                                                                      }
                                                                      else
                                                                      {
                                                                          failureBlock(RIApiResponseAPIError, nil);
                                                                      }
                                                                  }
                                                                  else
                                                                  {
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

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (RIProduct *)parseProduct:(NSDictionary *)productJSON country:(RICountryConfiguration*)country
{
    RIProduct* newProduct = [[RIProduct alloc] init];
    
    NSDictionary *dataDic = [productJSON copy];
    
    if (VALID_NOTEMPTY(dataDic, NSDictionary)) {
        
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
        if ([dataDic objectForKey:@"brand"]) {
            newProduct.brand = [dataDic objectForKey:@"brand"];
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
            newProduct.maxPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_price"] floatValue]];
            newProduct.maxPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxPrice country:country];
        }
        
        if ([dataDic objectForKey:@"max_price_converted"]) {
            newProduct.maxPriceEuroConverted = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_price_converted"] floatValue]];
        }
        
        if ([dataDic objectForKey:@"price"]) {
            newProduct.price = [NSNumber numberWithFloat:[[dataDic objectForKey:@"price"] floatValue]];
            newProduct.priceFormatted = [RICountryConfiguration formatPrice:newProduct.price country:country];
        }

        if ([dataDic objectForKey:@"price_converted"]) {
            newProduct.priceEuroConverted = [NSNumber numberWithFloat:[[dataDic objectForKey:@"price_converted"] floatValue]];
        }
        
        if ([dataDic objectForKey:@"price_range"]) {
            newProduct.priceRange = [dataDic objectForKey:@"price_range"];
        }

        if ([dataDic objectForKey:@"special_price"]) {
            newProduct.specialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"special_price"] floatValue]];
            newProduct.specialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.specialPrice country:country];
        }
        
        if ([dataDic objectForKey:@"special_price_converted"]) {
            newProduct.specialPriceEuroConverted = [NSNumber numberWithFloat:[[dataDic objectForKey:@"special_price_converted"] floatValue]];
        }
        
        if ([dataDic objectForKey:@"max_special_price"]) {
            newProduct.maxSpecialPrice = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_special_price"] floatValue]];
            newProduct.maxSpecialPriceFormatted = [RICountryConfiguration formatPrice:newProduct.maxSpecialPrice country:country];
        }
        
        if ([dataDic objectForKey:@"max_special_price_converted"]) {
            newProduct.maxSpecialPriceEuroConverted = [NSNumber numberWithFloat:[[dataDic objectForKey:@"max_special_price_converted"] floatValue]];
        }
        
        if ([dataDic objectForKey:@"max_saving_percentage"]) {
            newProduct.maxSavingPercentage = [NSString stringWithFormat:@"%@", [dataDic objectForKey:@"max_saving_percentage"]];
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

            NSMutableSet* newSpecifications = [NSMutableSet new];
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
                
                RISeller* seller = [RISeller parseSeller:sellerJSON];
                newProduct.seller = seller;
            }
        }
        
        if (VALID_NOTEMPTY([dataDic objectForKey:@"is_wishlist"], NSNumber) && [[dataDic objectForKey:@"is_wishlist"] integerValue] ==1) {
            newProduct.favoriteAddDate = [NSDate new];
        }else{
            newProduct.favoriteAddDate = nil;
        }
        
        if ([dataDic objectForKey:@"offers"]) {
            NSDictionary* offersJSON = [dataDic objectForKey:@"offers"];
            if (VALID_NOTEMPTY(offersJSON, NSDictionary)) {
                if ([offersJSON objectForKey:@"min_price"]) {
                    newProduct.offersMinPrice = [NSNumber numberWithFloat:[[offersJSON objectForKey:@"min_price"] floatValue]];
                    newProduct.offersMinPriceFormatted = [RICountryConfiguration formatPrice:newProduct.offersMinPrice country:country];
                }
                if ([offersJSON objectForKey:@"min_price_converted"]) {
                    newProduct.offersMinPriceEuroConverted = [NSNumber numberWithFloat:[[offersJSON objectForKey:@"min_price_converted"] floatValue]];
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
            
            if (VALID_NOTEMPTY(relatedProductsArray, NSArray)) {
                
                NSMutableSet *newRelatedProducts = [NSMutableSet new];
                for (NSDictionary* relatedProductJSON in relatedProductsArray) {
                    if (VALID_NOTEMPTY(relatedProductJSON, NSDictionary)) {
                        RIProduct* relatedProduct = [RIProduct parseProduct:relatedProductJSON country:country];
                        [newRelatedProducts addObject:relatedProduct];
                    }
                }
                newProduct.relatedProducts = [newRelatedProducts copy];
            }
        }
        
        if ([dataDic objectForKey:@"pre_order"]) {
            newProduct.preOrder = YES;
        }
    }
    
    return newProduct;
}

+ (NSString*)urlComponentForSortingMethod:(RICatalogSorting)sortingMethod
{
    NSString* urlComponent = @"";
    
    switch (sortingMethod) {
        case RICatalogSortingRating:
            urlComponent = @"sort/rating/dir/desc";
            break;
        case RICatalogSortingNewest:
            urlComponent = @"sort/newest/dir/desc";
            break;
        case RICatalogSortingPriceUp:
            urlComponent = @"sort/price/dir/asc";
            break;
        case RICatalogSortingPriceDown:
            urlComponent = @"sort/price/dir/desc";
            break;
        case RICatalogSortingName:
            urlComponent = @"sort/name/dir/asc";
            break;
        case RICatalogSortingBrand:
            urlComponent = @"sort/brand/dir/asc";
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
            sortingName = @"Popularity";
            break;
    }
    
    return sortingName;
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
                                                     httpMethod:HttpResponsePost
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
                                                                   NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"favoriteAddDate" ascending:NO];
                                                                   NSArray *sorted = [favoriteProducts sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateDescriptor]];
                                                                   successBlock(sorted, currentPage, totalPages);
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
       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_TO_WISHLIST];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:product.sku forKey:@"sku"];
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                     parameters:parameters
                                                     httpMethod:HttpResponsePost
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

+ (void)removeFromFavorites:(RIProduct*)product
               successBlock:(void (^)(RIApiResponse apiResponse, NSArray *success))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_FOM_WISHLIST];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:product.sku forKey:@"sku"];
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                     parameters:parameters httpMethod:HttpResponseDelete
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
                                                            httpMethod:HttpResponsePost
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
                NSNumber *sum = [NSNumber numberWithLong:[[brandsDictionary objectForKey:recentlyViewedProductSku.brand] longValue] + [recentlyViewedProductSku.numberOfTimesSeen longValue]];
                [brandsDictionary setObject:sum forKey:recentlyViewedProductSku.brand];
            }else{
                [brandsDictionary setObject:recentlyViewedProductSku.numberOfTimesSeen forKey:recentlyViewedProductSku.brand];
            }
            if([brandsDictionary[topBrand] longValue] < [brandsDictionary[recentlyViewedProductSku.brand] longValue])
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

@end
