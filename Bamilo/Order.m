//
//  Order.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Order.h"

@implementation Order
#pragma mark - JSONModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
          @"orderId":@"number",
          @"creationDate":@"date",
          @"price":@"total",
          @"formattedPrice":@"total",
          @"shippingAddress": @"shipping_address",
          @"billingAddress":@"billing_address",
          @"products":@"products",
          @"paymentReference":@"payment.transaction_reference",
          @"paymentDescription":@"payment.transaction_description",
          @"paymentMethod":@"payment.title"
    }];
}


- (NSString *)formattedPrice {
    if (self.price) {
        NSString *priceString = [NSString stringWithFormat:@"%lld", self.price];
        return [NSString stringWithFormat:@"%@ %@", [[priceString formatPrice] numbersToPersian], STRING_CURRENCY];
    }
    return nil;
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    
    [self.products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       [obj mergeFromDictionary:[dict objectForKey:@"products"][idx] useKeyMapping:YES error:nil];
    }];
    
    if ([dict objectForKey:@"order_number"]) {
        self.orderId = [dict objectForKey:@"order_number"];
    }
    if ([dict objectForKey:@"creation_date"] || [dict objectForKey:@"date"]) {
        NSString *dateString = [dict objectForKey:@"creation_date"] ?: [dict objectForKey:@"date"];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat: [dict objectForKey:@"creation_date"] ? @"yyyy-MM-dd HH:mm:ss" : @"yyyy-MM-dd"];
        self.creationDate = [df dateFromString:dateString];
    }
    if ([dict objectForKey:@"grand_total"]) {
        self.price = [[dict objectForKey:@"grand_total"] longLongValue];
    }
    
    if ([dict objectForKey:@"payment"]) {
        if ([[dict objectForKey:@"payment"] objectForKey:@"label"]) {
            self.paymentMethod = [[dict objectForKey:@"payment"] objectForKey:@"label"];
        }
        if ([[dict objectForKey:@"payment"] objectForKey:@"txnref"]) {
            self.paymentReference = [[dict objectForKey:@"payment"] objectForKey:@"txnref"];
        }
        if ([[dict objectForKey:@"payment"] objectForKey:@"status_description"]) {
            self.paymentDescription = [[dict objectForKey:@"payment"] objectForKey:@"status_description"];
        }
    }
    
    if(self.products.count) {
        self.orderStatus = [self getOrderStatusFromOrderProducts:self.products];
    }
    
    return YES;
}

#pragma mark - Helpers
-(OrderStatusType) getOrderStatusFromOrderProducts:(NSArray<OrderProduct> *)products {
    int currentOrderStep = 99;
    for(OrderProduct *product in products) {
        currentOrderStep = MIN(currentOrderStep, [self getStatusIndexFromStatusString:product.status.label]);
    }
    
    return (OrderStatusType)currentOrderStep;
}

-(int) getStatusIndexFromStatusString:(NSString *)statusString {
    if([statusString containsString:@"سفارش جدید"]) { //0
        return ORDER_STATUS_NEW_ORDER;
    } else if([statusString containsString:@"در حال پردازش"]) { //1
        return ORDER_STATUS_REGISTERED;
    } else if([statusString containsString:@"ارسال شد"]) { //2
        return ORDER_STATUS_IN_PROGRESS;
    } else if([statusString containsString:@"تحویل داده شد"]) { //3
        return ORDER_STATUS_DELIVERED;
    } else if([statusString containsString:@"لغو شده"]) { //4
        return ORDER_STATUS_CANCELLED;
    }
    
    return -1;
}

@end
