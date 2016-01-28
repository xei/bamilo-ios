//
//  RIProductOffer.m
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIProductOffer.h"
#import "RISeller.h"
#import "RIProductSimple.h"
#import "RITarget.h"

@implementation RIProductOffer

+ (NSString*)getProductOffersForProductWithSku:(NSString*)sku
                                  successBlock:(void (^)(NSArray *productOffers))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@%@%@/%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_PRODUCT_DETAIL, sku, RI_API_PRODUCT_OFFERS];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                            httpMethod:HttpResponseGet
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      NSDictionary* offersJSON = [metadata objectForKey:@"offers"];
                                                                      
                                                                      if (VALID_NOTEMPTY(offersJSON, NSDictionary)) {
                                                                          
                                                                          NSArray* offers = [RIProductOffer parseProductOffers:offersJSON country:configuration];
                                                                          successBlock(offers);
                                                                      }
                                                                  }
                                                                  else {
                                                                      
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

#pragma mark - Parsing

+ (NSArray*)parseProductOffers:(NSDictionary*)productOffersJSON
                       country:(RICountryConfiguration*)country;
{
    NSMutableArray* productOffers = [NSMutableArray new];

    NSArray* offersArray = [productOffersJSON objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(offersArray, NSArray)) {
        
        for (NSDictionary* offerJSON in offersArray) {
            
            if (VALID_NOTEMPTY(offerJSON, NSDictionary)) {
         
                RIProductOffer* newProductOffer = [RIProductOffer parseProductOffer:offerJSON country:country];
                [productOffers addObject:newProductOffer];
            }
        }
    }
        
    return [productOffers sortedArrayUsingSelector:@selector(compare:)];
}

- (NSComparisonResult)compare:(RIProductOffer *)productOffer {
    return [self.price compare:productOffer.price];
}

+ (RIProductOffer*)parseProductOffer:(NSDictionary*)productOfferJSON
                             country:(RICountryConfiguration*)country
{
    RIProductOffer* newProductOffer = [[RIProductOffer alloc] init];
    
    NSDictionary* productJSON = [productOfferJSON objectForKey:@"product"];
    
    if (VALID_NOTEMPTY(productJSON, NSDictionary)) {
        
        if ([productJSON objectForKey:@"sku"]) {
            newProductOffer.productSku = [productJSON objectForKey:@"sku"];
        }
        if (VALID_NOTEMPTY([productJSON objectForKey:@"shop_first"], NSNumber)) {
            newProductOffer.shopFirst = [productJSON objectForKey:@"shop_first"];
        }
        if ([productJSON objectForKey:@"simples"]) {
            NSArray* simplesArray = [productJSON objectForKey:@"simples"];
            NSMutableArray* newSimples = [[NSMutableArray alloc]init];
            if (VALID_NOTEMPTY(simplesArray, NSArray)) {
                for (NSDictionary* simple in simplesArray) {
                    [newSimples addObject:[RIProductSimple parseProductSimple:simple
                                                                     country:country
                                                                variationKey:Nil]];
                }
            }
            newProductOffer.productSimples = [newSimples copy];
        }
        if ([productJSON objectForKey:@"price"]) {
            newProductOffer.price = [productJSON objectForKey:@"price"];
            newProductOffer.priceFormatted = [RICountryConfiguration formatPrice:newProductOffer.price country:country];
        }
        if ([productJSON objectForKey:@"price_converted"]) {
            newProductOffer.priceEuroConverted = [productJSON objectForKey:@"price_converted"];
        }
        if ([productJSON objectForKey:@"special_price"]) {
            newProductOffer.specialPrice = [productJSON objectForKey:@"special_price"];
            newProductOffer.specialPriceFormatted = [RICountryConfiguration formatPrice:newProductOffer.specialPrice country:country];
        }
        if ([productJSON objectForKey:@"special_price_converted"]) {
            newProductOffer.specialPriceEuroConverted = [productJSON objectForKey:@"special_price_converted"];
        }
        if ([productJSON objectForKey:@"min_delivery_time"]) {
            newProductOffer.minDeliveryTime = [productJSON objectForKey:@"min_delivery_time"];
        }
        if ([productJSON objectForKey:@"max_delivery_time"]) {
            newProductOffer.maxDeliveryTime = [productJSON objectForKey:@"max_delivery_time"];
        }
    }
    
    NSDictionary* sellerJSON = [productOfferJSON objectForKey:@"seller_entity"];

    if (VALID_NOTEMPTY(sellerJSON, NSDictionary)) {
        
        RISeller* newSeller = [RISeller parseSeller:sellerJSON];
        newProductOffer.seller = newSeller;
    }
    
    return newProductOffer;
}

@end
