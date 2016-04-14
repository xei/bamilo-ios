//
//  JAProductInfoPriceLine.h
//  Jumia
//
//  Created by josemota on 9/24/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoBaseLine.h"

#define kProductInfoSingleLineHeight 48

@interface JAProductInfoPriceLine : JAProductInfoBaseLine

typedef NS_ENUM(NSInteger, JAPriceSize) {
    JAPriceSizeMedium = 0,
    JAPriceSizeSmall = 1,
    JAPriceSizeTitle = 2
};

@property (nonatomic) BOOL fashion;
@property (nonatomic) NSInteger priceOff;
@property (nonatomic) NSString *oldPrice;
@property (nonatomic) NSString *price;
@property (nonatomic) JAPriceSize priceSize;

@end
