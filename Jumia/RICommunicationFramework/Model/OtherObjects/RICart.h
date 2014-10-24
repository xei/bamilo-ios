//
//  RICart.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICart : NSObject

@property (strong, nonatomic) NSDictionary *cartItems; //!< Dictionary with simple sku : product information
@property (strong, nonatomic) NSNumber *cartCount;
@property (strong, nonatomic) NSNumber *cartValue;
@property (strong, nonatomic) NSString *cartValueFormatted;
@property (strong, nonatomic) NSNumber *cartValueEuroConverted;
@property (strong, nonatomic) NSNumber *cartUnreducedValue;
@property (strong, nonatomic) NSString *cartUnreducedValueFormatted;
@property (strong, nonatomic) NSNumber *cartCleanValue;
@property (strong, nonatomic) NSString *cartCleanValueFormatted;
@property (strong, nonatomic) NSNumber *cartCleanValueEuroConverted;
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
@property (strong, nonatomic) NSNumber *sumCosts;
@property (strong, nonatomic) NSNumber *sumCostsEuroConverted;
@property (strong, nonatomic) NSNumber *sumCostsValue;
@property (strong, nonatomic) NSNumber *sumCostsValueEuroConverted;
@property (strong, nonatomic) NSDictionary *priceRules;

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
