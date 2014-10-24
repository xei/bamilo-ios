//
//  RICartItem.m
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICartItem.h"

@implementation RICartItem

+ (RICartItem*)parseCartItemWithSimpleSku:(NSString*)simpleSku
                                     info:(NSDictionary*)info
                                  country:(RICountryConfiguration *)country
{
    RICartItem *cartItem = [[RICartItem alloc] init];
    
    cartItem.simpleSku = simpleSku;
    
    if (VALID_NOTEMPTY([info objectForKey:@"configSku"], NSString)) {
        cartItem.sku = [info objectForKey:@"configSku"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"url"], NSString)) {
        cartItem.productUrl = [info objectForKey:@"url"];
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
    
    if (VALID_NOTEMPTY([info objectForKey:@"configId"], NSString)) {
        cartItem.configId = [info objectForKey:@"configId"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"name"], NSString)) {
        cartItem.name = [info objectForKey:@"name"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"stock"], NSString)) {
        cartItem.stock = [NSNumber numberWithLongLong:[[info objectForKey:@"stock"] longLongValue]];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"variation"], NSString)) {
        cartItem.variation = [info objectForKey:@"variation"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"unit_price"], NSNumber)) {
        cartItem.price = [info objectForKey:@"unit_price"];
        cartItem.priceFormatted = [RICountryConfiguration formatPrice:cartItem.price country:country];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"unit_price_euroConverted"], NSNumber)) {
        cartItem.priceEuroConverted = [info objectForKey:@"unit_price_euroConverted"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"specialPrice"], NSNumber)) {
        cartItem.specialPrice = [info objectForKey:@"specialPrice"];
        cartItem.specialPriceFormatted = [RICountryConfiguration formatPrice:cartItem.specialPrice country:country];
        
        // If there is special price, we have a saving percentage
        cartItem.savingPercentage = [NSNumber numberWithDouble:(100 - ([cartItem.specialPrice doubleValue] / [cartItem.price doubleValue]) * 100)];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"specialPrice_euroConverted"], NSNumber)) {
        cartItem.specialPriceEuroConverted = [info objectForKey:@"specialPrice_euroConverted"];
    }
    
    if (VALID_NOTEMPTY([info objectForKey:@"tax_amount"], NSNumber)) {
        cartItem.taxAmount = [info objectForKey:@"tax_amount"];
    }
    
    return cartItem;
}

@end
