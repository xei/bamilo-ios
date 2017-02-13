//
//  RICart.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICart.h"
#import "RICartItem.h"
#import "RIShippingMethodForm.h"
#import "RIPaymentMethodForm.h"
#import "RIPaymentInformation.h"
#import "RIAddress.h"
#import "RISellerDelivery.h"
#import "RIProduct.h"

@implementation RICart

#pragma mark - Get cart

+ (NSString *)getCartWithSuccessBlock:(void (^)(RICart *cart))sucessBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CART_DATA]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"cart_entity"], NSDictionary)) {
                                                                          NSDictionary *cartEntity = metadata;
                                                                          sucessBlock([RICart parseCart:cartEntity country:configuration]);
                                                                  } else {
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

#pragma mark - Change quantity of cart products

+ (NSString *) changeQuantityInProducts:(NSDictionary *)productsQuantities
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_PRODUCT_UPDATE]]
                                                            parameters:productsQuantities
                                                            httpMethod:HttpVerbPUT
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
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

+ (NSString *) resetCartWithSuccessBlock:(void (^)(void))sucessBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_CLEAR_CART]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbDELETE
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              sucessBlock();
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
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

#pragma mark - Add product to cart

+ (NSString *)addProductWithQuantity:(NSString *)quantity
                           simpleSku:(NSString *)simpleSku
                    withSuccessBlock:(void (^)(RICart *cart, RIApiResponse apiResponse, NSArray *successMessage))sucessBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(quantity, NSString))
    {
        [parameters setValue:quantity forKey:@"quantity"];
    }
    if(VALID_NOTEMPTY(simpleSku, NSString))
    {
        [parameters setValue:simpleSku forKey:@"sku"];
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_ORDER]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"cart_entity"], NSDictionary))
                                                                  {
                                                                      NSDictionary *cartEntity = metadata;
                                                                      if (VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary)) {
                                                                          NSDictionary *messages = [jsonObject objectForKey:@"messages"];
                                                                          if (VALID_NOTEMPTY([messages objectForKey:@"success"], NSArray)) {
                                                                              NSArray *success = [messages objectForKey:@"success"];
                                                                              if (VALID_NOTEMPTY([success valueForKey:@"message"], NSArray)) {
                                                                                  NSArray *successMessage = [success valueForKey:@"message"];
                                                                                  sucessBlock([RICart parseCart:cartEntity country:configuration], apiResponse, successMessage);
                                                                                  return;
                                                                              }
                                                                          }
                                                                      }
                                                                      sucessBlock([RICart parseCart:cartEntity country:configuration], apiResponse, nil);
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

+ (NSString *)removeProductWithSku:(NSString *)sku
                  withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    if (VALID_NOTEMPTY(sku, NSString)) {
        [parameters setObject:sku forKey:@"sku"];
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_REMOVE_PRODUCT_FROM_CART]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbDELETE
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
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

#pragma mark - Add multiple products to cart

+ (NSString *)addMultipleProducts:(NSArray *)productsToAdd
                 withSuccessBlock:(void (^)(RICart *cart, NSArray *productsNotAdded))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock))failureBlock {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(productsToAdd.count) {
        [parameters setValue:productsToAdd forKey:[NSString stringWithFormat:@"product_list[]"]];
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_MULTIPLE_ORDER]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  RICart *cart = nil;
                                                                  NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      cart = [RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration];
                                                                  }
                                                                  
                                                                  NSDictionary *errorMessages = [RIError getErrorDictionary:jsonObject];
                                                                  
                                                                  if(VALID_NOTEMPTY(cart, RICart)) {
                                                                      if(VALID_NOTEMPTY(errorMessages, NSDictionary)) {
                                                                          sucessBlock(cart, [errorMessages allKeys]);
                                                                      } else {
                                                                          sucessBlock(cart, nil);
                                                                      }
                                                                  } else {
                                                                      failureBlock(apiResponse, nil, NO);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil, NO);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject)) {
                                                                  NSArray *errorMessagesArray = [RIError getErrorMessages:errorJsonObject];
                                                                  NSArray *errorMessages = nil;
                                                                  
                                                                  BOOL outOfStockError = YES;
                                                                  
                                                                  if(VALID_NOTEMPTY(errorMessagesArray, NSArray)) {
                                                                      outOfStockError = NO;
                                                                      errorMessages = [errorMessagesArray copy];
                                                                  } else {
                                                                      NSDictionary *errorMessagesDictionary = [RIError getErrorDictionary:errorJsonObject];
                                                                      
                                                                      if(VALID_NOTEMPTY(errorMessagesDictionary, NSDictionary)) {
                                                                          errorMessages = [errorMessagesDictionary allKeys];
                                                                          for(NSString *errorMessagesKey in errorMessages) {
                                                                              NSString *errorMessageValue = [errorMessagesDictionary objectForKey:errorMessagesKey];
                                                                              if(VALID_NOTEMPTY(errorMessageValue, NSString) && ![@"ORDER_PRODUCT_SOLD_OUT" isEqualToString:errorMessageValue]) {
                                                                                  outOfStockError = NO;
                                                                                  break;
                                                                              }
                                                                          }
                                                                      }
                                                                  }
                                                                  
                                                                  failureBlock(apiResponse, errorMessages, outOfStockError);
                                                                  
                                                              } else if (NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray, NO);
                                                              } else {
                                                                  failureBlock(apiResponse, nil, NO);
                                                              }
                                                          }];
}

