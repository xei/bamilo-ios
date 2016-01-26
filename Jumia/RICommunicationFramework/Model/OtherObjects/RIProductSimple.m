//
//  RIProductSimple.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIProductSimple.h"
#import "RIProduct.h"

@implementation RIProductSimple

@synthesize attributePackageType;
@synthesize variation;
@synthesize maxDeliveryTime;
@synthesize minDeliveryTime;
@synthesize price;
@synthesize priceFormatted;
@synthesize priceEuroConverted;
@synthesize quantity;
@synthesize sku;
@synthesize specialPrice;
@synthesize specialPriceFormatted;
@synthesize specialPriceEuroConverted;
@synthesize stock;
@synthesize product;

+ (RIProductSimple *)parseProductSimple:(NSDictionary*)productSimpleJSON country:(RICountryConfiguration*)country variationKey:(NSString*)variationKey
{
    RIProductSimple* newProductSimple = [[RIProductSimple alloc] init];
    
    if (ISEMPTY(productSimpleJSON)) {
        productSimpleJSON = productSimpleJSON;
    }
    if ([productSimpleJSON isKindOfClass:[NSDictionary class]]) {
        
        if ([productSimpleJSON objectForKey:@"sku"]) {
            newProductSimple.sku = [productSimpleJSON objectForKey:@"sku"];
        }
        if ([productSimpleJSON objectForKey:@"price"]) {
            newProductSimple.price = [NSNumber numberWithFloat:[[productSimpleJSON objectForKey:@"price"] floatValue]];
            newProductSimple.priceFormatted = [RICountryConfiguration formatPrice:newProductSimple.price country:country];
        }
        
        if ([productSimpleJSON objectForKey:@"price_converted"]) {
            newProductSimple.priceEuroConverted = [NSNumber numberWithFloat:[[productSimpleJSON objectForKey:@"price_converted"] floatValue]];
        }
        
        if ([productSimpleJSON objectForKey:@"special_price"]) {
            newProductSimple.specialPrice = [NSNumber numberWithFloat:[[productSimpleJSON objectForKey:@"special_price"] floatValue]];
            newProductSimple.specialPriceFormatted = [RICountryConfiguration formatPrice:newProductSimple.specialPrice country:country];
        }
        
        if ([productSimpleJSON objectForKey:@"special_price_converted"]) {
            newProductSimple.specialPriceEuroConverted = [NSNumber numberWithFloat:[[productSimpleJSON objectForKey:@"special_price_converted"] floatValue]];
        }
        
        if ([productSimpleJSON objectForKey:@"quantity"]) {
            id quantity = [productSimpleJSON objectForKey:@"quantity"];
            if ([quantity isKindOfClass:[NSString class]]) {
                newProductSimple.quantity = (NSString*)quantity;
            } else if ([quantity isKindOfClass:[NSNumber class]]){
                newProductSimple.quantity = [NSString stringWithFormat:@"%ld",(long)[(NSNumber*)quantity integerValue]];
            }

        }
        if ([productSimpleJSON objectForKey:@"stock"]) {
            newProductSimple.stock = [productSimpleJSON objectForKey:@"stock"];
        }
        if ([productSimpleJSON objectForKey:@"min_delivery_time"]) {
            newProductSimple.minDeliveryTime = [productSimpleJSON objectForKey:@"min_delivery_time"];
        }
        if ([productSimpleJSON objectForKey:@"max_delivery_time"]) {
            newProductSimple.maxDeliveryTime = [productSimpleJSON objectForKey:@"max_delivery_time"];
        }
 
        if (VALID_NOTEMPTY(variationKey, NSString)) {
            if ([productSimpleJSON objectForKey:variationKey]) {
                newProductSimple.variation = [productSimpleJSON objectForKey:variationKey];
            }
            else if(VALID_NOTEMPTY([productSimpleJSON objectForKey:@"attributes"], NSDictionary) &&
                    VALID_NOTEMPTY([[productSimpleJSON objectForKey:@"attributes"] objectForKey:@"size"], NSString))
            {
                newProductSimple.variation = [[productSimpleJSON objectForKey:@"attributes"] objectForKey:@"size"];
            }
            else if ([productSimpleJSON objectForKey:@"color"]) {
                newProductSimple.variation = [productSimpleJSON objectForKey:@"color"];
            }
            else if ([productSimpleJSON objectForKey:@"variation"]) {
                newProductSimple.variation = [productSimpleJSON objectForKey:@"variation"];
            }
            
            NSString *variationString = [newProductSimple.variation lowercaseString];
            if ([@"1" isEqualToString:variationString] ||
                [@"," isEqualToString:variationString] ||
                [@"..." isEqualToString:variationString] ||
                [@"." isEqualToString:variationString] ||
                [@"\u2026" isEqualToString:variationString] )
            {
                newProductSimple.variation = @"";
            }
        }
        else if ([productSimpleJSON objectForKey:@"size"]) {
            newProductSimple.variation = [productSimpleJSON objectForKey:@"size"];
        }
        else if ([productSimpleJSON objectForKey:@"variation_value"]) {
            id variationValue = [productSimpleJSON objectForKey:@"variation_value"];
            if ([variationValue isKindOfClass:[NSString class]]) {
                newProductSimple.variation = (NSString*)variationValue;
            } else if ([variationValue isKindOfClass:[NSNumber class]]){
                newProductSimple.variation = [NSString stringWithFormat:@"%ld",(long)[(NSNumber*)variationValue integerValue]];
            }
        }
        else if ([productSimpleJSON objectForKey:@"variation"]) {
            newProductSimple.variation = [productSimpleJSON objectForKey:@"variation"];
        }
    }
    
    NSDictionary* attributes = [productSimpleJSON objectForKey:@"attributes"];
    if (VALID_NOTEMPTY(attributes, NSDictionary)) {
        
        if ([attributes objectForKey:@"package_type"]) {
            newProductSimple.attributePackageType = [attributes objectForKey:@"package_type"];
        }
    }
    
    return newProductSimple;
}

@end