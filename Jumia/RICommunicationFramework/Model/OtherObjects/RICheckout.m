//
//  RICheckout.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICheckout.h"

@implementation RICheckout

+ (NSString*)getBillingAddressFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_BILLING_ADDRESS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)setBillingAddress:(RIForm*)form
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [RIForm sendForm:form successBlock:^(NSDictionary *jsonObject) {
        if(VALID_NOTEMPTY(jsonObject, NSDictionary))
        {
            successBlock([RICheckout parseCheckout:jsonObject]);
        } else
        {
            failureBlock(nil);
        }
    } andFailureBlock:failureBlock];
}

+ (NSString*)getShippingAddressFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_SHIPPING_ADDRESS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)setShippingAddress:(RIForm*)form
                   successBlock:(void (^)(RICheckout *checkout))successBlock
                andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [RIForm sendForm:form successBlock:^(NSDictionary *jsonObject) {
        if(VALID_NOTEMPTY(jsonObject, NSDictionary))
        {
            successBlock([RICheckout parseCheckout:jsonObject]);
        } else
        {
            failureBlock(nil);
        }
    } andFailureBlock:failureBlock];
}

+ (NSString*)getShippingMethodFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_SHIPPING_METHODS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)setShippingMethod:(RIShippingMethodForm*)form
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:form.action]
                                                            parameters:[RIShippingMethodForm getParametersForForm:form]
                                                        httpMethodPost:isPostRequest
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}


+ (NSString*)getPaymentMethodFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                  andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_PAYMENT_METHODS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)setPaymentMethodWithParameters:(NSDictionary*)parameters
                               successBlock:(void (^)(RICheckout *checkout))successBlock
                            andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_SET_PAYMENT_METHOD]]
                                                            parameters:parameters
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                              {
                                                                  successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"]]);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}
#pragma mark - Cancel request

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Private methods
+ (RICheckout*)parseCheckout:(NSDictionary*)checkoutObject
{
    RICheckout *checkout = [[RICheckout alloc] init];
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"order"], NSDictionary))
    {
        checkout.orderSummary = [RIOrder parseOrder:[checkoutObject objectForKey:@"order"]];
    }
    
    if (VALID_NOTEMPTY([checkoutObject objectForKey:@"cart"], NSDictionary))
    {
        checkout.cart = [RICart parseCart:[checkoutObject objectForKey:@"cart"]];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"billingForm"], NSDictionary))
    {
        checkout.billingAddressForm = [RIForm parseForm:[checkoutObject objectForKey:@"billingForm"]];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"shippingForm"], NSDictionary))
    {
        checkout.shippingAddressForm = [RIForm parseForm:[checkoutObject objectForKey:@"shippingForm"]];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"shippingMethodForm"], NSDictionary))
    {
        checkout.shippingMethodForm = [RIShippingMethodForm parseForm:[checkoutObject objectForKey:@"shippingMethodForm"]];
    }
    
    //    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"paymentMethodForm"], NSDictionary))
    //    {
    //        checkout.paymentMethodForm = [RIPaymentMethodForm parseForm:[checkoutObject objectForKey:@"paymentMethodForm"]];
    //    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"next_step"], NSString))
    {
        checkout.nextStep = [checkoutObject objectForKey:@"next_step"];
    }
    
    return checkout;
}

@end
