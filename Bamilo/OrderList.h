//
//  OrderList.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "Order.h"

@protocol Order;

@interface OrderList : BaseModel
@property (nonatomic) NSInteger totalOrdersCount;
@property (nonatomic, strong) NSMutableArray<Order>* orders;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totalPages;
@end
