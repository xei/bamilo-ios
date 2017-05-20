//
//  OrderProduct.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"

@interface OrderStatus : BaseModel

@property (copy, nonatomic) NSString *label;
@property (copy, nonatomic) NSString *updateAt;

@end

@interface OrderReturn : BaseModel

@property (copy, nonatomic) NSString *quantity;
@property (copy, nonatomic) NSString *date;

@end


@protocol OrderProductAction;
@interface OrderProductAction : BaseModel
@property (copy, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *returnableQty;
@end

@interface OrderProductOnlineReturnAction : OrderProductAction
@property (copy, nonatomic) NSString *targetString;
@end

@interface OrderProductCallReturnAction : OrderProductAction
@property (copy, nonatomic) NSString *callReturnTextBody1;
@property (copy, nonatomic) NSString *callReturnTextBody2;
@property (copy, nonatomic) NSString *callReturnTextTitle;
@end

@protocol OrderProduct;

@interface OrderProduct : BaseModel

@property (copy, nonatomic) NSString *sku;
@property (copy, nonatomic) NSString *brand;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSString *delivery;
@property (strong, nonatomic) OrderStatus *status;
@property (strong, nonatomic) NSArray<OrderReturn *> *returns;
@property (nonatomic) long long price;
@property (copy, nonatomic)   NSString *formatedPrice;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSMutableArray<OrderProductAction> *actions;

@end
