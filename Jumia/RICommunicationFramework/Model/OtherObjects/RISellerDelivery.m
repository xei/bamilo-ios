//
//  RISellerDelivery.m
//  Jumia
//
//  Created by miguelseabra on 13/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "RISellerDelivery.h"



@implementation RISellerDelivery

+(RISellerDelivery*) parseSellerDelivery:(NSDictionary*)json{
    RISellerDelivery* sellerDelivery = [[RISellerDelivery alloc] init];
    
    if (VALID_NOTEMPTY([json objectForKey:@"name"],NSString)) {
        sellerDelivery.name = [json objectForKey:@"name"];
    }
    
    if (VALID_NOTEMPTY([json objectForKey:@"delivery_time"],NSString)) {
        sellerDelivery.deliveryTime = [json objectForKey:@"delivery_time"];
    }
    if (VALID_NOTEMPTY([json objectForKey:@"is_global"],NSNumber)) {
        NSNumber* isGlobal = [json objectForKey:@"is_global"];
        
        if ([isGlobal boolValue]) {
            if (VALID_NOTEMPTY([json objectForKey:@"global"],NSDictionary)) {
                NSDictionary* global = [json objectForKey:@"global"];
                
                if (VALID_NOTEMPTY([global objectForKey:@"shipping"], NSString)) {
                    sellerDelivery.shippingGlobal = [global objectForKey:@"shipping"];
                }
            }
        }
    }
    
    return sellerDelivery;
}

@end

