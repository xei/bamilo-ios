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
    
    newTarget.type = type;
    newTarget.node = node;
    
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
        if ([type isEqualToString:[self getTargetKey:PRODUCT_DETAIL]]) {
            urlString = [urlString stringByAppendingString:RI_API_PRODUCT_DETAIL];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_HASH];
        }else if ([type isEqualToString:[self getTargetKey:CATALOG_CATEGORY]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_BRAND]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_BRAND];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_SELLER]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_SELLER];
        } else if ([type isEqualToString:[self getTargetKey:CAMAPAIGN]]) {
            urlString = [urlString stringByAppendingString:RI_API_CAMPAIGN_PAGE];
        } else if ([type isEqualToString:[self getTargetKey:STATIC_PAGE]]) {
            urlString = [urlString stringByAppendingString:RI_API_STATIC_PAGE];
        } else if ([type isEqualToString:[self getTargetKey:FORM_SUBMIT]]) {
            //append nothing here
        } else if ([type isEqualToString:[self getTargetKey:FORM_GET]]) {
            urlString = [urlString stringByAppendingString:RI_API_FORMS_GET];
        } else if ([type isEqualToString:[self getTargetKey:RR_RECOMENDATION]]){
            urlString = [urlString stringByAppendingString:RI_API_RICH_RELEVANCE];
        } else if ([type isEqualToString:[self getTargetKey:RR_CLICK]]) {
            urlString = RI_API_RICH_RELEVANCE_CLICK;
        }
    }
    if (VALID_NOTEMPTY(node, NSString)) {
        urlString = [urlString stringByAppendingString:node];
    }
    return urlString;
}

+ (NSString *)getTargetString:(TargetType)type node:(NSString *)node
{
    NSString *key = [self getTargetKey:type];
    if (key) {
        return [NSString stringWithFormat:@"%@::%@", key, node];
    }
    return nil;
}

+ (NSString *)getTargetKey:(TargetType)type
{
    switch (type) {
        case PRODUCT_DETAIL:
            return @"product_detail";
        case CATALOG:
            return @"catalog";
        case CATALOG_BRAND:
            return @"catalog_brand";
        case CATALOG_CATEGORY:
            return @"catalog_category";
        case CATALOG_SELLER:
            return @"catalog_seller";
        case CAMAPAIGN:
            return @"campaign";
        case STATIC_PAGE:
            return @"static_page";
        case FORM_SUBMIT:
            return @"form_submit";
        case FORM_GET:
            return @"form_get";
        case RR_RECOMENDATION:
            return @"rr_recommendation";
        case RR_CLICK:
            return @"rr_click";
            
        default:
            return nil;
            break;
    }
}

+ (RITarget *)getTarget:(TargetType)type node:(NSString *)node
{
    NSString *targetString = [self getTargetString:type node:node];
    if (targetString) {
        return [self parseTarget:targetString];
    }
    return nil;
}

@end
