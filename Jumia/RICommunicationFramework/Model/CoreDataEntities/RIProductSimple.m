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

@dynamic attributePackageType;
@dynamic variation;
@dynamic maxDeliveryTime;
@dynamic minDeliveryTime;
@dynamic price;
@dynamic priceFormatted;
@dynamic priceEuroConverted;
@dynamic quantity;
@dynamic sku;
@dynamic specialPrice;
@dynamic specialPriceFormatted;
@dynamic specialPriceEuroConverted;
@dynamic stock;
@dynamic product;

+ (RIProductSimple *)parseProductSimple:(NSDictionary*)productSimpleJSON country:(RICountryConfiguration*)country variationKey:(NSString*)variationKey
{
    RIProductSimple* newProductSimple = (RIProductSimple*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIProductSimple class])];
    
    NSDictionary* meta = [productSimpleJSON objectForKey:@"meta"];
    if (ISEMPTY(meta)) {
        meta = productSimpleJSON;
    }
    if ([meta isKindOfClass:[NSDictionary class]]) {
        
        if ([meta objectForKey:@"sku"]) {
            newProductSimple.sku = [meta objectForKey:@"sku"];
        }
        if ([meta objectForKey:@"price"]) {
            newProductSimple.price = [NSNumber numberWithFloat:[[meta objectForKey:@"price"] floatValue]];
            newProductSimple.priceFormatted = [RICountryConfiguration formatPrice:newProductSimple.price country:country];
        }
        
        if ([meta objectForKey:@"price_converted"]) {
            newProductSimple.priceEuroConverted = [NSNumber numberWithFloat:[[meta objectForKey:@"price_converted"] floatValue]];
        }
        
        if ([meta objectForKey:@"special_price"]) {
            newProductSimple.specialPrice = [NSNumber numberWithFloat:[[meta objectForKey:@"special_price"] floatValue]];
            newProductSimple.specialPriceFormatted = [RICountryConfiguration formatPrice:newProductSimple.specialPrice country:country];
        }
        
        if ([meta objectForKey:@"special_price_converted"]) {
            newProductSimple.specialPriceEuroConverted = [NSNumber numberWithFloat:[[meta objectForKey:@"special_price_converted"] floatValue]];
        }
        
        if ([meta objectForKey:@"quantity"]) {
            id quantity = [meta objectForKey:@"quantity"];
            if ([quantity isKindOfClass:[NSString class]]) {
                newProductSimple.quantity = (NSString*)quantity;
            } else if ([quantity isKindOfClass:[NSNumber class]]){
                newProductSimple.quantity = [NSString stringWithFormat:@"%ld",(long)[(NSNumber*)quantity integerValue]];
            }

        }
        if ([meta objectForKey:@"stock"]) {
            newProductSimple.stock = [meta objectForKey:@"stock"];
        }
        if ([meta objectForKey:@"min_delivery_time"]) {
            newProductSimple.minDeliveryTime = [meta objectForKey:@"min_delivery_time"];
        }
        if ([meta objectForKey:@"max_delivery_time"]) {
            newProductSimple.maxDeliveryTime = [meta objectForKey:@"max_delivery_time"];
        }
 
        if (VALID_NOTEMPTY(variationKey, NSString)) {
            if ([meta objectForKey:variationKey]) {
                newProductSimple.variation = [meta objectForKey:variationKey];
            }
            else if(VALID_NOTEMPTY([productSimpleJSON objectForKey:@"attributes"], NSDictionary) &&
                    VALID_NOTEMPTY([[productSimpleJSON objectForKey:@"attributes"] objectForKey:@"size"], NSString))
            {
                newProductSimple.variation = [[productSimpleJSON objectForKey:@"attributes"] objectForKey:@"size"];
            }
            else if ([meta objectForKey:@"color"]) {
                newProductSimple.variation = [meta objectForKey:@"color"];
            }
            else if ([meta objectForKey:@"variation"]) {
                newProductSimple.variation = [meta objectForKey:@"variation"];
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
        else if ([meta objectForKey:@"size"]) {
            newProductSimple.variation = [meta objectForKey:@"size"];
        }
        else if ([meta objectForKey:@"variation_value"]) {
            id variationValue = [meta objectForKey:@"variation_value"];
            if ([variationValue isKindOfClass:[NSString class]]) {
                newProductSimple.variation = (NSString*)variationValue;
            } else if ([variationValue isKindOfClass:[NSNumber class]]){
                newProductSimple.variation = [NSString stringWithFormat:@"%ld",(long)[(NSNumber*)variationValue integerValue]];
            }
        }
        else if ([meta objectForKey:@"variation"]) {
            newProductSimple.variation = [meta objectForKey:@"variation"];
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

+ (void)saveProductSimple:(RIProductSimple*)productSimple andContext:(BOOL)save;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:productSimple];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end