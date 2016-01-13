//
//  RIOrder.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"
#import "RICountryConfiguration.h"

@implementation RIStatus

+ (RIStatus *)parseStatus:(NSDictionary *)json
{
    RIStatus *status = [[RIStatus alloc] init];
    
    if(VALID_NOTEMPTY(json, NSDictionary))
    {
        if ([json objectForKey:@"label"]) {
            status.itemStatus = [json objectForKey:@"label"];
        }
        
        if ([json objectForKey:@"updated_at"]) {
            status.lastChangeStatus = [json objectForKey:@"updated_at"];
        }
    }
    
    return status;
}

@end

@implementation RIItemCollection

+ (RIItemCollection *)parseItemCollection:(NSDictionary *)json country:(RICountryConfiguration*)country
{
    RIItemCollection *item = [[RIItemCollection alloc] init];
    
    if (VALID([json objectForKey:@"sku"], NSString)) {
        item.sku = [json objectForKey:@"sku"];
    }
    
    if (VALID([json objectForKey:@"brand"], NSString)) {
        item.brand = [json objectForKey:@"brand"];
    }
    
    if (VALID([json objectForKey:@"name"], NSString)) {
        item.name = [json objectForKey:@"name"];
    }
    
    if (VALID([json objectForKey:@"quantity"], NSNumber)) {
        item.quantity = [json objectForKey:@"quantity"];
    }
    
    if (VALID([json objectForKey:@"image"], NSString)) {
        item.imageURL = [json objectForKey:@"image"];
    }
    
    if (VALID([json objectForKey:@"delivery"], NSString)) {
        item.delivery = [json objectForKey:@"delivery"];
    }
    
    if (VALID([json objectForKey:@"status"], NSDictionary)) {
        NSDictionary *tempDict = [json objectForKey:@"status"];
        RIStatus *status = [RIStatus parseStatus:tempDict];
        item.statusLabel = status.itemStatus;
        item.statusDate = status.lastChangeStatus;
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"price"], NSString))
    {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        item.total = [f numberFromString:[json objectForKey:@"price"]];
        
        item.totalFormatted = [RICountryConfiguration formatPrice:item.total country:country];
    }
    
    return item;
}

@end

@implementation RITrackOrder

#pragma mark - Track order parsers

+ (RITrackOrder *)parseDetailedTrackOrder:(NSDictionary *)json country:(RICountryConfiguration*)country
{
    RITrackOrder *trackOrder = [[RITrackOrder alloc] init];
    
    if ([json objectForKey:@"order_number"]) {
        trackOrder.orderId = [json objectForKey:@"order_number"];
    }
    
    if ([json objectForKey:@"creation_date"]) {
        trackOrder.creationDate = [json objectForKey:@"creation_date"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"date"], NSString))
    {
        trackOrder.lastOrderUpdate = [json objectForKey:@"date"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"payment"], NSDictionary))
    {
        NSDictionary *paymentObject = [json objectForKey:@"payment"];
        if(VALID_NOTEMPTY([paymentObject objectForKey:@"title"], NSString))
        {
            trackOrder.paymentMethod = [paymentObject objectForKey:@"title"];
        }
        if(VALID_NOTEMPTY([paymentObject objectForKey:@"label"], NSString))
        {
            trackOrder.paymentMethod = [paymentObject objectForKey:@"label"];
        }
        
        // WebPAY
        if(VALID_NOTEMPTY([paymentObject objectForKey:@"transaction_description"], NSString))
        {
            trackOrder.paymentDescription = [paymentObject objectForKey:@"transaction_description"];
        }
        // GlobalPay
        else if(VALID_NOTEMPTY([paymentObject objectForKey:@"status_description"], NSString))
        {
            trackOrder.paymentDescription = [paymentObject objectForKey:@"status_description"];
        }
        
        // WebPAY
        if(VALID_NOTEMPTY([paymentObject objectForKey:@"transaction_reference"], NSString))
        {
            trackOrder.paymentReference = [paymentObject objectForKey:@"transaction_reference"];
        }
        // GlobalPay
        else if(VALID_NOTEMPTY([paymentObject objectForKey:@"txnref"], NSString))
        {
            trackOrder.paymentReference = [paymentObject objectForKey:@"txnref"];
        }
    }
    
    if (VALID_NOTEMPTY([json objectForKey:@"products"], NSArray)) {
        NSArray *tempArray = [json objectForKey:@"products"];
        
        NSMutableArray *itemArray = [NSMutableArray new];
        
        for (NSDictionary *productJson in tempArray) {
            [itemArray addObject:[RIItemCollection parseItemCollection:productJson country:country]];
        }
        
        trackOrder.itemCollection = [itemArray copy];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"grand_total"], NSString))
    {
        trackOrder.total = [json objectForKey:@"grand_total"];
        
        NSNumber *totalNumber = [NSNumber numberWithFloat:[trackOrder.total floatValue]];
        trackOrder.totalFormatted = [RICountryConfiguration formatPrice:totalNumber country:country];
    }
    
    
    if (VALID_NOTEMPTY([json objectForKey:@"billing_address"], NSDictionary))
    {
        trackOrder.billingAddress = [RIAddress parseAddress:[json objectForKey:@"billing_address"]];
    }
    
    if (VALID_NOTEMPTY([json objectForKey:@"shipping_address"], NSDictionary))
    {
        trackOrder.shippingAddress = [RIAddress parseAddress:[json objectForKey:@"shipping_address"]];
    }
    
    return trackOrder;
}

