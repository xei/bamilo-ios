//
//  RIProductOffer.m
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIProductOffer.h"
#import "RISeller.h"

@implementation RIProductOffer

+ (NSString*)getProductOffersForProductUrl:(NSString*)productUrl
                              successBlock:(void (^)(NSArray *productOffers))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@",productUrl,RI_API_PRODUCT_OFFERS];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      NSDictionary* data = [metadata objectForKey:@"data"];
                                                                      
                                                                      if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                          
                                                                          NSArray* offers = [RIProductOffer parseProductOffers:data country:configuration];
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
    
    return [productOffers copy];
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
        if ([productJSON objectForKey:@"simples"]) {
            NSArray* simplesArray = [productJSON objectForKey:@"simples"];
            if (VALID_NOTEMPTY(simplesArray, NSArray)) {
                NSDictionary* simpleJSON = [simplesArray objectAtIndex:0];
                if (VALID_NOTEMPTY(simpleJSON, NSDictionary)) {
                    if ([simpleJSON objectForKey:@"sku"]) {
                        newProductOffer.simpleSku = [simpleJSON objectForKey:@"sku"];
                    }
                }
            }
        }
        if ([productJSON objectForKey:@"price"]) {
            newProductOffer.price = [productJSON objectForKey:@"price"];
            newProductOffer.priceFormatted = [RICountryConfiguration formatPrice:newProductOffer.price country:country];
        }
        if ([productJSON objectForKey:@"price_euroConverted"]) {
            newProductOffer.priceEuroConverted = [productJSON objectForKey:@"price_euroConverted"];
        }
        if ([productJSON objectForKey:@"min_delivery_time"]) {
            newProductOffer.minDeliveryTime = [productJSON objectForKey:@"min_delivery_time"];
        }
        if ([productJSON objectForKey:@"max_delivery_time"]) {
            newProductOffer.maxDeliveryTime = [productJSON objectForKey:@"max_delivery_time"];
        }
    }
    
    NSDictionary* sellerJSON = [productOfferJSON objectForKey:@"seller"];

    if (VALID_NOTEMPTY(sellerJSON, NSDictionary)) {
        
        RISeller* newSeller = [RISeller parseSeller:sellerJSON];
        newProductOffer.seller = newSeller;
    }
    
    return newProductOffer;
}

@end
