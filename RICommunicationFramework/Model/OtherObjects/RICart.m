//
//  RICart.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICart.h"
#import "CartEntity.h"
#import "RIForm.h"
#import "RIShippingMethodForm.h"
#import "RIPaymentMethodForm.h"
#import "RIPaymentInformation.h"
#import "CartForm.h"

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
+ (RICart *)parseCheckoutFinish:(NSDictionary*)json forCart:(RICart*)cart {
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

//TODO: Remove this and replace with CartForm serialization when no function is using it anymore
+(void)parseCartEntityFromJSONResponse:(NSDictionary*)jsonResponse successBlock:(void (^)(RICart* cart))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
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
                                        cart.formEntity.paymentMethodForm = paymentMethodForm;
                                    } else if ([type isEqualToString:@"multistep_shipping_method"]) {
                                        cart.formEntity.shippingMethodForm = [ShippingMethodForm new];
                                        [cart.formEntity.shippingMethodForm mergeFromDictionary:[metadata objectForKey:@"form_entity"] useKeyMapping:YES error:nil];
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

+ (RICart *)parseCart:(NSDictionary *)json country:(RICountryConfiguration*)country {
    return [RICart parseToDataModelWithObjects:@[ json, country ]];
}

#pragma mark - JSONVerboseModel
+(instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    RICountryConfiguration *country = objects[1];
    
    RICart *cart;
    if(objects.count >= 3) {
        cart = (RICart *)[objects objectAtIndex:2];
    } else {
        cart = [RICart new];
    }
    
    //ADDRESSES
    if (VALID_NOTEMPTY([dict objectForKey:@"addresses"], NSDictionary)) {
        RIForm* address = [RIForm parseForm:[dict objectForKey:@"addresses"]];
        cart.addressForm = address;
    }
    
    //FORM ENTITY
    NSDictionary *_formEntity = [dict objectForKey:@"form_entity"];
    if(_formEntity) {
        cart.formEntity = [FormEntity parseToDataModelWithObjects:@[ _formEntity ]];
    }
    
    //CART ENTITY
    NSDictionary *_cartEntity = [dict objectForKey:@"cart_entity"];
    if(_cartEntity) {
        cart.cartEntity = [CartEntity parseToDataModelWithObjects:@[ _cartEntity, country ]];
    }
    
    //CUSTOMER ENTITY
    NSDictionary *_customerEntity = [dict objectForKey:@"customer_entity"];
    if(_customerEntity) {
        cart.customerEntity = [RICustomer parseToDataModelWithObjects:@[ _customerEntity ]];
    }
    
    //SHIPPING METHOD FORM
    /*if (VALID_NOTEMPTY([dict objectForKey:@"shippingMethodForm"], NSDictionary)) {
        cart.formEntity.shippingMethodForm = [ShippingMethodForm new];
        [cart.formEntity.shippingMethodForm mergeFromDictionary:[dict objectForKey:@"shippingMethodForm"] useKeyMapping:YES error:nil];
    }
    
    //PAYMENT METHOD FORM
    if(VALID_NOTEMPTY([dict objectForKey:@"paymentMethodForm"], NSDictionary)) {
        RIPaymentMethodForm *paymentMethodForm = [RIPaymentMethodForm parseForm:[dict objectForKey:@"paymentMethodForm"]];
        cart.formEntity.paymentMethodForm = paymentMethodForm;
    }*/
    
    //MULTI-STEP ENTITY
    if (VALID_NOTEMPTY([dict objectForKey:@"multistep_entity"], NSDictionary) ) {
        NSDictionary* nextStep = [dict objectForKey:@"multistep_entity"];
        cart.nextStep = [nextStep objectForKey:@"next_step"];
    }
    
    return cart;
}

@end
