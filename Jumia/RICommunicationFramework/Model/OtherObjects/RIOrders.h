//
//  RIOrders.h
//  Jumia
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICartData : NSObject

@property (strong, nonatomic) NSNumber *cartCleanValue;
@property (strong, nonatomic) NSNumber *cartCount;
@property (strong, nonatomic) NSArray *cartItems;
@property (strong, nonatomic) NSNumber *cartValue;
@property (strong, nonatomic) NSNumber *couponMoneyValue;
@property (strong, nonatomic) NSNumber *extraCosts;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *priceRules;
@property (strong, nonatomic) NSNumber *shippingValue;
@property (strong, nonatomic) NSNumber *sumCosts;
@property (strong, nonatomic) NSNumber *sumCostsValue;
@property (strong, nonatomic) NSNumber *vatValue;

@end

@interface RIOrders : NSObject

/**
 *  Method to add an order in the cart
 *
 *  @param the quantity that will be added
 *  @param the simple product sku (format: SH660AAAC1MWNGAMZ-177254)
 *  @param the product sku
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the sring with the code to cancel the request
 */
+ (NSString *)addOrderWithCartQuantity:(NSString *)quantity
                                   sku:(NSString *)sku
                                simple:(NSString *)simple
                      withSuccessBlock:(void (^)())sucessBlock
                       andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 *  Method to get the cart data
 *
 *  @param the success block
 *  @param the error block that contains the error case the operation fails
 *
 *  @return the sring with the code to cancel the request
 */
+ (NSString *)getCartDataWithSuccessBlock:(void (^)(RICartData *cartData))sucessBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