#pragma mark - Add Bundles

+ (NSString *)addBundleProductsWithSimpleSkus:(NSArray *)simpleSkus
                                     bundleId:(NSString *)bundleId
                             withSuccessBlock:(void (^)(RICart *cart, NSArray *productsNotAdded))sucessBlock
                              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock))failureBlock
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    
    [parameters setObject:bundleId forKey:@"bundle_id"];
    [parameters setObject:simpleSkus forKey:[NSString stringWithFormat:@"product_list[]"]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_BUNDLE]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  RICart *cart = nil;
                                                                  NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                  {
                                                                      cart = [RICart parseCart:[jsonObject objectForKey:@"metadata"] country:configuration];
                                                                  }
                                                                  
                                                                  NSDictionary *errorMessages = [RIError getErrorDictionary:jsonObject];
                                                                  
                                                                  if(VALID_NOTEMPTY(cart, RICart))
                                                                  {
                                                                      if(VALID_NOTEMPTY(errorMessages, NSDictionary))
                                                                      {
                                                                          sucessBlock(cart, [errorMessages allKeys]);
                                                                      }
                                                                      else
                                                                      {
                                                                          sucessBlock(cart, nil);
                                                                      }
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(apiResponse, nil, NO);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil, NO);
                                                              }];
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              
                                                              if (NOTEMPTY(errorJsonObject))
                                                              {
                                                                  NSArray *errorMessagesArray = [RIError getErrorMessages:errorJsonObject];
                                                                  NSArray *errorMessages = nil;
                                                                  
                                                                  BOOL outOfStockError = YES;
                                                                  
                                                                  if(VALID_NOTEMPTY(errorMessagesArray, NSArray))
                                                                  {
                                                                      outOfStockError = NO;
                                                                      errorMessages = [errorMessagesArray copy];
                                                                  }
                                                                  else
                                                                  {
                                                                      NSDictionary *errorMessagesDictionary = [RIError getErrorDictionary:errorJsonObject];
                                                                      
                                                                      if(VALID_NOTEMPTY(errorMessagesDictionary, NSDictionary))
                                                                      {
                                                                          errorMessages = [errorMessagesDictionary allKeys];
                                                                          for(NSString *errorMessagesKey in errorMessages)
                                                                          {
                                                                              NSString *errorMessageValue = [errorMessagesDictionary objectForKey:errorMessagesKey];
                                                                              if(VALID_NOTEMPTY(errorMessageValue, NSString) && ![@"ORDER_PRODUCT_SOLD_OUT" isEqualToString:errorMessageValue])
                                                                              {
                                                                                  outOfStockError = NO;
                                                                                  break;
                                                                              }
                                                                          }
                                                                      }
                                                                  }
                                                                  
                                                                  failureBlock(apiResponse, errorMessages, outOfStockError);
                                                                  
                                                              }
                                                              else if (NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray, NO);
                                                                  
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil, NO);
                                                              }
                                                          }];

}


#pragma mark - Vouchers
+ (NSString *) addVoucherWithCode:(NSString *)voucherCode
                 withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSDictionary *dic =[NSDictionary dictionaryWithObject:voucherCode forKey:@"couponcode"];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_ADD_VOUCHER_TO_CART]]
                                                            parameters:dic
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
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
                                                        httpMethod:HttpVerbDELETE
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
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

