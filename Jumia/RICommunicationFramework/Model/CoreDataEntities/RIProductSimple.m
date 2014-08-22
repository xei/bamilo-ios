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
@dynamic maxDeliveryTime;
@dynamic minDeliveryTime;
@dynamic price;
@dynamic priceFormatted;
@dynamic quantity;
@dynamic sku;
@dynamic specialPrice;
@dynamic specialPriceFormatted;
@dynamic stock;
@dynamic product;

+ (RIProductSimple *)parseProductSimple:(NSDictionary*)productSimpleJSON country:(RICountryConfiguration*)country
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
        if ([meta objectForKey:@"special_price"]) {
            newProductSimple.specialPrice = [NSNumber numberWithFloat:[[meta objectForKey:@"special_price"] floatValue]];
            newProductSimple.specialPriceFormatted = [RICountryConfiguration formatPrice:newProductSimple.specialPrice country:country];
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