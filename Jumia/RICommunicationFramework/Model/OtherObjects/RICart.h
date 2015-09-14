//
//  RICart.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 *  @param the product sku
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)addProductWithQuantity:(NSString *)quantity
                                 sku:(NSString *)sku
                              simple:(NSString *)simple
                    withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                     andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to add multiple products to the cart
 *
 *  @param an array of products to add (format: each element of this array should contain a dictionary with three keys quantity, p and simple)
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)addProductsWithQuantity:(NSArray *)productsToAdd
                     withSuccessBlock:(void (^)(RICart *cart, NSArray *productsNotAdded))sucessBlock
                      andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock))failureBlock;

/**
 *  Method to add multiple products from a bundle to the cart
 *
 *  @param an array of products skus to add
 *  @param an array of products simple skus to add
 *  @param the id of the bundle
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)addBundleProductsWithSkus:(NSArray *)productSkus
                             simpleSkus:(NSArray *)simpleSkus
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

@end
