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

@protocol Order;

@interface Order : BaseModel
@property (copy, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSDate *creationDate;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *formattedPrice;

@property (copy, nonatomic) NSString *paymentMethod;
@property (copy, nonatomic) NSString *paymentDescription;
@property (copy, nonatomic) NSString *paymentReference;
@property (strong, nonatomic) NSArray<OrderProduct> *products;
@property (nonatomic, strong) Address *shippingAddress;
@property (nonatomic, strong) Address *billingAddress;
@end
