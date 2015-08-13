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
             httpMethodPost:YES
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
                       httpMethodPost:YES
                       cacheType:RIURLCacheNoCache
                       cacheTime:RIURLCacheDefaultTime
                       userAgentInjection:[RIApi getCountryUserAgentInjection]
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                   
                                   NSDictionary *dic = [jsonObject objectForKey:@"metadata"];
                                   
                                   successBlock([RIOrder parseTrackOrder:dic country:configuration]);
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
        RITrackOrder *trackOrder = [RIOrder parseTrackOrder:orderObject country:country];
        [ordersList addObject:trackOrder];
    }
    
    return [ordersList copy];
}

#pragma mark - Track order parsers

+ (RITrackOrder *)parseTrackOrder:(NSDictionary *)json country:(RICountryConfiguration*)country
{
    RITrackOrder *trackOrder = [[RITrackOrder alloc] init];
    
    // Track order
    if ([json objectForKey:@"order_id"]) {
        trackOrder.orderId = [json objectForKey:@"order_id"];
    }
    // Order list
    else if(VALID_NOTEMPTY([json objectForKey:@"number"], NSString))
    {
        trackOrder.orderId = [json objectForKey:@"number"];
    }
    
    // Track order
    if ([json objectForKey:@"creation_date"]) {
        trackOrder.creationDate = [json objectForKey:@"creation_date"];
    }
    // Order list
    else if(VALID_NOTEMPTY([json objectForKey:@"date"], NSString))
    {
        trackOrder.creationDate = [json objectForKey:@"date"];
    }
    
    // Track order
    if ([json objectForKey:@"last_order_update"]) {
        trackOrder.lastOrderUpdate = [json objectForKey:@"last_order_update"];
    }
    
    // Track order
    if ([json objectForKey:@"payment_method"]) {
        trackOrder.paymentMethod = [json objectForKey:@"payment_method"];
    }
    // Order list
    else if(VALID_NOTEMPTY([json objectForKey:@"payment"], NSDictionary))
    {
        NSDictionary *paymentObject = [json objectForKey:@"payment"];
        if(VALID_NOTEMPTY([paymentObject objectForKey:@"title"], NSString))
        {
            trackOrder.paymentMethod = [paymentObject objectForKey:@"title"];
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
    
    // Track order
    if ([json objectForKey:@"item_collection"]) {
        NSDictionary *tempDic = [json objectForKey:@"item_collection"];
        
        NSMutableArray *itemArray = [NSMutableArray new];
        
        for (NSString *string in tempDic) {
            NSDictionary *temp = [tempDic objectForKey:string];
            [itemArray addObject:[RIOrder parseItemCollection:temp country:country]];
        }
        
        trackOrder.itemCollection = [itemArray copy];
    }
    // Order list
    else if ([json objectForKey:@"products"]) {
        NSArray *productsObject = [json objectForKey:@"products"];
        
        NSMutableArray *itemArray = [NSMutableArray new];
        
        for (NSDictionary *productObject in productsObject) {
            [itemArray addObject:[RIOrder parseItemCollection:productObject country:country]];
        }
        
        trackOrder.itemCollection = [itemArray copy];
    }
    
    if(VALID_NOTEMPTY([json objectForKey:@"total"], NSString))
    {
        trackOrder.total = [json objectForKey:@"total"];
        
        NSNumber *totalNumber = [NSNumber numberWithFloat:[trackOrder.total floatValue]];
        trackOrder.totalFormatted = [RICountryConfiguration formatPrice:totalNumber country:country];
    }
    
    return trackOrder;
}

+ (RIItemCollection *)parseItemCollection:(NSDictionary *)json country:(RICountryConfiguration*)country
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
    
    if(VALID_NOTEMPTY([json objectForKey:@"total"], NSNumber))
    {
        item.total = [json objectForKey:@"total"];
        item.totalFormatted = [RICountryConfiguration formatPrice:item.total country:country];
    }
    
    return item;
}

+ (RIStatus *)parseStatus:(NSDictionary *)json
{
    RIStatus *status = [[RIStatus alloc] init];
    
    if(VALID_NOTEMPTY(json, NSDictionary))
    {
        if ([json objectForKey:@"item_status"]) {
            status.itemStatus = [json objectForKey:@"item_status"];
        }
        
        if ([json objectForKey:@"last_status_change"]) {
            status.lastChangeStatus = [json objectForKey:@"last_status_change"];
        }
    }
    
    return status;
}

@end
