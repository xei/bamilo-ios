//
//  JAProductInfoPriceDescriptionLine.m
//  Jumia
//
//  Created by Jose Mota on 12/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAProductInfoPriceDescriptionLine.h"

@interface JAProductInfoPriceDescriptionLine ()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;

@end

@implementation JAProductInfoPriceDescriptionLine

- (UILabel *)descriptionLabel
{
    CGRect frame = CGRectMake(self.lineContentXOffset, 6, self.width-32, self.height-12);
    if (!VALID_NOTEMPTY(_descriptionLabel, UILabel)) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:frame];
        [_descriptionLabel setFont:JABodyFont];
        [_descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [_descriptionLabel setTextColor:JABlackColor];
        [_descriptionLabel setText:@""];
        [_descriptionLabel sizeToFit];
        [_descriptionLabel setY:self.height/2-_descriptionLabel.height/2];
        [self addSubview:_descriptionLabel];
    }
    return _descriptionLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_priceLine setPriceSize:JAPriceSizeSmall];
        [self addSubview:_priceLine];
    }
    return _priceLine;
}

- (void)setTitle:(NSString *)title
{
    [self.descriptionLabel setText:title];
    [self reload];
}

- (void)setSize:(JAPriceSize)size
{
    _size = size;
    [self.priceLine setPriceSize:size];
    [self.descriptionLabel setFont:[self priceSizeFont]];
    [self reload];
}

- (void)setPrice:(NSString *)price andOldPrice:(NSString *)oldPrice
{
    [self.priceLine setPrice:price];
    if (VALID(oldPrice, NSString)) {
        [self.priceLine setOldPrice:oldPrice];
    }
    [self reload];
}

- (void)reload
{
    [self.priceLine sizeToFit];
    [self.priceLine setYCenterAligned];
    [self.priceLine setXRightAligned:0.f];
    [self.priceLine flipAllSubviews];
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel setYCenterAligned];
    [self.descriptionLabel setWidth:self.priceLine.x - self.descriptionLabel.x - 10.f];
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
