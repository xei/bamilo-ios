//
//  JAProductInfoPriceDescriptionLine.m
//  Jumia
//
//  Created by Jose Mota on 12/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAProductInfoPriceDescriptionLine.h"

@interface JAProductInfoPriceDescriptionLine ()

@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;

@end

@implementation JAProductInfoPriceDescriptionLine

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_priceLine setPriceSize:JAPriceSizeSmall];
        [self addSubview:_priceLine];
    }
    return _priceLine;
}

- (void)setSize:(JAPriceSize)size
{
    _size = size;
    [self.priceLine setPriceSize:size];
    [self label];
}

- (void)setPrice:(NSString *)price andOldPrice:(NSString *)oldPrice
{
    [self.priceLine setPrice:price];
    if (VALID(oldPrice, NSString)) {
        [self.priceLine setOldPrice:oldPrice];
    }
    [self.priceLine sizeHeightToFit];
    [self.priceLine flipAllSubviews];
}

- (void)setPromotionalPrice:(NSString *)price
{
    [self.priceLine setPrice:price];
    [self.priceLine sizeHeightToFit];
    [self.priceLine.label setTextColor:JAGreen1Color];
    [self.priceLine flipAllSubviews];
}

- (UILabel *)label
{
    UILabel *label = super.label;
    if (self.size) {
        [label setFont:[self priceSizeFont]];
    }else{
        [label setFont:JABodyFont];
    }
    return label;
}

- (UIFont *)priceSizeFont
{
    switch (self.size) {
        case JAPriceSizeSmall:
            return JABodyFont;
            
        case JAPriceSizeMedium:
            return JAListFont;
            
        case JAPriceSizeTitle:
            return JATitleFont;
            
        default:
            return JAListFont;
    }
}

@end
