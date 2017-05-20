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
@dynamic targetString;
@dynamic title;
@dynamic brand;
@dynamic richRelevance;
@dynamic maxSavingPercentage;
@dynamic sku;
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
country:(RICountryConfiguration*)country {
    RITeaserComponent* newTeaserComponent = (RITeaserComponent*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserComponent class])];
    
    if (teaserComponentJSON) {
        
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
        
        if ([teaserComponentJSON objectForKey:@"target"]) {
            newTeaserComponent.targetString = [teaserComponentJSON objectForKey:@"target"];
        }
        
        if ([teaserComponentJSON objectForKey:@"brand"]) {
            newTeaserComponent.brand = [teaserComponentJSON objectForKey:@"brand"];
        }
        
        if ([teaserComponentJSON objectForKey:@"click_request"]) {
            newTeaserComponent.richRelevance = [teaserComponentJSON objectForKey:@"click_request"];
        }
        
        if ([teaserComponentJSON objectForKey:@"max_saving_percentage"]) {
            newTeaserComponent.maxSavingPercentage = [teaserComponentJSON objectForKey:@"max_saving_percentage"];
        }
        
        if ([teaserComponentJSON objectForKey:@"sku"]) {
            newTeaserComponent.sku = [teaserComponentJSON objectForKey:@"sku"];
        }
        
        if ([teaserComponentJSON objectForKey:@"max_price"]) {
            newTeaserComponent.maxPrice = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"max_price"] longLongValue]];
            newTeaserComponent.maxPriceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.maxPrice country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"max_price_converted"]) {
            newTeaserComponent.maxPriceEuroConverted = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"max_price_converted"] longLongValue]];
        }
        
        if ([teaserComponentJSON objectForKey:@"price"]) {
            newTeaserComponent.price = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"price"] longLongValue]];
            newTeaserComponent.priceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.price country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"price_converted"]) {
            newTeaserComponent.priceEuroConverted = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"price_converted"] longLongValue]];
        }
        
        if ([teaserComponentJSON objectForKey:@"special_price"]) {
            newTeaserComponent.specialPrice = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"special_price"] longLongValue]];
            newTeaserComponent.specialPriceFormatted = [RICountryConfiguration formatPrice:newTeaserComponent.specialPrice country:country];
        }
        
        if ([teaserComponentJSON objectForKey:@"special_price_converted"]) {
            newTeaserComponent.specialPriceEuroConverted = [NSNumber numberWithLongLong:[[teaserComponentJSON objectForKey:@"special_price_converted"] longLongValue]];
        }

    }
    
    return newTeaserComponent;
}

+ (void)saveTeaserComponent:(RITeaserComponent *)teaserComponent andContext:(BOOL)save {
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:teaserComponent];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

- (void)sendNotificationForTeaseTarget:(NSString *)optionalTrackingInfo {
    RITarget* teaserTarget = [RITarget parseTarget:self.targetString];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:STRING_HOME forKey:@"show_back_button_title"];
    if (self.name.length) {
        [userInfo setObject:self.name forKey:@"title"];
    } else if (self.title.length) {
        [userInfo setObject:self.title forKey:@"title"];
    }
    
    if (self.richRelevance.length) {
        [userInfo setObject:self.richRelevance forKey:@"richRelevance"];
    }
    
    if (optionalTrackingInfo) {
      [userInfo setObject:optionalTrackingInfo forKey:@"teaserTrackingInfo"];
    }
    
    NSString* notificationName;
    
    if ([teaserTarget.type isEqualToString:[RITarget getTargetKey:CATALOG_HASH]] || [teaserTarget.type isEqualToString:[RITarget getTargetKey:CATALOG_CATEGORY]]) {
        
        notificationName = kDidSelectTeaserWithCatalogUrlNofication;
        
    } else if ([teaserTarget.type isEqualToString:[RITarget getTargetKey:PRODUCT_DETAIL]]) {
        
        notificationName = kDidSelectTeaserWithPDVUrlNofication;
        
    } else if ([teaserTarget.type isEqualToString:[RITarget getTargetKey:STATIC_PAGE]] || [teaserTarget.type isEqualToString:[RITarget getTargetKey:SHOP_IN_SHOP]]) {
        
        notificationName = kDidSelectTeaserWithShopUrlNofication;
        
    } else if ([teaserTarget.type isEqualToString:[RITarget getTargetKey:CAMPAIGN]]) {
        
        notificationName = kDidSelectCampaignNofication;
        //For the campaigns teaserGrouping we need all the campaign components
        if ([self.teaserGrouping.type isEqualToString:@"campaigns"]) {
            [userInfo setObject:self.teaserGrouping forKey:@"teaserGrouping"];
        }
    }
    
    if (self.targetString.length) {
        [userInfo setObject:self.targetString forKey:@"targetString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
        
        //tracking click
        NSMutableDictionary* teaserTrackingDictionary = [NSMutableDictionary new];
        [teaserTrackingDictionary setValue:optionalTrackingInfo forKey:kRIEventCategoryKey];
        [teaserTrackingDictionary setValue:@"BannerClick" forKey:kRIEventActionKey];
        [teaserTrackingDictionary setValue:teaserTarget.node forKey:kRIEventLabelKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTeaserClick] data:[teaserTrackingDictionary copy]];
    }
}

@end
