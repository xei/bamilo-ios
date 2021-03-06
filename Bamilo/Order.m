//
//  Order.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Order.h"

#define OrderRegisteredAPIStatusesPredicate [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"new", @"payment_pending", @"order_verification_pending", @"order_verification_in_progress"]]
#define OrderInProgressAPIStatusesPredicate [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"exportable", @"exported"]]
#define OrderShippedAPIStatusesPredicate [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"shipped"]]
#define OrderDeliveredAPIStatusesPredicate [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"delivered"]]
#define OrderCancelledAPIStatusesPredicate [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"canceled", @"invalid", @"canceled_before_payment", @"incomplete"]]

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
        return [priceString formatPriceWithCurrency];
    }
    return nil;
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    
    [self.products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mergeFromDictionary:[dict objectForKey:@"products"][idx] useKeyMapping:YES error:nil];
    }];
    
    if (VALID_NOTEMPTY([dict objectForKey:@"order_number"], NSString)) {
        self.orderId = [dict objectForKey:@"order_number"];
    }
    if (VALID_NOTEMPTY([dict objectForKey:@"creation_date"], NSString) || VALID_NOTEMPTY([dict objectForKey:@"date"], NSString)) {
        NSString *dateString = [dict objectForKey:@"creation_date"] ?: [dict objectForKey:@"date"];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat: [dict objectForKey:@"creation_date"] ? @"yyyy-MM-dd HH:mm:ss" : @"yyyy-MM-dd"];
        self.creationDate = [df dateFromString:dateString];
    }
    if (VALID_NOTEMPTY([dict objectForKey:@"grand_total"], NSNumber)) {
        self.price = [[dict objectForKey:@"grand_total"] longLongValue];
    }
    
    if ([dict objectForKey:@"payment"]) {
        if (VALID_NOTEMPTY([[dict objectForKey:@"payment"] objectForKey:@"label"], NSString)) {
            self.paymentMethod = [[dict objectForKey:@"payment"] objectForKey:@"label"];
        }
        if (VALID_NOTEMPTY([[dict objectForKey:@"payment"] objectForKey:@"txnref"], NSString)) {
            self.paymentReference = [[dict objectForKey:@"payment"] objectForKey:@"txnref"];
        }
        if (VALID_NOTEMPTY([[dict objectForKey:@"payment"] objectForKey:@"status_description"], NSString)) {
            self.paymentDescription = [[dict objectForKey:@"payment"] objectForKey:@"status_description"];
        }
    }
    
    if([dict objectForKey:@"status"]) {
        self.orderStatus = [self mapServiceStatusTypeFromString:[dict objectForKey:@"status"]];
    } else {
        NSString *productStatus = [self getStatusFromProductStatus:dict];
        if(productStatus) {
            self.orderStatus = [self mapServiceStatusTypeFromString:productStatus];
        } else {
            NSArray *products = [dict objectForKey:@"products"];
            int _max_status = 99;
            for(NSDictionary *product in products) {
                productStatus = [self getStatusFromProductStatus:product];
                if(productStatus) {
                    _max_status = MIN(_max_status, [self mapServiceStatusTypeFromString:productStatus]);
                }
            }
            self.orderStatus = _max_status;
        }
    }
    
    return YES;
}

#pragma mark - Helpers
-(NSString *)getStatusFromProductStatus:(NSDictionary *)product {
    NSDictionary *productStatus = [product objectForKey:@"status"];
    if(productStatus) {
        return [productStatus objectForKey:@"name"];
    }
    
    return nil;
}

-(int) mapServiceStatusTypeFromString:(NSString *)statusString {
    if([OrderRegisteredAPIStatusesPredicate evaluateWithObject:statusString]) {
        return OrderStatusRegistered;
    } else if([OrderInProgressAPIStatusesPredicate evaluateWithObject:statusString]) {
        return OrderStatusInProgress;
    } else if([OrderShippedAPIStatusesPredicate evaluateWithObject:statusString]){
        return OrderStatusShipped;
    } else if([OrderDeliveredAPIStatusesPredicate evaluateWithObject:statusString]) {
        return OrderStatusDelivered;
    } else if([OrderCancelledAPIStatusesPredicate evaluateWithObject:statusString]) {
        return OrderStatusCancelled;
    }
    
    return 99; //Ignore
}

@end

