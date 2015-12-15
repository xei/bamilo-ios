//
//  RITarget.m
//  Jumia
//
//  Created by Telmo Pinto on 23/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "RITarget.h"

@implementation RITarget

@synthesize urlString=_urlString;
- (NSString*)urlString
{
    return [RITarget getURLStringforTarget:self];
}

+ (RITarget*)parseTarget:(NSString*)targetString;
{
    RITarget* newTarget = [[RITarget alloc] init];
    
    if (VALID_NOTEMPTY(targetString, NSString)) {
        NSArray *components = [targetString componentsSeparatedByString:@"::"];
        if (0 < components.count) {
            newTarget.type = [components firstObject];
            if (1 < components.count) {
                newTarget.node = [components objectAtIndex:1];
            }
        }
    }
    
    return newTarget;
}

+ (NSString*)getURLStringforTargetString:(NSString*)targetString;
{
    NSString* type;
    NSString* node;
    if (VALID_NOTEMPTY(targetString, NSString)) {
        NSArray *components = [targetString componentsSeparatedByString:@"::"];
        if (1 == components.count) {
            node = [components firstObject];
        } else if (2 == components.count) {
            type = [components firstObject];
            node = [components lastObject];
        }
    }
    return [RITarget getURLStringforType:type node:node];
}


+ (NSString*)getURLStringforTarget:(RITarget*)target
{
    return [RITarget getURLStringforType:target.type node:target.node];
}

+ (NSString*)getURLStringforType:(NSString*)type
                            node:(NSString*)node;
{
    NSString* urlString = [NSString stringWithFormat:@"%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION];
    if (VALID_NOTEMPTY(type, NSString)) {
        if ([type isEqualToString:@"product_detail"]) {
            urlString = [urlString stringByAppendingString:RI_API_PRODUCT_DETAIL];
        } else if ([type isEqualToString:@"catalog"]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_HASH];
        } else if ([type isEqualToString:@"catalog_brand"]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_BRAND];
        } else if ([type isEqualToString:@"catalog_seller"]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_SELLER];
        } else if ([type isEqualToString:@"campaign"]) {
            urlString = [urlString stringByAppendingString:RI_API_CAMPAIGN_PAGE];
        } else if ([type isEqualToString:@"static_page"]) {
            urlString = [urlString stringByAppendingString:RI_API_STATIC_PAGE];
        } else if ([type isEqualToString:@"form_submit"]) {
            //append nothing here
        } else if ([type isEqualToString:@"form_get"]) {
            urlString = [urlString stringByAppendingString:RI_API_FORMS_GET];
        } else if ([type isEqualToString:@"rr_recommendation"]){
            urlString = [urlString stringByAppendingString:RI_API_RICH_RELEVANCE];
        } else if ([type isEqualToString:@"rr_click"]) {
            urlString = RI_API_RICH_RELEVANCE_CLICK;
        }
    }
    if (VALID_NOTEMPTY(node, NSString)) {
        urlString = [urlString stringByAppendingString:node];
    }
    return urlString;
}


@end
