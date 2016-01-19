//
//  RICartItem.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICartItem.h"

@implementation RICartItem

+ (RICartItem*)parseCartItem:(NSDictionary*)info
                                  country:(RICountryConfiguration *)country
{
    RICartItem *cartItem = [[RICartItem alloc] init];
    
    if (VALID_NOTEMPTY([info objectForKey:@"simple_sku"], NSString)) {
        cartItem.simpleSku = [info objectForKey:@"simple_sku"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"sku"], NSString)) {
        cartItem.sku = [info objectForKey:@"sku"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"attribute_set_id"], NSNumber)) {
        cartItem.attributeSetID = [info objectForKey:@"attribute_set_id"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"target"], NSString)) {
        cartItem.targetString = [info objectForKey:@"target"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"image"], NSString)) {
        cartItem.imageUrl = [info objectForKey:@"image"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"quantity"], NSNumber)) {
        cartItem.quantity = [info objectForKey:@"quantity"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"max_quantity"], NSNumber)) {
        cartItem.maxQuantity = [info objectForKey:@"max_quantity"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"name"], NSString)) {
        cartItem.name = [info objectForKey:@"name"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"variation"], NSString)) {
        cartItem.variation = [info objectForKey:@"variation"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"price"], NSNumber)) {
        cartItem.price = [info objectForKey:@"price"];
        cartItem.priceFormatted = [RICountryConfiguration formatPrice:cartItem.price country:country];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"price_converted"], NSNumber)) {
        cartItem.priceEuroConverted = [info objectForKey:@"price_converted"];
    }
    
    if ([info objectForKey:@"shop_first"]) {
        cartItem.shopFirst = [NSNumber numberWithBool:[[info objectForKey:@"shop_first"] boolValue]];
        if ([info objectForKey:@"shop_first_overlay"]) {
            cartItem.shopFirstOverlay = [info objectForKey:@"shop_first_overlay"];
        }
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"special_price"], NSNumber)) {
        cartItem.specialPrice = [info objectForKey:@"special_price"];
        cartItem.specialPriceFormatted = [RICountryConfiguration formatPrice:cartItem.specialPrice country:country];
        
        // If there is special price, we have a saving percentage
        cartItem.savingPercentage = [NSNumber numberWithDouble:(100 - ([cartItem.specialPrice doubleValue] / [cartItem.price doubleValue]) * 100)];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"special_price_converted"], NSNumber)) {
        cartItem.specialPriceEuroConverted = [info objectForKey:@"special_price_converted"];
    }
    
    return cartItem;
}

@end
