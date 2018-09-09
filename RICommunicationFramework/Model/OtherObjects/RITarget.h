//
//  RITarget.h
//  Jumia
//
//  Created by Telmo Pinto on 23/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RITarget : NSObject

typedef NS_ENUM(NSUInteger, TargetType) {
    UNKNOWN = 0,
    PRODUCT_DETAIL = 1,
    CATALOG_SEARCH,
    CATALOG_HASH,
    CATALOG_CATEGORY,
    CATALOG_BRAND,
    CATALOG_SELLER,
    CAMPAIGN,
    STATIC_PAGE,
    SHOP_IN_SHOP,
    FORM_SUBMIT,
    FORM_GET,
    RR_RECOMENDATION,
    RR_CLICK,
    EXTERNAL_LINK
};

@property (nonatomic, strong) NSString* type;
@property (nonatomic) TargetType targetType;
@property (nonatomic, strong) NSString* node;
@property (nonatomic, strong) NSString* urlString;
@property (nonatomic, strong) NSString* targetString;

+ (RITarget *)parseTarget:(NSString*)targetString;
+ (NSString *)getURLStringforTargetString:(NSString*)targetString;
+ (NSString *)getTargetKey:(TargetType)type;
+ (NSString *)getTargetString:(TargetType)type node:(NSString *)string;
+ (RITarget *)getTarget:(TargetType)type node:(NSString *)string;
+ (NSString*)getRelativeUrlStringforTarget:(RITarget*)target;

@end