+ (RITrackOrder *)parseTrackOrder:(NSDictionary *)json country:(RICountryConfiguration*)country
{
    RITrackOrder *trackOrder = [[RITrackOrder alloc] init];
    
    if(VALID_NOTEMPTY([json objectForKey:@"number"], NSString))
    {
        trackOrder.orderId = [json objectForKey:@"number"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"date"], NSString))
    {
        trackOrder.creationDate = [json objectForKey:@"date"];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"total"], NSString))
    {
        trackOrder.total = [json objectForKey:@"total"];
        
        NSNumber *totalNumber = [NSNumber numberWithFloat:[trackOrder.total floatValue]];
        trackOrder.totalFormatted = [RICountryConfiguration formatPrice:totalNumber country:country];
    }
    
    return trackOrder;
}

@end

@implementation RIOrder

+ (RIOrder*)parseOrder:(NSDictionary*)orderObject
{
    RIOrder *order = [[RIOrder alloc] init];
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"grand_total"], NSNumber)) {
        order.grandTotal = [orderObject objectForKey:@"grand_total"];
    }
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"grand_total_converted"], NSNumber)) {
        order.grandTotalEuroConverted = [orderObject objectForKey:@"grand_total_converted"];
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
    
    if (VALID_NOTEMPTY([orderObject objectForKey:@"coupon_discount"], NSNumber)) {
        order.discountCouponValue = [orderObject objectForKey:@"coupon_discount"];
    }
    
    NSString *shippingMethod = @"";
    if (VALID_NOTEMPTY([orderObject objectForKey:@"shipping_method"], NSDictionary)) {
        NSDictionary *shippingMethodObject = [orderObject objectForKey:@"shipping_method"];
        if (VALID_NOTEMPTY([shippingMethodObject objectForKey:@"label"], NSString)) {
            shippingMethod = [shippingMethodObject objectForKey:@"label"];
        }
    }
    order.shippingMethod = shippingMethod;
    
    NSString *paymentMethod = @"";
    if (VALID_NOTEMPTY([orderObject objectForKey:@"payment_method"], NSDictionary)) {
        NSDictionary *paymentMethodObject = [orderObject objectForKey:@"payment_method"];
        if (VALID_NOTEMPTY([paymentMethodObject objectForKey:@"label"], NSString)) {
            paymentMethod = [paymentMethodObject objectForKey:@"label"];
        }
    }
    else if (VALID_NOTEMPTY([orderObject objectForKey:@"payment_method"], NSString))
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

+ (NSString *)getOrdersPage:(NSNumber*)page
                   maxItems:(NSNumber*)maxItems
           withSuccessBlock:(void (^)(NSArray *orders, NSInteger ordersTotal))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(page, NSNumber))
    {
        [parameters setObject:[page stringValue] forKey:@"page"];
    }
    
    if(VALID_NOTEMPTY(maxItems, NSNumber))
    {
        [parameters setObject:[maxItems stringValue] forKey:@"per_page"];
    }
    
    return  [[RICommunicationWrapper sharedInstance]
             sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_ORDERS]]
             parameters:parameters
             httpMethod:HttpResponsePost
             cacheType:RIURLCacheNoCache
             cacheTime:RIURLCacheDefaultTime
             userAgentInjection:[RIApi getCountryUserAgentInjection]
             successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                         
                         NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
                         NSArray *ordersList = nil;
                         
                         NSInteger totalOrders = 0;
                         if(VALID_NOTEMPTY([metadata objectForKey:@"total_orders"], NSNumber))
                         {
                             totalOrders = [[metadata objectForKey:@"total_orders"] intValue];
                         }
                         if(VALID_NOTEMPTY([metadata objectForKey:@"orders"], NSArray))
                         {
                             ordersList = [RIOrder parseOrdersList:[metadata objectForKey:@"orders"] country:configuration];
                         }
                         
                         successBlock(ordersList, totalOrders);
                         
                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                         failureBlock(RIApiResponseUnknownError, nil);
                     }];
                 });
                 
             } failureBlock:^(RIApiResponse apiResponse,  NSDictionary *errorJsonObject, NSError *errorObject) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if(NOTEMPTY(errorJsonObject))
                     {
                         failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                     } else if(NOTEMPTY(errorObject))
                     {
                         NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                         failureBlock(apiResponse, errorArray);
                     } else
                     {
                         failureBlock(apiResponse, nil);
                     }
                 });
             }];
}