+ (RICart *)parseCheckoutFinish:(NSDictionary*)json
                        forCart:(RICart*)cart
{
    if (VALID_NOTEMPTY([json objectForKey:@"orders_count"], NSString)) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        cart.totalNumberOfOrders = [f numberFromString:[json objectForKey:@"orders_count"]];
    } else if (VALID_NOTEMPTY([json objectForKey:@"orders_count"], NSNumber)){
        cart.totalNumberOfOrders = [json objectForKey:@"orders_count"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"order_nr"], NSString)) {
        cart.orderNr = [json objectForKey:@"order_nr"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"customer_first_name"], NSString)) {
        cart.customerFirstMame = [json objectForKey:@"customer_first_name"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"customer_last_name"], NSString)) {
        cart.customerLastName = [json objectForKey:@"customer_last_name"];
    }
    
    if([json objectForKey:@"payment"]) {
        cart.paymentInformation = [RIPaymentInformation parsePaymentInfo:[json objectForKey:@"payment"]];
    }
    
    return cart;
}

#pragma mark - Checkout multistep methods

+(void)parseNextStepFromJSONResponse:(NSDictionary*)jsonResponse
                    successBlock:(void (^)(NSString* nextStep))successBlock
                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    if ([jsonResponse objectForKey:@"metadata"]) {
        NSDictionary* metadata = [jsonResponse objectForKey:@"metadata"];
        
        if (VALID_NOTEMPTY(metadata, NSDictionary)) {
            
            if ([metadata objectForKey:@"multistep_entity"]) {
                
                NSDictionary* multistepEntity = [metadata objectForKey:@"multistep_entity"];
                
                if (VALID_NOTEMPTY(multistepEntity, NSDictionary)) {
                    
                    if ([multistepEntity objectForKey:@"next_step"]) {
                        
                        NSString* nextStep = [multistepEntity objectForKey:@"next_step"];
                        if (VALID_NOTEMPTY(nextStep, NSString)) {
                            successBlock(nextStep);
                            return;
                        }
                        
                    }
                }
            }
        }
    }
    if (failureBlock) {
        failureBlock(0, nil);
    }
}

+(void)parseCartEntityFromJSONResponse:(NSDictionary*)jsonResponse
                          successBlock:(void (^)(RICart* cart))successBlock
                       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSDictionary* metadata = [jsonResponse objectForKey:@"metadata"];
    if (VALID_NOTEMPTY(metadata, NSDictionary)) {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            
            RICart* cart;
            if (VALID_NOTEMPTY([metadata objectForKey:@"cart_entity"], NSDictionary)) {
                cart = [RICart parseCart:metadata country:configuration];
                
                if (VALID_NOTEMPTY(cart, RICart)) {
                    if (VALID_NOTEMPTY([metadata objectForKey:@"form_entity"], NSDictionary)) {
                        
                        NSDictionary* formEntity = [metadata objectForKey:@"form_entity"];
                        if (VALID_NOTEMPTY(formEntity, NSDictionary)) {
                            if ([formEntity objectForKey:@"type"]) {
                                
                                NSString* type = [formEntity objectForKey:@"type"];
                                if (VALID_NOTEMPTY(type, NSString)) {
                                    
                                    if ([type isEqualToString:@"multistep_payment_method"]) {
                                        RIPaymentMethodForm* paymentMethodForm = [RIPaymentMethodForm parseForm:[metadata objectForKey:@"form_entity"]];
                                        cart.paymentMethodForm = paymentMethodForm;
                                    } else if ([type isEqualToString:@"multistep_shipping_method"]) {
                                        RIShippingMethodForm* shippingMethodForm = [RIShippingMethodForm parseForm:[metadata objectForKey:@"form_entity"]];
                                        cart.shippingMethodForm = shippingMethodForm;
                                    }
                                }
                            }
                        }
                    }
                    
                    if (successBlock) {
                        successBlock(cart);
                    }
                    return;
                }
            }
            if (failureBlock) {
                failureBlock(0, nil);
            }
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            failureBlock(apiResponse, errorMessages);
        }];
    }
}

+(void)parseErrorForApiResponse:(RIApiResponse)apiResponse
                      errorJSON:(NSDictionary*)errorJsonObject
                          error:(NSError*)errorObject
                   failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
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
}


