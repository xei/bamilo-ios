//
//  RIOrder.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICart.h"
#import "RIAddress.h"

// My Orders Objects
@interface RITrackOrder : NSObject

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *creationDate;
@property (strong, nonatomic) NSString *lastOrderUpdate;
@property (strong, nonatomic) NSString *paymentMethod;
@property (strong, nonatomic) NSString *paymentDescription;
@property (strong, nonatomic) NSString *paymentReference;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) NSString *totalFormatted;
@property (strong, nonatomic) NSArray *itemCollection;
@property (nonatomic, strong) RIAddress *shippingAddress;
@property (nonatomic, strong) RIAddress *billingAddress;

@end

@interface RIItemCollection : NSObject

@property (strong, nonatomic) NSString *sku;
@property (strong, nonatomic) NSString *brand;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSNumber *total;
@property (strong, nonatomic) NSString *totalFormatted;
@property (strong, nonatomic) NSString *delivery;
@property (strong, nonatomic) NSString *statusLabel;
@property (strong, nonatomic) NSString *statusDate;

@property (strong, nonatomic) NSArray *returns;
@property (assign, nonatomic) BOOL onlineReturn;
@property (assign, nonatomic) BOOL callReturn;
@property (strong, nonatomic) NSString *onlineReturnTargetString;
@property (strong, nonatomic) NSNumber *returnableQty;
@property (strong, nonatomic) NSString *callReturnTextBody1;
@property (strong, nonatomic) NSString *callReturnTextBody2;
@property (strong, nonatomic) NSString *callReturnTextTitle;

@end

@interface RIStatus : NSObject

@property (nonatomic, strong) NSString *itemStatus;
@property (nonatomic, strong) NSString *lastChangeStatus;

@end

@interface RIReturnAction : NSObject

@property (nonatomic, strong) NSNumber *items;
@property (nonatomic, strong) NSString *lastChangeStatus;

+ (RIReturnAction *)parseReturnAction:(NSDictionary *)json;

@end

// Checkout Order Object
@interface RIOrder : NSObject

@property (nonatomic, strong) NSNumber *grandTotal;
@property (nonatomic, strong) NSNumber *grandTotalEuroConverted;
@property (nonatomic, strong) NSNumber *shippingAmount;
@property (nonatomic, strong) NSNumber *extraCost;
@property (nonatomic, strong) NSNumber *installmentFees;
@property (nonatomic, strong) NSNumber *taxAmount;
@property (nonatomic, strong) NSString *customerDevice;
@property (nonatomic, strong) NSNumber *discountCouponValue;
@property (nonatomic, strong) NSString *discountCouponCode;
@property (nonatomic, strong) NSString *shippingMethod;
@property (nonatomic, strong) NSString *paymentMethod;
@property (nonatomic, strong) RIAddress *shippingAddress;
@property (nonatomic, strong) RIAddress *billingAddress;

+ (RIOrder*)parseOrder:(NSDictionary*)orderObject;

/**
 * Method to get the list of orders of the user
 *
 * @param the page number
 * @param the max items
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 *
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getOrdersPage:(NSNumber*)page
                   maxItems:(NSNumber*)maxItems
           withSuccessBlock:(void (^)(NSArray *orders, NSInteger ordersTotal))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 * Method to track an order
 *
 * @param the order number
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 *
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)trackOrderWithOrderNumber:(NSString *)orderNumber
                       WithSuccessBlock:(void (^)(RITrackOrder *trackingOrder))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

@end
