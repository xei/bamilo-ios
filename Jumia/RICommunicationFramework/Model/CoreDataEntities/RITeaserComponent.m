//
//  RITeaserComponent.m
//  Jumia
//
//  Created by Telmo Pinto on 16/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RITeaserComponent.h"
#import "RITeaserGrouping.h"


@implementation RITeaserComponent

@dynamic imageLandscapeUrl;
@dynamic imagePortraitUrl;
@dynamic name;
@dynamic endingDate;
@dynamic subTitle;
@dynamic targetType;
@dynamic title;
@dynamic url;
@dynamic price;
@dynamic priceEuroConverted;
@dynamic priceFormatted;
@dynamic maxPriceEuroConverted;
@dynamic maxPrice;
@dynamic maxPriceFormatted;
@dynamic teaserGrouping;
@dynamic specialPrice;
@dynamic specialPriceEuroConverted;
@dynamic specialPriceFormatted;

+ (RITeaserComponent*)parseTeaserComponent:(NSDictionary*)teaserComponentJSON
                                   country:(RICountryConfiguration*)country
{
    RITeaserComponent* newTeaserComponent = (RITeaserComponent*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserComponent class])];
    
    if (VALID_NOTEMPTY(teaserComponentJSON, NSDictionary)) {

        if ([teaserComponentJSON objectForKey:@"image"]) {
            NSString* url = [teaserComponentJSON objectForKey:@"image"];
            NSString* realURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            newTeaserComponent.imagePortraitUrl = realURL;
        }
        
        if ([teaserComponentJSON objectForKey:@"image_landscape"]) {
            NSString* url = [teaserComponentJSON objectForKey:@"image_landscape"];
            NSString* realURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            newTeaserComponent.imageLandscapeUrl = realURL;
        }
        
        if ([teaserComponentJSON objectForKey:@"image_portrait"]) {
            NSString* url = [teaserComponentJSON objectForKey:@"image_portrait"];
            NSString* realURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            newTeaserComponent.imagePortraitUrl = realURL;
        }

        if ([teaserComponentJSON objectForKey:@"name"]) {
            newTeaserComponent.name = [teaserComponentJSON objectForKey:@"name"];
        }
        
        if ([teaserComponentJSON objectForKey:@"unix_time"]) {
            NSNumber* unixTime = [teaserComponentJSON objectForKey:@"unix_time"];
            newTeaserComponent.endingDate = [NSDate dateWithTimeIntervalSince1970:[unixTime doubleValue]];
        }
        
        if ([teaserComponentJSON objectForKey:@"title"]) {
            newTeaserComponent.title = [teaserComponentJSON objectForKey:@"title"];
        }
        
        if ([teaserComponentJSON objectForKey:@"sub_title"]) {
            newTeaserComponent.subTitle = [teaserComponentJSON objectForKey:@"sub_title"];
        }
        
        if ([teaserComponentJSON objectForKey:@"target_type"]) {
            newTeaserComponent.targetType = [teaserComponentJSON objectForKey:@"target_type"];
        }
        
        if ([teaserComponentJSON objectForKey:@"url"]) {
            newTeaserComponent.url = [teaserComponentJSON objectForKey:@"url"];
        }
        
        if ([teaserComponentJSON objectForKey:@"max_price"]) {
            newTeaserComponent.maxPrice = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"max_price"] floatValue]];
            newTeaserComponent.maxPriceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.maxPrice country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"max_price_converted"]) {
            newTeaserComponent.maxPriceEuroConverted = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"max_price_converted"] floatValue]];
        }
        
        if ([teaserComponentJSON objectForKey:@"price"]) {
            newTeaserComponent.price = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"price"] floatValue]];
            newTeaserComponent.priceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.price country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"price_converted"]) {
            newTeaserComponent.priceEuroConverted = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"price_converted"] floatValue]];
        }
        
        if ([teaserComponentJSON objectForKey:@"special_price"]) {
            newTeaserComponent.specialPrice = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"special_price"] floatValue]];
            newTeaserComponent.specialPriceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.specialPrice country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"special_price_converted"]) {
            newTeaserComponent.specialPriceEuroConverted = [NSNumber numberWithFloat:[[teaserComponentJSON objectForKey:@"special_price_converted"] floatValue]];
        }

    }
    
    return newTeaserComponent;
}

+ (void)saveTeaserComponent:(RITeaserComponent *)teaserComponent
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserComponent];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
