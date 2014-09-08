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

@interface RIStatus : NSObject

@property (nonatomic, strong) NSString *itemStatus;
@property (nonatomic, strong) NSString *lastChangeStatus;

@end

@interface RIItemCollection : NSObject

@property (strong, nonatomic) NSString *sku;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSArray *status;

@end

@interface RITrackOrder : NSObject

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *creationDate;
@property (strong, nonatomic) NSString *lastOrderUpdate;
@property (strong, nonatomic) NSString *paymentMethod;
@property (strong, nonatomic) NSArray *itemCollection;

@end

@interface RIOrder : NSObject

@property (nonatomic, strong) NSNumber *grandTotal;
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

+ (NSString *)trackOrderWithOrderNumber:(NSString *)orderNumber
                       WithSuccessBlock:(void (^)(RITrackOrder *trackingOrder))successBlock
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

@end
