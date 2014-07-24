//
//  RIOrders.m
//  Jumia
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrders.h"

@implementation RICartData

@end

@implementation RIOrders

#pragma mark - Add order

+ (NSString *)addOrderWithCartQuantity:(NSString *)quantity
                                   sku:(NSString *)sku
                                simple:(NSString *)simple
                      withSuccessBlock:(void (^)())sucessBlock
                       andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    NSDictionary *dic = @{@"quantity": quantity,
                          @"sku": sku,
                          @"p": simple };
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_ADD_ORDER]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              sucessBlock();
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject)) {
                                                                  
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                                  
                                                              } else if (NOTEMPTY(errorObject)) {
                                                                  
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                                  
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

#pragma mark - Get cart data

+ (NSString *)getCartDataWithSuccessBlock:(void (^)(RICartData *cartData))sucessBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_CART_DATA]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              if ([jsonObject objectForKey:@"metadata"]) {
                                                                  sucessBlock([RIOrders parseCartData:[jsonObject objectForKey:@"metadata"]]);
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject)) {
                                                                  
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                                  
                                                              } else if (NOTEMPTY(errorObject)) {
                                                                  
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                                  
                                                              } else {
                                                                  failureBlock(nil);
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

+ (RICartData *)parseCartData:(NSDictionary *)json
{
    RICartData *cartData = [[RICartData alloc] init];
    
    if ([json objectForKey:@"cartCleanValue"]) {
        if (![[json objectForKey:@"cartCleanValue"] isKindOfClass:[NSNull class]]) {
            cartData.cartCleanValue = [json objectForKey:@"cartCleanValue"];
        }
    }
    
    if ([json objectForKey:@"cartCount"]) {
        if (![[json objectForKey:@"cartCount"] isKindOfClass:[NSNull class]]) {
            cartData.cartCount = [json objectForKey:@"cartCount"];
        }
    }
    
    if ([json objectForKey:@"cartItems"]) {
        if (![[json objectForKey:@"cartItems"] isKindOfClass:[NSNull class]]) {
#warning it's necessary to know the struture of each cart item and implement the parser
        }
    }
    
    if ([json objectForKey:@"cartValue"]) {
        if (![[json objectForKey:@"cartValue"] isKindOfClass:[NSNull class]]) {
            cartData.cartValue = [json objectForKey:@"cartValue"];
        }
    }
    
    if ([json objectForKey:@"couponMoneyValue"]) {
        if (![[json objectForKey:@"couponMoneyValue"] isKindOfClass:[NSNull class]]) {
            cartData.couponMoneyValue = [json objectForKey:@"couponMoneyValue"];
        }
    }
    
    if ([json objectForKey:@"extra_costs"]) {
        if (![[json objectForKey:@"extra_costs"] isKindOfClass:[NSNull class]]) {
            cartData.extraCosts = [json objectForKey:@"extra_costs"];
        }
    }
    
    if ([json objectForKey:@"messages"]) {
        if (![[json objectForKey:@"messages"] isKindOfClass:[NSNull class]]) {
            cartData.messages = [json objectForKey:@"messages"];
        }
    }
    
    if ([json objectForKey:@"price_rules"]) {
        if (![[json objectForKey:@"price_rules"] isKindOfClass:[NSNull class]]) {
            cartData.priceRules = [json objectForKey:@"price_rules"];
        }
    }
    
    if ([json objectForKey:@"shipping_value"]) {
        if (![[json objectForKey:@"shipping_value"] isKindOfClass:[NSNull class]]) {
            cartData.shippingValue = [json objectForKey:@"shipping_value"];
        }
    }
    
    if ([json objectForKey:@"sum_costs"]) {
        if (![[json objectForKey:@"sum_costs"] isKindOfClass:[NSNull class]]) {
            cartData.sumCosts = [json objectForKey:@"sum_costs"];
        }
    }
    
    if ([json objectForKey:@"sum_costs_value"]) {
        if (![[json objectForKey:@"sum_costs_value"] isKindOfClass:[NSNull class]]) {
            cartData.sumCostsValue = [json objectForKey:@"sum_costs_value"];
        }
    }
    
    if ([json objectForKey:@"vat_value"]) {
        if (![[json objectForKey:@"vat_value"] isKindOfClass:[NSNull class]]) {
            cartData.vatValue = [json objectForKey:@"vat_value"];
        }
    }
    
    return cartData;
}

@end
