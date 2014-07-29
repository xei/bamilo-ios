//
//  RICheckout.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIOrder.h"
#import "RIForm.h"
#import "RIShippingMethodForm.h"
#import "RIPaymentMethodForm.h"
#import "RIPaymentInformation.h"

@interface RICheckout : NSObject

@property (nonatomic, strong) RIOrder *orderSummary;
@property (nonatomic, strong) RICart *cart;
@property (nonatomic, strong) NSString *nextStep;
@property (nonatomic, strong) RIForm *shippingAddressForm;
@property (nonatomic, strong) RIForm *billingAddressForm;
@property (nonatomic, strong) RIShippingMethodForm *shippingMethodForm;
@property (nonatomic, strong) RIPaymentMethodForm *paymentMethodForm;
@property (nonatomic, strong) NSString *orderNr;
@property (nonatomic, strong) NSString *customerFirstMame;
@property (nonatomic, strong) NSString *customerLastName;
@property (nonatomic, strong) RIPaymentInformation *paymentInformation;

/**
 * Method to get the billing address form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getBillingAddressFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to set the billing address needed for checkout process
 *
 * @param the billing address form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setBillingAddress:(RIForm*)form
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to get the shipping address form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getShippingAddressFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to set the shipping address needed for checkout process
 *
 * @param the shipping address form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setShippingAddress:(RIForm*)form
                   successBlock:(void (^)(RICheckout *checkout))successBlock
                andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;


/**
 * Method to get the shipping method form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getShippingMethodFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to set the shipping method needed for checkout process
 *
 * @param the shipping method form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setShippingMethod:(RIShippingMethodForm*)form
                  successBlock:(void (^)(RICheckout *checkout))successBlock
               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to get the payment method form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getPaymentMethodFormWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                                  andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to set the payment method needed for checkout process
 *
 * @param the payment method form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setPaymentMethod:(RIPaymentMethodForm *)form
                 successBlock:(void (^)(RICheckout *checkout))successBlock
              andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to end the checkout proccess
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)finishCheckoutWithSuccessBlock:(void (^)(RICheckout *checkout))successBlock
                            andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID that was returned by the getCountriesWithSuccessBlock:andFailureBlock method
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
