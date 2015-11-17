//
//  RICartItem.h
//  Jumia
//
//  Created by Pedro Lopes on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICartItem : NSObject

@property (nonatomic, strong) NSString *simpleSku;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) NSNumber *attributeSetID;
@property (nonatomic, strong) NSString *productUrl;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSNumber *maxQuantity;
@property (nonatomic, strong) NSString *configId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *variation;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *priceFormatted;
@property (nonatomic, strong) NSNumber *priceEuroConverted;
@property (nonatomic, strong) NSNumber *specialPrice;
@property (nonatomic, strong) NSString *specialPriceFormatted;
@property (nonatomic, strong) NSNumber *specialPriceEuroConverted;
@property (nonatomic, strong) NSNumber *savingPercentage;

+ (RICartItem*)parseCartItem:(NSDictionary*)info
                     country:(RICountryConfiguration *)country;

@end
