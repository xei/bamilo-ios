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
@dynamic attributeSize;
@dynamic variation;
@dynamic color;
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
    if ([meta isKindOfClass:[NSDictionary class]]) {
        
        if ([meta objectForKey:@"sku"]) {
            newProductSimple.sku = [meta objectForKey:@"sku"];
        }
        if ([meta objectForKey:@"price"]) {
            newProductSimple.price = [NSNumber numberWithFloat:[[meta objectForKey:@"price"] floatValue]];
            newProductSimple.priceFormatted = [RICountryConfiguration formatPrice:newProductSimple.price country:country];
        }
        
        if ([meta objectForKey:@"price_euroConverted"]) {
            newProductSimple.priceEuroConverted = [NSNumber numberWithFloat:[[meta objectForKey:@"price_euroConverted"] floatValue]];
        }
        
        if ([meta objectForKey:@"special_price"]) {
            newProductSimple.specialPrice = [NSNumber numberWithFloat:[[meta objectForKey:@"special_price"] floatValue]];
            newProductSimple.specialPriceFormatted = [RICountryConfiguration formatPrice:newProductSimple.specialPrice country:country];
        }
        
        if ([meta objectForKey:@"special_price_euroConverted"]) {
            newProductSimple.specialPriceEuroConverted = [NSNumber numberWithFloat:[[meta objectForKey:@"special_price_euroConverted"] floatValue]];
        }
        
        if ([meta objectForKey:@"quantity"]) {
            newProductSimple.quantity = [meta objectForKey:@"quantity"];
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
        if ([meta objectForKey:@"min_delivery_time"]) {
            newProductSimple.minDeliveryTime = [meta objectForKey:@"min_delivery_time"];
        }
        if ([meta objectForKey:@"variation"]) {
            newProductSimple.variation = [meta objectForKey:@"variation"];
        }
        if (VALID_NOTEMPTY(variationKey, NSString)) {
            if ([meta objectForKey:variationKey]) {
                newProductSimple.variation = [meta objectForKey:variationKey];
            }
        }
        
        if ([meta objectForKey:@"color"]) {
            newProductSimple.color = [meta objectForKey:@"color"];
        }
    }
    
    NSDictionary* attributes = [productSimpleJSON objectForKey:@"attributes"];
    if (VALID_NOTEMPTY(attributes, NSDictionary)) {
        
        if ([attributes objectForKey:@"package_type"]) {
            newProductSimple.attributePackageType = [attributes objectForKey:@"package_type"];
        }
        if ([attributes objectForKey:@"size"]) {
            newProductSimple.attributeSize = [attributes objectForKey:@"size"];
        }
    }
    
    return newProductSimple;
}

+ (void)saveProductSimple:(RIProductSimple*)productSimple;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:productSimple];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end