+(NSString*)getMultistepAddressWithSuccessBlock:(void (^)(RICart *cart, RICustomer *customer))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_GET_ADDRESSES]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                          
                                                          
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)setMultistepAddressForShipping:(NSString*)shippingAddressId
                                   billing:(NSString*)billingAddressId
                              successBlock:(void (^)(NSString* nextStep))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    if (VALID_NOTEMPTY(shippingAddressId, NSString)) {
        [parameters setObject:shippingAddressId forKey:@"addresses[shipping_id]"];
    } else {
        //shipping id is mandatory for this request
        return nil;
    }
    if (VALID_NOTEMPTY(billingAddressId, NSString)) {
        [parameters setObject:billingAddressId forKey:@"addresses[billing_id]"];
    } else {
        //billing id is mandatory. the caller of this method might send it as nil if
        //its the same as shipping address, in which case we set it so
        [parameters setObject:shippingAddressId forKey:@"addresses[billing_id]"];
    }
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_SUBMIT_ADDRESSES]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICart parseNextStepFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)getMultistepShippingWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_GET_SHIPPING]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICart parseCartEntityFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)setMultistepShippingForShippingMethod:(NSString*)shippingMethod
                                   pickupStation:(NSString*)pickupStation
                                           region:(NSString*)region
                              successBlock:(void (^)(NSString* nextStep))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    if (VALID_NOTEMPTY(shippingMethod, NSString)) {
        [parameters setObject:shippingMethod forKey:@"shipping_method[shipping_method]"];
    }
    if (VALID_NOTEMPTY(pickupStation, NSString)) {
        [parameters setObject:pickupStation forKey:@"shipping_method[pickup_station]"];
    }
    if (VALID_NOTEMPTY(region, NSString)) {
        [parameters setObject:region forKey:@"shipping_method[pickup_station_customer_address_region]"];
    }
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_SUBMIT_SHIPPING]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICart parseNextStepFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)getMultistepPaymentWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_GET_PAYMENT]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               [RICart parseCartEntityFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)setMultistepPayment:(NSDictionary*)parameters
                   successBlock:(void (^)(NSString* nextStep))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_SUBMIT_PAYMENT]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICart parseNextStepFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)getMultistepFinishWithSuccessBlock:(void (^)(RICart *cart))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_GET_FINISH]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICart parseCartEntityFromJSONResponse:jsonObject successBlock:successBlock andFailureBlock:failureBlock];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+(NSString*)setMultistepFinishForCart:(RICart*)cart
                     withSuccessBlock:(void (^)(RICart* cart, NSString *rrTargetString))successBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    [parameters setObject:@"ios" forKey:@"app"];
    NSString* device = @"mobile";
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        device = @"tablet";
    }
    [parameters setObject:device forKey:@"customer_device"];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_MULTISTEP_SUBMIT_FINISH]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      NSDictionary *metadata = VALID_NOTEMPTY_VALUE([jsonObject objectForKey:@"metadata"], NSDictionary);
                                                                      NSDictionary *recommendedProducts = VALID_NOTEMPTY_VALUE([metadata objectForKey:@"recommended_products"], NSDictionary);
                                                                      NSString *rrTarget = VALID_NOTEMPTY_VALUE([recommendedProducts objectForKey:@"target"], NSString);
                                                                      successBlock([RICart parseCheckoutFinish:[jsonObject objectForKey:@"metadata"] forCart:cart], rrTarget);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              [RICart parseErrorForApiResponse:apiResponse errorJSON:errorJsonObject error:errorObject failureBlock:failureBlock];
                                                          }];
}

+ (RICart *)parseCart:(NSDictionary *)json country:(RICountryConfiguration*)country {
    return [RICart parseToDataModelWithObjects:@[json, country]];
}

