//
//  RITarget.h
//  Jumia
//
//  Created by Telmo Pinto on 23/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RITarget : NSObject

typedef enum {
    UNKNOWN,
    PRODUCT_DETAIL,
    CATALOG_SEARCH,
    CATALOG_HASH,
    CATALOG_CATEGORY,
    CATALOG_BRAND,
    CATALOG_SELLER,
    CAMAPAIGN,
    STATIC_PAGE,
    FORM_SUBMIT,
    FORM_GET,
    RR_RECOMENDATION,
    RR_CLICK
} TargetType;

@property (nonatomic, strong) NSString* type;
@property (nonatomic) TargetType targetType;
@property (nonatomic, strong) NSString* node;
@property (nonatomic, strong) NSString* urlString;

+ (RITarget*)parseTarget:(NSString*)targetString;
+ (NSString*)getURLStringforTargetString:(NSString*)targetString;

+ (NSString *)getTargetString:(TargetType)type node:(NSString *)string;
+ (RITarget *)getTarget:(TargetType)type node:(NSString *)string;

@end
