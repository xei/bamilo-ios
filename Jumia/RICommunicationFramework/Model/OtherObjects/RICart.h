//
//  RICart.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIShippingMethodForm, RIPaymentMethodForm, RIPaymentInformation,
    RIAddress, RIForm, RISellerDelivery, RICustomer;

@interface RICart : NSObject

@property (strong, nonatomic) NSArray *cartItems;
@property (strong, nonatomic) NSNumber *cartCount;
@property (strong, nonatomic) NSNumber *cartValue;
@property (strong, nonatomic) NSString *cartValueFormatted;
@property (strong, nonatomic) NSNumber *cartValueEuroConverted;
@property (strong, nonatomic) NSNumber *cartUnreducedValue;
@property (strong, nonatomic) NSString *cartUnreducedValueFormatted;
@property (strong, nonatomic) NSString *couponCode;
@property (strong, nonatomic) NSNumber *couponMoneyValue;
@property (strong, nonatomic) NSString *couponMoneyValueFormatted;
@property (strong, nonatomic) NSNumber *couponMoneyValueEuroConverted;
@property (strong, nonatomic) NSNumber *extraCosts;
@property (strong, nonatomic) NSString *extraCostsFormatted;
@property (strong, nonatomic) NSNumber *extraCostsEuroConverted;
@property (strong, nonatomic) NSNumber *shippingValue;
@property (strong, nonatomic) NSString *shippingValueFormatted;
@property (strong, nonatomic) NSNumber *shippingValueEuroConverted;
@property (strong, nonatomic) NSNumber *vatValue;
@property (strong, nonatomic) NSString *vatValueFormatted;
@property (strong, nonatomic) NSNumber *vatValueEuroConverted;
@property (strong, nonatomic) NSNumber *vatLabelEnabled;
@property (strong, nonatomic) NSString *vatLabel;
@property (strong, nonatomic) NSNumber *sumCosts;
@property (strong, nonatomic) NSNumber *sumCostsEuroConverted;
@property (strong, nonatomic) NSNumber *sumCostsValue;
@property (strong, nonatomic) NSNumber *sumCostsValueEuroConverted;
@property (strong, nonatomic) NSDictionary *priceRules;
@property (strong, nonatomic) NSNumber *subTotal;
@property (strong, nonatomic) NSString *subTotalFormatted;

@property (nonatomic, strong) NSString *nextStep;
@property (nonatomic, strong) RIForm *addressForm;
@property (nonatomic, strong) RIShippingMethodForm *shippingMethodForm;
@property (nonatomic, strong) NSString *shippingMethod;
@property (nonatomic, strong) RIPaymentMethodForm *paymentMethodForm;
@property (nonatomic, strong) NSString *paymentMethod;
@property (nonatomic, strong) RIAddress *shippingAddress;
@property (nonatomic, strong) RIAddress *billingAddress;
@property (strong, nonatomic) NSArray* sellerDelivery;

//CHECKOUT FINISH
@property (nonatomic, strong) NSString *orderNr;
@property (nonatomic, strong) NSString *customerFirstMame;
@property (nonatomic, strong) NSString *customerLastName;
@property (nonatomic, strong) RIPaymentInformation *paymentInformation;

/**
 * new params (NOT USED)
 */
@property (strong, nonatomic) NSNumber *deliveryDiscountAmount;
@property (strong, nonatomic) NSNumber *deliveryDiscountAmountConverted;
@property (strong, nonatomic) NSNumber *deliveryDiscountCartRuleDiscount;
@property (strong, nonatomic) NSNumber *deliveryDiscountCartRuleDiscountConverted;
@property (strong, nonatomic) NSNumber *deliveryDiscountCouponMoneyValue;
@property (strong, nonatomic) NSNumber *deliveryDiscountCouponMoneyValueConverted;


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
+ (NSString *)addProductWithQuantity:(NSString *)quantity
                           simpleSku:(NSString *)simpleSku
                    withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

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
 *  @param the quantity that will be removed
 *  @param the product sku
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)removeProductWithQuantity:(NSString *)quantity
                                    sku:(NSString *)sku
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



//$$$ FROM CHECKOUT

/**
 * Method to get the address forms needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getCheckoutAddressFormsWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to set the addresses needed for checkout process
 *
 * @param the address form
 * @param the parameters to send along with the form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setCheckoutAddresses:(RIForm*)form
                       parameters:(NSDictionary*)parameters
                     successBlock:(void (^)(RICart *cart))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;


/**
 * Method to get the shipping method form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getShippingMethodFormWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to set the shipping method needed for checkout process
 *
 * @param the shipping method form
 * @param the parameters to send along with the form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setShippingMethod:(RIShippingMethodForm*)form
                    parameters:(NSDictionary*)parameters
                  successBlock:(void (^)(RICart *cart))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to get the payment method form needed for checkout process
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getPaymentMethodFormWithSuccessBlock:(void (^)(RICart *cart))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to set the payment method needed for checkout process
 *
 * @param the payment method form
 * @param the parameters to send along with the form
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)setPaymentMethod:(RIPaymentMethodForm *)form
                   parameters:(NSDictionary*)parameters
                 successBlock:(void (^)(RICart *cart))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to end the checkout proccess
 *
 * @param the cart that is finishing the checkout
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)finishCheckoutForCart:(RICart*)cart
                  withSuccessBlock:(void (^)(RICart *cart))successBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;


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

+(NSString*)getMultistepPaymentWithSuccessBlock:(void (^)(RICart *cart, RIPaymentMethodForm *paymentForm))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepPayment:(NSDictionary*)parameters
                   successBlock:(void (^)(NSString* nextStep))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;


+(NSString*)getMultistepFinishWithSuccessBlock:(void (^)(RICart *cart))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
+(NSString*)setMultistepFinishWithSuccessBlock:(void (^)(NSString* nextStep))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

@end
