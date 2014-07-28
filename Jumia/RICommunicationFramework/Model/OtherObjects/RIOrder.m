//
//  RIOrder.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"

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

@end
