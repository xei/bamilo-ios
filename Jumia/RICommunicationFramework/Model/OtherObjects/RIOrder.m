//
//  RIOrder.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"

@implementation RIStatus

@end

@implementation RIItemCollection

@end

@implementation RITrackOrder

@end

@implementation RIOrder

+ (RIOrder*)parseOrder:(NSDictionary*)orderObject
{
    RIOrder *order = [[RIOrder alloc] init];
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"grand_total"], NSNumber)) {
        order.grandTotal = [orderObject objectForKey:@"grand_total"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"shipping_amount"], NSNumber)) {
        order.shippingAmount = [orderObject objectForKey:@"shipping_amount"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"extra_payment_cost"], NSNumber)) {
        order.extraCost = [orderObject objectForKey:@"extra_payment_cost"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"installment_fees"], NSNumber)) {
        order.installmentFees = [orderObject objectForKey:@"installment_fees"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"tax_amount"], NSNumber)) {
        order.taxAmount = [orderObject objectForKey:@"tax_amount"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"customer_device"], NSString)) {
        order.customerDevice = [orderObject objectForKey:@"customer_device"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"discount"], NSNumber)) {
        order.discountCouponValue = [orderObject objectForKey:@"discount"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"coupon_code"], NSString)) {
        order.discountCouponCode = [orderObject objectForKey:@"coupon_code"];
    }
    
    NSString *shippingMethod = @"";
    if (VALID_NOTEMPTY([orderObject objectForKey:@"shipping_method"], NSDictionary)) {
        NSDictionary *shippingMethodObject = [orderObject objectForKey:@"shipping_method"];
        if (VALID_NOTEMPTY([shippingMethodObject objectForKey:@"method"], NSString)) {
            shippingMethod = [shippingMethodObject objectForKey:@"method"];
        }
    }
    order.shippingMethod = shippingMethod;
    
    NSString *paymentMethod = @"";
    if (VALID_NOTEMPTY([orderObject objectForKey:@"payment_method"], NSDictionary)) {
        NSDictionary *paymentMethodObject = [orderObject objectForKey:@"payment_method"];
        if (VALID_NOTEMPTY([paymentMethodObject objectForKey:@"provider"], NSString)) {
            paymentMethod = [paymentMethodObject objectForKey:@"provider"];
        }
    }
    if (VALID_NOTEMPTY([orderObject objectForKey:@"payment_method"], NSString))
    {
        paymentMethod = [orderObject objectForKey:@"payment_method"];
    }
    order.paymentMethod = paymentMethod;
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"billing_address"], NSDictionary))
    {
        order.billingAddress = [RIAddress parseAddress:[orderObject objectForKey:@"billing_address"]];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"shipping_address"], NSDictionary))
    {
        order.shippingAddress = [RIAddress parseAddress:[orderObject objectForKey:@"shipping_address"]];
    }
    
    return order;
}

+ (NSString *)trackOrderWithOrderNumber:(NSString *)orderNumber
                       WithSuccessBlock:(void (^)(RITrackOrder *trackingOrder))successBlock
                        andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(orderNumber, NSString))
    {
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, [NSString stringWithFormat:RI_API_TRACK_ORDER, orderNumber]]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               NSDictionary *dic = [jsonObject objectForKey:@"metadata"];
                               
                               successBlock([RIOrder parseTrackOrder:dic]);
                           });
                           
                       } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(NOTEMPTY(errorJsonObject))
                               {
                                   failureBlock([RIError getErrorMessages:errorJsonObject]);
                               } else if(NOTEMPTY(errorObject))
                               {
                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                   failureBlock(errorArray);
                               } else
                               {
                                   failureBlock(nil);
                               }
                           });
                       }];
    } else {
        failureBlock(nil);
    }
    
    return operationID;
}

#pragma mark - Track order parsers

+ (RITrackOrder *)parseTrackOrder:(NSDictionary *)json
{
    RITrackOrder *trackOrder = [[RITrackOrder alloc] init];
    
    if ([json objectForKey:@"order_id"]) {
        trackOrder.orderId = [json objectForKey:@"order_id"];
    }
    
    if ([json objectForKey:@"creation_date"]) {
        trackOrder.creationDate = [json objectForKey:@"creation_date"];
    }
    
    if ([json objectForKey:@"last_order_update"]) {
        trackOrder.lastOrderUpdate = [json objectForKey:@"last_order_update"];
    }
    
    if ([json objectForKey:@"payment_method"]) {
        trackOrder.paymentMethod = [json objectForKey:@"payment_method"];
    }
    
    if ([json objectForKey:@"item_collection"]) {
        NSDictionary *tempDic = [json objectForKey:@"item_collection"];
        
        NSMutableArray *itemArray = [NSMutableArray new];
        
        for (NSString *string in tempDic) {
            NSDictionary *temp = [tempDic objectForKey:string];
            [itemArray addObject:[RIOrder parseItemCollection:temp]];
        }
        
        trackOrder.itemCollection = [itemArray copy];
    }
    
    return trackOrder;
}

+ (RIItemCollection *)parseItemCollection:(NSDictionary *)json
{
    RIItemCollection *item = [[RIItemCollection alloc] init];
    
    if ([json objectForKey:@"sku"]) {
        item.sku = [json objectForKey:@"sku"];
    }
    
    if ([json objectForKey:@"name"]) {
        item.name = [json objectForKey:@"name"];
    }
    
    if ([json objectForKey:@"quantity"]) {
        item.quantity = [json objectForKey:@"quantity"];
    }
    
    if ([json objectForKey:@"status"]) {
        NSArray *tempArray = [json objectForKey:@"status"];
        
        NSMutableArray *statusArray = [NSMutableArray new];
        
        for (NSDictionary *dic in tempArray) {
            [statusArray addObject:[RIOrder parseStatus:dic]];
        }
        
        item.status = [statusArray copy];
    }
    
    return item;
}

+ (RIStatus *)parseStatus:(NSDictionary *)json
{
    RIStatus *status = [[RIStatus alloc] init];
    
    if ([json objectForKey:@"item_status"]) {
        status.itemStatus = [json objectForKey:@"item_status"];
    }
    
    if ([json objectForKey:@"last_status_change"]) {
        status.lastChangeStatus = [json objectForKey:@"last_status_change"];
    }
    
    return status;
}

@end
