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

- (void)setTargetType:(TargetType)targetType {
    self.type = [RITarget getTargetKey:targetType];
}

- (TargetType)targetType {
    if (!self.type && self.targetString) {
        self.type = [RITarget parseTarget:self.targetString].type;
    }
    
    if ([self.type isEqualToString:[RITarget getTargetKey:PRODUCT_DETAIL]]) {
        return PRODUCT_DETAIL;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CATALOG_HASH]]) {
        return CATALOG_HASH;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CATALOG_SEARCH]]) {
        return CATALOG_SEARCH;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CATALOG_CATEGORY]]) {
        return CATALOG_CATEGORY;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CATALOG_BRAND]]) {
        return CATALOG_BRAND;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CATALOG_SELLER]]) {
        return CATALOG_SELLER;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:CAMPAIGN]]) {
        return CAMPAIGN;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:STATIC_PAGE]]) {
        return STATIC_PAGE;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:SHOP_IN_SHOP]]) {
        return SHOP_IN_SHOP;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:FORM_SUBMIT]]) {
        return FORM_SUBMIT;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:FORM_GET]]) {
        return FORM_GET;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:RR_RECOMENDATION]]) {
        return RR_RECOMENDATION;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:RR_CLICK]]) {
        return RR_CLICK;
    } else if ([self.type isEqualToString:[RITarget getTargetKey:EXTERNAL_LINK]]) {
        return EXTERNAL_LINK;
    }
    return UNKNOWN;
}

- (NSString *)targetString {
    return [NSString stringWithFormat:@"%@::%@", self.type, self.node];
}

+ (RITarget*)parseTarget:(NSString*)targetString {
    RITarget* newTarget = [[RITarget alloc] init];
    
    NSString* type;
    NSString* node;
    if (targetString.length) {
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

+ (NSString*)getURLStringforTargetString:(NSString*)targetString {
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


+ (NSString*)getURLStringforTarget:(RITarget*)target {
    return [RITarget getURLStringforType:target.type node:target.node];
}

+ (NSString*)getRelativeUrlStringforTarget:(RITarget*)target {
    return [RITarget getRelativeUrlForType:target.type node:target.node];
}

+ (NSString*)getURLStringforType:(NSString*)type node:(NSString*)node {
    if ([type isEqualToString:@"external_link"]) {
        return node;
    }
    NSString* urlString = [NSString stringWithFormat:@"%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION];
    return [NSString stringWithFormat:@"%@%@", urlString, [RITarget getRelativeUrlForType:type node:node]];
}

+ (NSString *)getRelativeUrlForType:(NSString *)type node: (NSString *)node {
    NSString *urlString = @"";
    if (VALID_NOTEMPTY(type, NSString)) {
        if ([type isEqualToString:[self getTargetKey:PRODUCT_DETAIL]]) {
            urlString = [urlString stringByAppendingString:RI_API_PRODUCT_DETAIL];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_HASH]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_HASH];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_SEARCH]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_QUERY_SEARCH];
        }else if ([type isEqualToString:[self getTargetKey:CATALOG_CATEGORY]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_CATEGORY];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_BRAND]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_BRAND];
        } else if ([type isEqualToString:[self getTargetKey:CATALOG_SELLER]]) {
            urlString = [urlString stringByAppendingString:RI_API_CATALOG_SELLER];
        } else if ([type isEqualToString:[self getTargetKey:CAMPAIGN]]) {
            urlString = [urlString stringByAppendingString:RI_API_CAMPAIGN_PAGE];
        } else if ([type isEqualToString:[self getTargetKey:STATIC_PAGE]]) {
            urlString = [urlString stringByAppendingString:RI_API_STATIC_PAGE];
        } else if ([type isEqualToString:[self getTargetKey:SHOP_IN_SHOP]]) {
            urlString = [urlString stringByAppendingString:RI_API_STATIC_PAGE];
        } else if ([type isEqualToString:[self getTargetKey:FORM_SUBMIT]]) {
            //append nothing here
        } else if ([type isEqualToString:[self getTargetKey:FORM_GET]]) {
            urlString = [urlString stringByAppendingString:RI_API_FORMS_GET];
        } else if ([type isEqualToString:[self getTargetKey:RR_RECOMENDATION]]){
            urlString = [urlString stringByAppendingString:RI_API_RICH_RELEVANCE];
        } else if ([type isEqualToString:[self getTargetKey:RR_CLICK]]) {
            urlString = RI_API_RICH_RELEVANCE_CLICK;
        } else if ([type isEqualToString:[self getTargetKey:EXTERNAL_LINK]]) {
            urlString = [NSString new];
        }
    }
    if (VALID_NOTEMPTY(node, NSString)) {
        urlString = [urlString stringByAppendingString:node];
    }
    return urlString;
}

+ (NSString *)getTargetString:(TargetType)type node:(NSString *)node {
    NSString *key = [self getTargetKey:type];
    if (key) {
        return [NSString stringWithFormat:@"%@::%@", key, node];
    }
    return nil;
}

+ (NSString *)getTargetKey:(TargetType)type {
    switch (type) {
        case PRODUCT_DETAIL:
            return @"product_detail";
        case CATALOG_SEARCH:
            return @"catalog_query";
        case CATALOG_HASH:
            return @"catalog";
        case CATALOG_BRAND:
            return @"catalog_brand";
        case CATALOG_CATEGORY:
            return @"catalog_category";
        case CATALOG_SELLER:
            return @"catalog_seller";
        case CAMPAIGN:
            return @"campaign";
        case STATIC_PAGE:
            return @"static_page";
        case SHOP_IN_SHOP:
            return @"shop_in_shop";
        case FORM_SUBMIT:
            return @"form_submit";
        case FORM_GET:
            return @"form_get";
        case RR_RECOMENDATION:
            return @"rr_recommendation";
        case RR_CLICK:
            return @"rr_click";
        case EXTERNAL_LINK:
            return @"external_link";
            
        default:
            return nil;
            break;
    }
}

+ (RITarget *)getTarget:(TargetType)type node:(NSString *)node {
    RITarget *target = [RITarget new];
    target.targetType = type;
    target.node = node;
    return target;
}

@end
