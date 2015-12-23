//
//  RIShippingMethod.m
//  Jumia
//
//  Created by plopes on 15/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethod.h"

@implementation RIShippingMethod

+ (RIShippingMethod *)parseShippingMethod:(NSDictionary *)shippingMethodJSON
{
    RIShippingMethod* newShippingMethod = [[RIShippingMethod alloc] init];
    
    if (VALID_NOTEMPTY(shippingMethodJSON, NSDictionary))
    {    
        if (VALID_NOTEMPTY([shippingMethodJSON objectForKey:@"label"], NSString))
        {
            newShippingMethod.label = [shippingMethodJSON objectForKey:@"label"];
        }
        
        if (VALID_NOTEMPTY([shippingMethodJSON objectForKey:@"delivery_time"], NSString))
        {
            newShippingMethod.deliveryTime = [shippingMethodJSON objectForKey:@"delivery_time"];
        }
        
        if (VALID_NOTEMPTY([shippingMethodJSON objectForKey:@"shipping_fee"], NSNumber))
        {
            newShippingMethod.shippingFee = [shippingMethodJSON objectForKey:@"shipping_fee"];
        }
        
        if (VALID_NOTEMPTY([shippingMethodJSON objectForKey:@"value"], NSString))
        {
            newShippingMethod.value = [shippingMethodJSON objectForKey:@"value"];
        }
    }
    
    return newShippingMethod;
}

@end
