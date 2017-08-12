//
//  RICart.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONVerboseModel.h"
#import "CartEntity.h"
#import "FormEntity.h"
#import "RICustomer.h"
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

@interface RICart : NSObject <JSONVerboseModel>

@property (strong, nonatomic) CartEntity *cartEntity;
@property (strong, nonatomic) FormEntity *formEntity;
@property (strong, nonatomic) RICustomer *customerEntity;

@property (strong, nonatomic) NSNumber *totalNumberOfOrders;
@property (nonatomic, strong) NSString *nextStep;
@property (nonatomic, strong) RIForm *addressForm;

//CHECKOUT FINISH
@property (nonatomic, copy) NSString *orderNr;
@property (nonatomic, copy) NSString *customerFirstMame;
@property (nonatomic, copy) NSString *customerLastName;
@property (nonatomic, copy) NSString *estimatedDeliveryTime;
@property (nonatomic, strong) RIPaymentInformation *paymentInformation;

+ (instancetype)sharedInstance;

- (NSArray<EMCartItem *> *)convertItems;

/**
 *  Method to add a product to the cart
 *
 *  @param the quantity that will be added
 *  @param the simple product sku (format: SH660AAAC1MWNGAMZ-177254)
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
//+ (NSString *)addProductWithQuantity:(NSString *)quantity simpleSku:(NSString *)simpleSku withSuccessBlock:(void (^)(RICart *cart, RIApiResponse apiResponse, NSArray *successMessage))sucessBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to add multiple products to the cart
 *
 *  @param an array of products to add (format: each element of this array should be a string representing the simple sku to add)
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)addMultipleProducts:(NSArray *)productsToAdd
                 withSuccessBlock:(void (^)(RICart *cart, NSArray *productsNotAdded))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock))failureBlock;

/**
 *  Method to add multiple products from a bundle to the cart
 *
 *  @param an array of products simple skus to add
 *  @param the id of the bundle
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)addBundleProductsWithSimpleSkus:(NSArray *)simpleSkus
                                     bundleId:(NSString *)bundleId
                             withSuccessBlock:(void (^)(RICart *cart, NSArray *productsNotAdded))sucessBlock
                              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock))failureBlock;


/**
 *  Method to remove product from cart
 *
 *  @param the product sku
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)removeProductWithSku:(NSString *)sku
                  withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to get the cart data
 *
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)getCartWithSuccessBlock:(void (^)(RICart *cartData))sucessBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to get the cart change information
 *
 *  @param a dictionary with the sku / new quantity. If nil the request will clean the cart.
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *) changeQuantityInProducts:(NSDictionary *)productsQuantities
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to clear the cart data
 */
+ (NSString *) resetCartWithSuccessBlock:(void (^)(void))sucessBlock
                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to add voucher information
 *
 *  @param the voucher code
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *) addVoucherWithCode:(NSString *)voucherCode
                 withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to remove voucher information
 *
 *  @param the voucher code
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *) removeVoucherWithCode:(NSString *)voucherCode
                    withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+ (RICart *)parseCart:(NSDictionary *)json country:(RICountryConfiguration*)country;

/**
 * Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;


+(NSString*)getMultistepAddressWithSuccessBlock:(void (^)(RICart *cart, RICustomer *customer))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepAddressForShipping:(NSString*)shippingAddressId
                                   billing:(NSString*)billingAddressId
                              successBlock:(void (^)(NSString* nextStep))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+(NSString*)getMultistepShippingWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepShippingForShippingMethod:(NSString*)shippingMethod
                                    pickupStation:(NSString*)pickupStation
                                           region:(NSString*)region
                                     successBlock:(void (^)(NSString* nextStep))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+(NSString*)getMultistepPaymentWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepPayment:(NSDictionary*)parameters
                   successBlock:(void (^)(NSString* nextStep))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;


+(NSString*)getMultistepFinishWithSuccessBlock:(void (^)(RICart *cart))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepFinishForCart:(RICart*)cart
                     withSuccessBlock:(void (^)(RICart* cart, NSString *rrStringTarget))successBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

//##########################################################################################
+ (RICart *)parseCheckoutFinish:(NSDictionary*)json forCart:(RICart*)cart;

@end