+ (NSString *)trackOrderWithOrderNumber:(NSString *)orderNumber
                       WithSuccessBlock:(void (^)(RITrackOrder *trackingOrder))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(orderNumber, NSString))
    {
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, [NSString stringWithFormat:RI_API_TRACK_ORDER, orderNumber]]]
                       parameters:nil
                       httpMethod:HttpResponsePost
                       cacheType:RIURLCacheNoCache
                       cacheTime:RIURLCacheDefaultTime
                       userAgentInjection:[RIApi getCountryUserAgentInjection]
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                   
                                   NSDictionary *dic = [jsonObject objectForKey:@"metadata"];
                                   
                                   successBlock([RITrackOrder parseDetailedTrackOrder:dic country:configuration]);
                               } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                   failureBlock(RIApiResponseUnknownError, nil);
                               }];
                           });
                           
                       } failureBlock:^(RIApiResponse apiResponse,  NSDictionary *errorJsonObject, NSError *errorObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(NOTEMPTY(errorJsonObject))
                               {
                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                               } else if(NOTEMPTY(errorObject))
                               {
                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                   failureBlock(apiResponse, errorArray);
                               } else
                               {
                                   failureBlock(apiResponse, nil);
                               }
                           });
                       }];
    } else {
        failureBlock(RIApiResponseUnknownError, nil);
    }
    
    return operationID;
}

+ (NSArray *)parseOrdersList:(NSArray *)ordersListObject country:(RICountryConfiguration*)country
{
    NSMutableArray *ordersList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *orderObject in ordersListObject)
    {
        RITrackOrder *trackOrder = [RITrackOrder parseTrackOrder:orderObject country:country];
        [ordersList addObject:trackOrder];
    }
    
    return [ordersList copy];
}

@end
