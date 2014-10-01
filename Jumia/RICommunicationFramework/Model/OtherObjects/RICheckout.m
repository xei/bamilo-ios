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
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_BILLING_ADDRESS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  
                                                              }];
                                                              
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
                    parameters:(NSDictionary*)parameters
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [RIForm sendForm:form parameters:parameters successBlock:^(id object) {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            if(VALID_NOTEMPTY(object, NSDictionary))
            {
                successBlock([RICheckout parseCheckout:object country:configuration]);
            } else
            {
                failureBlock(nil);
            }
        } andFailureBlock:^(id errorMessages) {
            failureBlock(nil);
        }];
    } andFailureBlock:failureBlock];
}

+ (NSString*)getShippingAddressFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_SHIPPING_ADDRESS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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
                     parameters:(NSDictionary*)parameters
                   successBlock:(void (^)(RICheckout *checkout))successBlock
                andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [RIForm sendForm:form successBlock:^(id object) {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            if(VALID_NOTEMPTY(object, NSDictionary))
            {
                successBlock([RICheckout parseCheckout:object country:configuration]);
            } else
            {
                failureBlock(nil);
            }
        } andFailureBlock:^(id errorMessages) {
            failureBlock(nil);
        }];
    } andFailureBlock:failureBlock];
}

+ (NSString*)getShippingMethodFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_SHIPPING_METHODS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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
                    parameters:(NSDictionary*)parameters
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:form.action]
                                                            parameters:parameters
                                                        httpMethodPost:isPostRequest
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_PAYMENT_METHODS_FORM]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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

+ (NSString*)setPaymentMethod:(RIPaymentMethodForm *)form
                   parameters:(NSDictionary*)parameters
                 successBlock:(void (^)(RICheckout *checkout))successBlock
              andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:form.action]
                                                            parameters:parameters
                                                        httpMethodPost:isPostRequest
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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

+ (NSString*)finishCheckoutWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                            andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_FINISH_CHECKOUT]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  if(VALID_NOTEMPTY(jsonObject, NSDictionary) && VALID_NOTEMPTY([jsonObject objectForKey:@"metadata"], NSDictionary))
                                                                  {
                                                                      successBlock([RICheckout parseCheckout:[jsonObject objectForKey:@"metadata"] country:configuration]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
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

+ (NSString*)getConversionRate:(void (^)(CGFloat rate))returnBlock
{
    __block NSString *operationID = [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        
        NSURL *rateConversionURL = [NSURL URLWithString:[NSString stringWithFormat:RI_RATE_CONVERSION, configuration.currencyIso]];
        
        operationID = [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:rateConversionURL
                                                                       parameters:nil
                                                                   httpMethodPost:NO
                                                                        cacheType:RIURLCacheNoCache
                                                                        cacheTime:RIURLCacheNoTime
                                                                     successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                                         if(VALID_NOTEMPTY(jsonObject, NSDictionary) && [jsonObject objectForKey:@"rate"])
                                                                         {
                                                                             returnBlock([[jsonObject objectForKey:@"rate"] floatValue]);
                                                                         }
                                                                         else
                                                                         {
                                                                             returnBlock(0.0f);
                                                                         }
                                                                     } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObjectt) {
                                                                         returnBlock(0.0f);
                                                                     }];
    } andFailureBlock:^(NSArray *errorMessages) {
        returnBlock(0.0f);
    }];
    return operationID;
}

#pragma mark - Cancel request

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Private methods
+ (RICheckout*)parseCheckout:(NSDictionary*)checkoutObject country:(RICountryConfiguration*)country
{
    RICheckout *checkout = [[RICheckout alloc] init];
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"order"], NSDictionary))
    {
        checkout.orderSummary = [RIOrder parseOrder:[checkoutObject objectForKey:@"order"]];
    }
    
    if (VALID_NOTEMPTY([checkoutObject objectForKey:@"cart"], NSDictionary))
    {
        checkout.cart = [RICart parseCart:[checkoutObject objectForKey:@"cart"] country:country];
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
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"paymentMethodForm"], NSDictionary))
    {
        checkout.paymentMethodForm = [RIPaymentMethodForm parseForm:[checkoutObject objectForKey:@"paymentMethodForm"]];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"next_step"], NSString))
    {
        checkout.nextStep = [checkoutObject objectForKey:@"next_step"];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"order_nr"], NSString))
    {
        checkout.orderNr = [checkoutObject objectForKey:@"order_nr"];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"customer_first_name"], NSString))
    {
        checkout.customerFirstMame = [checkoutObject objectForKey:@"customer_first_name"];
    }
    
    if(VALID_NOTEMPTY([checkoutObject objectForKey:@"customer_last_name"], NSString))
    {
        checkout.customerLastName = [checkoutObject objectForKey:@"customer_last_name"];
    }
    
    if([checkoutObject objectForKey:@"payment"])
    {
        checkout.paymentInformation = [RIPaymentInformation parsePaymentInfo:[checkoutObject objectForKey:@"payment"]];
    }
    
    return checkout;
}

@end
