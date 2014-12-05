//
//  RICart.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICart.h"
#import "RICartItem.h"

@implementation RICart

#pragma mark - Get cart

+ (NSString *)getCartWithSuccessBlock:(void (^)(RICart *cart))sucessBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CART_DATA]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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

#pragma mark - Get the cart change

+ (NSString *) changeQuantityInProducts:(NSDictionary *)productsQuantities
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CART_CHANGE]]
                                                            parameters:productsQuantities
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if (NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

#pragma mark - Add order

+ (NSString *)addProductWithQuantity:(NSString *)quantity
                                 sku:(NSString *)sku
                              simple:(NSString *)simple
                    withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(quantity, NSString))
    {
        [parameters setValue:quantity forKey:@"quantity"];
    }
    if(VALID_NOTEMPTY(sku, NSString))
    {
        [parameters setValue:sku forKey:@"p"];
    }
    if(VALID_NOTEMPTY(simple, NSString))
    {
        [parameters setValue:simple forKey:@"sku"];
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_ORDER]]
                                                            parameters:parameters
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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


#pragma mark - Remove product from cart

+ (NSString *)removeProductWithQuantity:(NSString *)quantity
                                    sku:(NSString *)sku
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSDictionary *dic = @{@"quantity": quantity,
                          @"sku": sku };
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_FROM_CART]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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

+ (NSString *) addVoucherWithCode:(NSString *)voucherCode
                 withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSDictionary *dic =[NSDictionary dictionaryWithObject:voucherCode forKey:@"couponcode"];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_VOUCHER_TO_CART]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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

+ (NSString *) removeVoucherWithCode:(NSString *)voucherCode
                 withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSDictionary *dic =[NSDictionary dictionaryWithObject:voucherCode forKey:@"couponcode"];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_VOUCHER_FROM_CART]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
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

#pragma mark - Cancel the request

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString)) {
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
    }
}

#pragma mark - Parsers

