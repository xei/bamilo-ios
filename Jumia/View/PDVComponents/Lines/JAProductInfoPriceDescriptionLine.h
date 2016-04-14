//
//  JAProductInfoPriceDescriptionLine.h
//  Jumia
//
//  Created by Jose Mota on 12/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSubLine.h"
#import "JAProductInfoPriceLine.h"

@interface JAProductInfoPriceDescriptionLine : JAProductInfoSubLine

@property (nonatomic) JAPriceSize size;

- (void)setPrice:(NSString *)price andOldPrice:(NSString *)oldPrice;
- (void)setPromotionalPrice:(NSString *)price;

@end
