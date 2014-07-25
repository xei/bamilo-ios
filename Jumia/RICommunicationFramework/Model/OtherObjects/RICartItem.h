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
@property (nonatomic, strong) NSString *productUrl;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSNumber *maxQuantity;
@property (nonatomic, strong) NSString *configId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *stock;
@property (nonatomic, strong) NSString *variation;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *specialPrice;
@property (nonatomic, strong) NSNumber *taxAmount;
@property (nonatomic, strong) NSNumber *savingPercentage;

+ (RICartItem*)parseCartItemWithSimpleSku:(NSString*)simpleSku
                                  andInfo:(NSDictionary*)info;

@end
