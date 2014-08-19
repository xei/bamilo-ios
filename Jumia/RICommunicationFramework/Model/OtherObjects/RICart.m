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
                      andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CART_DATA]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
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

#pragma mark - Get the cart change

+ (NSString *) changeQuantityInProducts:(NSDictionary *)productsQuantities
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CART_CHANGE]]
                                                            parameters:productsQuantities
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if (NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

#pragma mark - Add order

+ (NSString *)addProductWithQuantity:(NSString *)quantity
                                 sku:(NSString *)sku
                              simple:(NSString *)simple
                    withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                     andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
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
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
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


#pragma mark - Remove product from cart

+ (NSString *)removeProductWithQuantity:(NSString *)quantity
                                    sku:(NSString *)sku
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    NSDictionary *dic = @{@"quantity": quantity,
                          @"sku": sku };
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_FROM_CART]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  sucessBlock([RICart parseCart:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
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

+ (RICart *)parseCart:(NSDictionary *)json
{
    RICart *cart = [[RICart alloc] init];
    
    if ([json objectForKey:@"cartItems"]) {
        NSDictionary *cartItemObjects = [json objectForKey:@"cartItems"];
        if (VALID_NOTEMPTY(cartItemObjects, NSDictionary))
        {
            NSArray *cartItemObjectsKeys = [cartItemObjects allKeys];
            if (VALID_NOTEMPTY(cartItemObjectsKeys, NSArray))
            {
                NSMutableDictionary *cartItems = [[NSMutableDictionary alloc] init];
                for(NSString *cartItemObjectsKey in cartItemObjectsKeys)
                {
                    RICartItem *cartItem = [RICartItem parseCartItemWithSimpleSku:cartItemObjectsKey andInfo:[cartItemObjects objectForKey:cartItemObjectsKey]];
                    [cartItems setValue:cartItem forKey:cartItemObjectsKey];
                }
                
                cart.cartItems = [cartItems copy];
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
        }
    }
    
    if ([json objectForKey:@"cartCleanValue"]) {
        if (![[json objectForKey:@"cartCleanValue"] isKindOfClass:[NSNull class]]) {
            cart.cartCleanValue = [json objectForKey:@"cartCleanValue"];
        }
    }
    
    if ([json objectForKey:@"couponMoneyValue"]) {
        if (![[json objectForKey:@"couponMoneyValue"] isKindOfClass:[NSNull class]]) {
            cart.couponMoneyValue = [json objectForKey:@"couponMoneyValue"];
        }
    }
    
    if ([json objectForKey:@"extra_costs"]) {
        if (![[json objectForKey:@"extra_costs"] isKindOfClass:[NSNull class]]) {
            cart.extraCosts = [json objectForKey:@"extra_costs"];
        }
    }
    
    if ([json objectForKey:@"shipping_value"]) {
        if (![[json objectForKey:@"shipping_value"] isKindOfClass:[NSNull class]]) {
            cart.shippingValue = [json objectForKey:@"shipping_value"];
        }
    }
    
    if ([json objectForKey:@"vat_value"]) {
        if (![[json objectForKey:@"vat_value"] isKindOfClass:[NSNull class]]) {
            cart.vatValue = [json objectForKey:@"vat_value"];
        }
    }
    
    if ([json objectForKey:@"sum_costs"]) {
        if (![[json objectForKey:@"sum_costs"] isKindOfClass:[NSNull class]]) {
            cart.sumCosts = [json objectForKey:@"sum_costs"];
        }
    }
    
    if ([json objectForKey:@"sum_costs_value"]) {
        if (![[json objectForKey:@"sum_costs_value"] isKindOfClass:[NSNull class]]) {
            cart.sumCostsValue = [json objectForKey:@"sum_costs_value"];
        }
    }
    
    if ([json objectForKey:@"price_rules"]) {
        if (![[json objectForKey:@"price_rules"] isKindOfClass:[NSNull class]]) {
            cart.priceRules = [json objectForKey:@"price_rules"];
        }
    }
    
    return cart;
}

@end
