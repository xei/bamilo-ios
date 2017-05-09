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
    NSString *orderStatus = [dict objectForKey:@"status"];
    if (!orderStatus.length && [dict objectForKey:@"status"]) {
        orderStatus = dict[@"status"][@"name"];
    }
    
    if(orderStatus.length) {
        self.orderStatus = [self statusTypeFromString:orderStatus];
    }
    
    return YES;
}

#pragma mark - Helpers
-(int) statusTypeFromString:(NSString *)statusString {
    if([statusString isEqualToString:@"new"]) {
        return OrderStatusTypeNew;
    } else if([statusString isEqualToString:@"order_verification_pending"]) {
        return OrderStatusVerificationPending;
    } else if([statusString isEqualToString:@"order_verification_in_progress"]) {
        return OrderStatusTypeVerificationInProgress;
    } else if([statusString isEqualToString:@"exportable"]) { //3
        return OrderStatusTypeExportable;
    } else if([statusString isEqualToString:@"exported"]) { //4
        return OrderStatusTypeExported;
    } else if([statusString isEqualToString:@"shipped"]) {
        return OrderStatusTypeShipped;
    } else if([statusString isEqualToString:@"delivered"]) {
        return OrderStatusTypeDelivered;
    } else if([statusString isEqualToString:@"delivery_failed"]) { //3
        return OrderStatusTypeDeliveryFailed;
    } else if([statusString isEqualToString:@"closed"]) { //4
        return OrderStatusTypeClosed;
    } else if([statusString isEqualToString:@"returned"]) {
        return OrderStatusTypeReturned;
    } else if([statusString isEqualToString:@"replaced"]) {
        return OrderStatusTypeReplaced;
    } else if([statusString isEqualToString:@"return_denied"]) { //3
        return OrderStatusTypeReturnDenied;
    } else if([statusString isEqualToString:@"refunded_after_return"]) { //4
        return OrderStatusTypeRefundedAfterReturn;
    } else if([statusString isEqualToString:@"canceled"]) { //4
        return OrderStatusTypeCanceled;
    }
    
    return -1;
}

@end
