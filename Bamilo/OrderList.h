//
//  OrderList.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "Order.h"

@interface OrderList : BaseModel
@property (nonatomic) NSInteger totalOrdersCount;
@property (nonatomic, strong) NSArray<Order>* orders;
@end
