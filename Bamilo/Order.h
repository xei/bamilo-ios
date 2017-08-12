//
//  Order.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "OrderProduct.h"
#import "Address.h"

typedef NS_ENUM(NSUInteger, OrderStatusType) {
    OrderStatusRegistered = 1,
    OrderStatusInProgress = 2,
    OrderStatusShipped = 3,
    OrderStatusDelivered= 4,
    OrderStatusCancelled = 5
};

@interface Order : BaseModel
@property (copy, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSDate *creationDate;
@property (nonatomic) long long price;
@property (copy, nonatomic) NSString *formattedPrice;

@property (copy, nonatomic) NSString *paymentMethod;
@property (copy, nonatomic) NSString *paymentDescription;
@property (copy, nonatomic) NSString *paymentReference;
@property (strong, nonatomic) NSArray<OrderProduct> *products;
@property (nonatomic, strong) Address *shippingAddress;
@property (nonatomic, strong) Address *billingAddress;
@property (assign, nonatomic) OrderStatusType orderStatus;
@property (nonatomic, copy) NSString *translatedStringOrderStatus;

@end
