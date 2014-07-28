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

@end