#pragma mark - JSONVerboseModel
+(instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    RICountryConfiguration *country = objects[1];
    
    RICart *cart = [[RICart alloc] init];
    
    cart.cartUnreducedValue = nil;
    cart.cartUnreducedValueFormatted = nil;
    
    //Parse stuff outside of cart_entity
    if (VALID_NOTEMPTY([dict objectForKey:@"addresses"], NSDictionary)) {
        RIForm* address = [RIForm parseForm:[dict objectForKey:@"addresses"]];
        cart.addressForm = address;
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"shippingMethodForm"], NSDictionary)) {
        RIShippingMethodForm* shippingMethodForm = [RIShippingMethodForm parseForm:[dict objectForKey:@"shippingMethodForm"]];
        cart.shippingMethodForm = shippingMethodForm;
    }
    
    if(VALID_NOTEMPTY([dict objectForKey:@"paymentMethodForm"], NSDictionary)) {
        RIPaymentMethodForm* paymentMethodForm = [RIPaymentMethodForm parseForm:[dict objectForKey:@"paymentMethodForm"]];
        cart.paymentMethodForm = paymentMethodForm;
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"multistep_entity"], NSDictionary) ) {
        NSDictionary* nextStep = [dict objectForKey:@"multistep_entity"];
        cart.nextStep = [nextStep objectForKey:@"next_step"];
    }
    
    //From here on out we're parsing stuff inside cart_entity
    if (VALID([dict objectForKey:@"cart_entity"], NSDictionary)) {
        NSDictionary* cartEntityJSON = [dict objectForKey:@"cart_entity"];
        
        BOOL showUnreducedPrice = NO;
        CGFloat cartUnreducedValue = 0.0f;
        if ([cartEntityJSON objectForKey:@"products"]) {
            NSArray *cartItemObjects = [cartEntityJSON objectForKey:@"products"];
            if (VALID_NOTEMPTY(cartItemObjects, NSArray)) {
                NSMutableArray *cartItems = [[NSMutableArray alloc] init];
                for(NSDictionary *cartItemObject in cartItemObjects) {
                    RICartItem *cartItem = [RICartItem parseCartItem:cartItemObject country:country];
                    [cartItems addObject:cartItem];
                    
                    cartUnreducedValue += ([cartItem.price floatValue] * [cartItem.quantity integerValue]);
                    if(!showUnreducedPrice && VALID_NOTEMPTY(cartItem.specialPrice , NSNumber) && 0.0f < [cartItem.specialPrice floatValue] && [cartItem.price floatValue] != [cartItem.specialPrice floatValue]) {
                        showUnreducedPrice = YES;
                    }
                }
                
                cart.cartItems = [cartItems copy];
                
                if(showUnreducedPrice) {
                    cart.cartUnreducedValue = [NSNumber numberWithFloat:cartUnreducedValue];
                    cart.cartUnreducedValueFormatted = [RICountryConfiguration formatPrice:cart.cartUnreducedValue country:country];
                }
            }
        }
        
        if([cartEntityJSON objectForKey:@"sub_total_undiscounted"]) {
            cart.cartUnreducedValue = [cartEntityJSON objectForKey:@"sub_total_undiscounted"];
            cart.cartUnreducedValueFormatted = [RICountryConfiguration formatPrice:cart.cartUnreducedValue country:country];
        }
        
        if([cartEntityJSON objectForKey:@"sub_total"]){
            if(![[cartEntityJSON objectForKey:@"sub_total"] isKindOfClass:[NSNull class]]){
                cart.subTotal = [cartEntityJSON objectForKey:@"sub_total"];
                cart.subTotalFormatted = [RICountryConfiguration formatPrice:cart.subTotal country:country];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"total_products"]) {
            if (![[cartEntityJSON objectForKey:@"total_products"] isKindOfClass:[NSNull class]]) {
                cart.cartCount = [cartEntityJSON objectForKey:@"total_products"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"total"]) {
            if (![[cartEntityJSON objectForKey:@"total"] isKindOfClass:[NSNull class]]) {
                cart.cartValue = [cartEntityJSON objectForKey:@"total"];
                cart.cartValueFormatted = [RICountryConfiguration formatPrice:cart.cartValue country:country];
            }
        }
        
        if (cart.cartValue && cart.cartUnreducedValue) {
            NSNumber *discountValue = [NSNumber numberWithInt: cart.cartUnreducedValue.intValue - cart.cartValue.intValue];
            cart.discountedValueFormated = [RICountryConfiguration formatPrice:discountValue country:country];
        }
        
        if ([cartEntityJSON objectForKey:@"total_converted"]) {
            if (![[cartEntityJSON objectForKey:@"total_converted"] isKindOfClass:[NSNull class]]) {
                cart.cartValueEuroConverted = [cartEntityJSON objectForKey:@"total_converted"];
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"delivery"], NSDictionary)) {
            NSDictionary *deliveryDic = [cartEntityJSON objectForKey:@"delivery"];
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"amount"], NSNumber)) {
                cart.shippingValue = [deliveryDic objectForKey:@"amount"];
                cart.shippingValueFormatted = [RICountryConfiguration formatPrice:cart.shippingValue country:country];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"amount_converted"], NSNumber)) {
                cart.shippingValueEuroConverted = [cartEntityJSON objectForKey:@"amount_converted"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_amount"], NSNumber)) {
                cart.deliveryDiscountAmount = [cartEntityJSON objectForKey:@"discount_amount"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_amount_converted"], NSNumber)) {
                cart.deliveryDiscountAmountConverted = [cartEntityJSON objectForKey:@"discount_amount_converted"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_cart_rule_discount"], NSNumber)) {
                cart.deliveryDiscountCartRuleDiscount = [cartEntityJSON objectForKey:@"discount_cart_rule_discount"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_cart_rule_discount_converted"], NSNumber)) {
                cart.deliveryDiscountCartRuleDiscountConverted = [cartEntityJSON objectForKey:@"discount_cart_rule_discount_converted"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_coupon_money_value"], NSNumber)) {
                cart.deliveryDiscountCouponMoneyValue = [cartEntityJSON objectForKey:@"discount_coupon_money_value"];
            }
            if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_coupon_money_value_converted"], NSNumber)) {
                cart.deliveryDiscountCouponMoneyValueConverted = [cartEntityJSON objectForKey:@"discount_coupon_money_value_converted"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"extra_costs"]) {
            if (![[cartEntityJSON objectForKey:@"extra_costs"] isKindOfClass:[NSNull class]]) {
                cart.extraCosts = [cartEntityJSON objectForKey:@"extra_costs"];
                cart.extraCostsFormatted = [RICountryConfiguration formatPrice:cart.extraCosts country:country];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"extra_costs_converted"]) {
            if (![[cartEntityJSON objectForKey:@"extra_costs_converted"] isKindOfClass:[NSNull class]]) {
                cart.extraCostsEuroConverted = [cartEntityJSON objectForKey:@"extra_costs_converted"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"vat"]) {
            if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"vat"], NSDictionary)) {
                NSDictionary *vatDict = [cartEntityJSON objectForKey:@"vat"];
                if (VALID_NOTEMPTY([vatDict objectForKey:@"label"], NSString)) {
                    cart.vatLabel = [vatDict objectForKey:@"label"];
                }
                if (VALID_NOTEMPTY([vatDict objectForKey:@"label_configuration"], NSNumber)) {
                    cart.vatLabelEnabled = [vatDict objectForKey:@"label_configuration"];
                }
                if (VALID_NOTEMPTY([vatDict objectForKey:@"value"], NSNumber)) {
                    cart.vatValue = [vatDict objectForKey:@"value"];
                    cart.vatValueFormatted = [RICountryConfiguration formatPrice:cart.vatValue country:country];
                }
                if (VALID_NOTEMPTY([vatDict objectForKey:@"value_converted"], NSNumber)) {
                    cart.vatValueEuroConverted = [vatDict objectForKey:@"value_converted"];
                }
            }
        }
        
        if ([cartEntityJSON objectForKey:@"sub_total"]) {
            if (![[cartEntityJSON objectForKey:@"sub_total"] isKindOfClass:[NSNull class]]) {
                cart.sumCosts = [cartEntityJSON objectForKey:@"sub_total"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"sub_total_converted"]) {
            if (![[cartEntityJSON objectForKey:@"sub_total_converted"] isKindOfClass:[NSNull class]]) {
                cart.sumCostsEuroConverted = [cartEntityJSON objectForKey:@"sub_total_converted"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"sum_costs_value"]) {
            if (![[cartEntityJSON objectForKey:@"sum_costs_value"] isKindOfClass:[NSNull class]]) {
                cart.sumCostsValue = [cartEntityJSON objectForKey:@"sum_costs_value"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"sum_costs_value_converted"]) {
            if (![[cartEntityJSON objectForKey:@"sum_costs_value_converted"] isKindOfClass:[NSNull class]]) {
                cart.sumCostsValueEuroConverted = [cartEntityJSON objectForKey:@"sum_costs_value_converted"];
            }
        }
        
        if ([cartEntityJSON objectForKey:@"price_rules"]) {
            if (![[cartEntityJSON objectForKey:@"price_rules"] isKindOfClass:[NSNull class]]) {
                NSArray *priceRulesObject = [cartEntityJSON objectForKey:@"price_rules"];
                if(VALID_NOTEMPTY(priceRulesObject, NSArray)) {
                    NSMutableDictionary *priceRules = [[NSMutableDictionary alloc] init];
                    for(NSDictionary *priceRulesDictionary in priceRulesObject) {
                        if(VALID_NOTEMPTY(priceRulesDictionary, NSDictionary)) {
                            if ([priceRulesDictionary objectForKey:@"label"] && ![[priceRulesDictionary objectForKey:@"label"] isKindOfClass:[NSNull class]]) {
                                if ([priceRulesDictionary objectForKey:@"value"] && ![[priceRulesDictionary objectForKey:@"value"] isKindOfClass:[NSNull class]]) {
                                    if(VALID_NOTEMPTY([priceRulesDictionary objectForKey:@"value"], NSNumber)) {
                                        //since it's a rule to create a discount, add the minus signal to the string
                                        [priceRules setValue:[@"- " stringByAppendingString:[RICountryConfiguration formatPrice:[priceRulesDictionary objectForKey:@"value"] country:country]] forKey:[priceRulesDictionary objectForKey:@"label"]];
                                    } else {
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
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"coupon"], NSDictionary)) {
            NSDictionary *couponDic = [cartEntityJSON objectForKey:@"coupon"];
            if (VALID_NOTEMPTY([couponDic objectForKey:@"code"], NSString)) {
                cart.couponCode = [couponDic objectForKey:@"code"];
            }
            if (VALID_NOTEMPTY([couponDic objectForKey:@"value"], NSNumber)) {
                cart.couponMoneyValue = [couponDic objectForKey:@"value"];
                cart.couponMoneyValueFormatted = [RICountryConfiguration formatPrice:cart.couponMoneyValue country:country];
            }
            if (VALID_NOTEMPTY([couponDic objectForKey:@"value_converted"], NSNumber)) {
                cart.couponMoneyValueEuroConverted = [couponDic objectForKey:@"value_converted"];
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"shipping_method"], NSDictionary)) {
            NSDictionary* shipMethodDic = [cartEntityJSON objectForKey:@"shipping_method"];
            if (VALID_NOTEMPTY([shipMethodDic objectForKey:@"method"], NSString)) {
                cart.shippingMethod = [shipMethodDic objectForKey:@"method"];
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"payment_method"], NSDictionary)) {
            NSDictionary* payMethodDic = [cartEntityJSON objectForKey:@"payment_method"];
            if (VALID_NOTEMPTY([payMethodDic objectForKey:@"label"], NSString)) {
                cart.paymentMethod = [payMethodDic objectForKey:@"label"];
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"billing_address"], NSDictionary)) {
            NSDictionary* billingAddressJSON = [cartEntityJSON objectForKey:@"billing_address"];
            RIAddress* billingAddress = [RIAddress parseAddress:billingAddressJSON];
            if (VALID_NOTEMPTY(billingAddress, RIAddress)) {
                cart.billingAddress = billingAddress;
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"shipping_address"], NSDictionary)) {
            NSDictionary* shippingAddressJSON = [cartEntityJSON objectForKey:@"shipping_address"];
            RIAddress* shippingAddress = [RIAddress parseAddress:shippingAddressJSON];
            if (VALID_NOTEMPTY(shippingAddress, RIAddress)) {
                cart.shippingAddress = shippingAddress;
            }
        }
        
        if (VALID_NOTEMPTY([cartEntityJSON objectForKey:@"fulfillment"], NSArray)) {
            NSArray* fulfillment = [cartEntityJSON objectForKey:@"fulfillment"];
            NSMutableArray* sellers = [[NSMutableArray alloc] init];
            
            for (NSDictionary* seller in fulfillment) {
                RISellerDelivery* sellerDelivery = [RISellerDelivery parseSellerDelivery:[seller objectForKey:@"seller_entity"]];
                NSMutableArray* products = [[NSMutableArray alloc] init];
                
                for (NSDictionary* prod in [seller objectForKey:@"products"]) {
                    NSString* simpleSku = [prod objectForKey:@"simple_sku"];
                    
                    for (RICartItem* cartItem in cart.cartItems) {
                        if ([cartItem.simpleSku isEqual:simpleSku]) {
                            [products addObject:cartItem];
                            break;
                        }
                    }
                }
                sellerDelivery.products = [products copy];
                [sellers addObject:sellerDelivery];
            }
            cart.sellerDelivery = sellers;
        }
    }
    
    return cart;
}

@end