+ (RICart *)parseCart:(NSDictionary *)json country:(RICountryConfiguration*)country
{
    RICart *cart = [[RICart alloc] init];
    
    cart.cartUnreducedValue = nil;
    cart.cartUnreducedValueFormatted = nil;
    
    BOOL showUnreducedPrice = NO;
    CGFloat cartUnreducedValue = 0.0f;
    if ([json objectForKey:@"cartItems"]) {
        NSDictionary *cartItemObjects = [json objectForKey:@"cartItems"];
        if (VALID_NOTEMPTY(cartItemObjects, NSDictionary))
        {
            NSArray *cartItemObjectsKeys = [[cartItemObjects allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            if (VALID_NOTEMPTY(cartItemObjectsKeys, NSArray))
            {
                NSMutableArray *cartItems = [[NSMutableArray alloc] init];
                for(NSString *cartItemObjectsKey in cartItemObjectsKeys)
                {
                    RICartItem *cartItem = [RICartItem parseCartItemWithSimpleSku:cartItemObjectsKey info:[cartItemObjects objectForKey:cartItemObjectsKey] country:country];
                    [cartItems addObject:cartItem];
                    
                    cartUnreducedValue += ([cartItem.price floatValue] * [cartItem.quantity integerValue]);
                    if(!showUnreducedPrice && VALID_NOTEMPTY(cartItem.specialPrice , NSNumber) && 0.0f < [cartItem.specialPrice floatValue] && [cartItem.price floatValue] != [cartItem.specialPrice floatValue])
                    {
                        showUnreducedPrice = YES;
                    }
                }
                
                cart.cartItems = [cartItems copy];
                
                if(showUnreducedPrice)
                {
                    cart.cartUnreducedValue = [NSNumber numberWithFloat:cartUnreducedValue];
                    cart.cartUnreducedValueFormatted = [RICountryConfiguration formatPrice:cart.cartUnreducedValue country:country];
                }
            }
        }
    }
    
    if ([json objectForKey:@"cartCount"]) {
        if (![[json objectForKey:@"cartCount"] isKindOfClass:[NSNull class]]) {
            cart.cartCount = [json objectForKey:@"cartCount"];
        }
    }
    
    if ([json objectForKey:@"cartValue"]) {
        if (![[json objectForKey:@"cartValue"] isKindOfClass:[NSNull class]]) {
            cart.cartValue = [json objectForKey:@"cartValue"];
            cart.cartValueFormatted = [RICountryConfiguration formatPrice:cart.cartValue country:country];
        }
    }
    
    if ([json objectForKey:@"cartValue_euroConverted"]) {
        if (![[json objectForKey:@"cartValue_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.cartValueEuroConverted = [json objectForKey:@"cartValue_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"cartCleanValue"]) {
        if (![[json objectForKey:@"cartCleanValue"] isKindOfClass:[NSNull class]]) {
            cart.cartCleanValue = [json objectForKey:@"cartCleanValue"];
            cart.cartCleanValueFormatted = [RICountryConfiguration formatPrice:cart.cartCleanValue country:country];
        }
    }
    
    if ([json objectForKey:@"cartCleanValue_euroConverted"]) {
        if (![[json objectForKey:@"cartCleanValue_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.cartCleanValueEuroConverted = [json objectForKey:@"cartCleanValue_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"couponMoneyValue"]) {
        if (![[json objectForKey:@"couponMoneyValue"] isKindOfClass:[NSNull class]]) {
            cart.couponMoneyValue = [json objectForKey:@"couponMoneyValue"];
            cart.couponMoneyValueFormatted = [RICountryConfiguration formatPrice:cart.couponMoneyValue country:country];
        }
    }
    
    if ([json objectForKey:@"couponMoneyValue_euroConverted"]) {
        if (![[json objectForKey:@"couponMoneyValue_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.couponMoneyValueEuroConverted = [json objectForKey:@"couponMoneyValue_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"extra_costs"]) {
        if (![[json objectForKey:@"extra_costs"] isKindOfClass:[NSNull class]]) {
            cart.extraCosts = [json objectForKey:@"extra_costs"];
            cart.extraCostsFormatted = [RICountryConfiguration formatPrice:cart.extraCosts country:country];
        }
    }
    
    if ([json objectForKey:@"extra_costs_euroConverted"]) {
        if (![[json objectForKey:@"extra_costs_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.extraCostsEuroConverted = [json objectForKey:@"extra_costs_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"shipping_value"]) {
        if (![[json objectForKey:@"shipping_value"] isKindOfClass:[NSNull class]]) {
            cart.shippingValue = [json objectForKey:@"shipping_value"];
            cart.shippingValueFormatted = [RICountryConfiguration formatPrice:cart.shippingValue country:country];
        }
    }
    
    if ([json objectForKey:@"shipping_value_euroConverted"]) {
        if (![[json objectForKey:@"shipping_value_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.shippingValueEuroConverted = [json objectForKey:@"shipping_value_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"vat_value"]) {
        if (![[json objectForKey:@"vat_value"] isKindOfClass:[NSNull class]]) {
            cart.vatValue = [json objectForKey:@"vat_value"];
            cart.vatValueFormatted = [RICountryConfiguration formatPrice:cart.vatValue country:country];
        }
    }
    
    if ([json objectForKey:@"vat_value_euroConverted"]) {
        if (![[json objectForKey:@"vat_value_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.vatValueEuroConverted = [json objectForKey:@"vat_value_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"sum_costs"]) {
        if (![[json objectForKey:@"sum_costs"] isKindOfClass:[NSNull class]]) {
            cart.sumCosts = [json objectForKey:@"sum_costs"];
        }
    }
    
    if ([json objectForKey:@"sum_costs_euroConverted"]) {
        if (![[json objectForKey:@"sum_costs_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.sumCostsEuroConverted = [json objectForKey:@"sum_costs_euroConverted"];
        }
    }

    if ([json objectForKey:@"sum_costs_value"]) {
        if (![[json objectForKey:@"sum_costs_value"] isKindOfClass:[NSNull class]]) {
            cart.sumCostsValue = [json objectForKey:@"sum_costs_value"];
        }
    }
    
    if ([json objectForKey:@"sum_costs_value_euroConverted"]) {
        if (![[json objectForKey:@"sum_costs_value_euroConverted"] isKindOfClass:[NSNull class]]) {
            cart.sumCostsValueEuroConverted = [json objectForKey:@"sum_costs_value_euroConverted"];
        }
    }
    
    if ([json objectForKey:@"price_rules"]) {
        if (![[json objectForKey:@"price_rules"] isKindOfClass:[NSNull class]]) {
            NSArray *priceRulesObject = [json objectForKey:@"price_rules"];
            if(VALID_NOTEMPTY(priceRulesObject, NSArray))
            {
                NSMutableDictionary *priceRules = [[NSMutableDictionary alloc] init];
                for(NSDictionary *priceRulesDictionary in priceRulesObject)
                {
                    if(VALID_NOTEMPTY(priceRulesDictionary, NSDictionary))
                    {
                        if ([priceRulesDictionary objectForKey:@"label"] && ![[priceRulesDictionary objectForKey:@"label"] isKindOfClass:[NSNull class]])
                        {
                            if ([priceRulesDictionary objectForKey:@"value"] && ![[priceRulesDictionary objectForKey:@"value"] isKindOfClass:[NSNull class]])
                            {
                                if(VALID_NOTEMPTY([priceRulesDictionary objectForKey:@"value"], NSNumber))
                                {
                                    [priceRules setValue:[RICountryConfiguration formatPrice:[priceRulesDictionary objectForKey:@"value"] country:country] forKey: [priceRulesDictionary objectForKey:@"label"]];
                                }
                                else
                                {
                                    [priceRules setValue:[priceRulesDictionary objectForKey:@"value"] forKey: [priceRulesDictionary objectForKey:@"label"]];
                                }
                            }
                        }
                    }
                }
                cart.priceRules = [priceRules copy];
            }
        }
    }
    
    return cart;
}

@end
