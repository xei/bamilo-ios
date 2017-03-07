//
//  Order.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "OrderProduct.h"
#import "Address.h"

typedef NS_ENUM(NSUInteger, OrderStatusType) {
    ORDER_STATUS_NONE = -1,
    ORDER_STATUS_NEW_ORDER = 0,
    ORDER_STATUS_REGISTERED,
    ORDER_STATUS_IN_PROGRESS,
    ORDER_STATUS_DELIVERED
};

@interface Order : BaseModel
@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *creationDate;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *formatedPrice;

@property (strong, nonatomic) NSString *paymentMethod;
@property (strong, nonatomic) NSString *paymentDescription;
@property (strong, nonatomic) NSString *paymentReference;
@property (strong, nonatomic) NSArray<OrderProduct> *products;
@property (nonatomic, strong) Address *shippingAddress;
@property (nonatomic, strong) Address *billingAddress;
@property (assign, nonatomic) OrderStatusType status;
@end
