//
//  RIPromotion.m
//  Jumia
//
//  Created by Telmo Pinto on 02/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPromotion.h"

@implementation RIPromotion

+ (NSString *)getPromotionWithSuccessBlock:(void (^)(RIPromotion* promotion))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_PROMOTIONS_URL]]
                                                            parameters:nil
                                                            httpMethod:HttpResponseGet
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      NSDictionary* data = [metadata objectForKey:@"data"];
                                                                      if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                          RIPromotion* promotion = [RIPromotion parsePromotion:data];
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              successBlock(promotion);
                                                                          });
                                                                          return;
                                                                      }
                                                                  }
                                                                  failureBlock(apiResponse, nil);
                                                              } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
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


+(RIPromotion*)parsePromotion:(NSDictionary*)promotionJSON
{
    RIPromotion* promotion = [[RIPromotion alloc] init];
    
    if ([promotionJSON objectForKey:@"title"]) {
        if (![[promotionJSON objectForKey:@"title"] isKindOfClass:[NSNull class]]) {
            promotion.title = [promotionJSON objectForKey:@"title"];
        }
    }
    if ([promotionJSON objectForKey:@"description"]) {
        if (![[promotionJSON objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
            promotion.descriptionMessage = [promotionJSON objectForKey:@"description"];
        }
    }
    if ([promotionJSON objectForKey:@"coupon_code"]) {
        if (![[promotionJSON objectForKey:@"coupon_code"] isKindOfClass:[NSNull class]]) {
            promotion.couponCode = [promotionJSON objectForKey:@"coupon_code"];
        }
    }
    if ([promotionJSON objectForKey:@"terms_conditions"]) {
        if (![[promotionJSON objectForKey:@"terms_conditions"] isKindOfClass:[NSNull class]]) {
            promotion.termsAndConditions = [promotionJSON objectForKey:@"terms_conditions"];
        }
    }
    if ([promotionJSON objectForKey:@"end_date"]) {
        if (![[promotionJSON objectForKey:@"end_date"] isKindOfClass:[NSNull class]]) {
            promotion.endDate = [promotionJSON objectForKey:@"end_date"];
        }
    }
    
    return promotion;
}

@end
