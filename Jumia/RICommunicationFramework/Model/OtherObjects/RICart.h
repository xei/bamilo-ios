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
@property (strong, nonatomic) NSNumber *cartCleanValue;
@property (strong, nonatomic) NSNumber *couponMoneyValue;
@property (strong, nonatomic) NSNumber *extraCosts;
@property (strong, nonatomic) NSNumber *shippingValue;
@property (strong, nonatomic) NSNumber *vatValue;
@property (strong, nonatomic) NSNumber *sumCosts;
@property (strong, nonatomic) NSNumber *sumCostsValue;
@property (strong, nonatomic) NSArray *priceRules;

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
                     andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

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
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 *  Method to get the cart data
 *
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the string with the code to cancel the request
 */
+ (NSString *)getCartWithSuccessBlock:(void (^)(RICart *cartData))sucessBlock
                      andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 *  Method to get the cart change information
 *
 *  @param a dictionary with the sku / new quantity. If nil the request will clean the cart.
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the tsring with the code to cancel the request
 */
+ (NSString *) changeQuantityInProducts:(NSDictionary *)productsQuantities
                       withSuccessBlock:(void (^)(RICart *cart))sucessBlock
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
