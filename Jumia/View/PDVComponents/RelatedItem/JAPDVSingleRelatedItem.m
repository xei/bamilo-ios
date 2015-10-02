//
//  JAPDVSingleRelatedItem.m
//  Jumia
//
//  Created by Miguel Chaves on 05/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVSingleRelatedItem.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JAPDVSingleRelatedItem ()

@property (nonatomic) UIImageView *imageViewItem;
@property (nonatomic) UILabel *labelBrand;
@property (nonatomic) UILabel *labelName;
@property (nonatomic) UILabel *labelPrice;

@end

@implementation JAPDVSingleRelatedItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

- (UILabel *)labelBrand
{
    if (!VALID_NOTEMPTY(_labelBrand, UILabel)) {
        _labelBrand = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelBrand setTextColor:JABlack800Color];
        [_labelBrand setFont:JACaptionFont];
        [self addSubview:_labelBrand];
    }
    return _labelBrand;
}

- (UILabel *)labelName
{
    if (!VALID_NOTEMPTY(_labelName, UILabel)) {
        _labelName = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelName setFont:JABody3Font];
        [_labelName setTextColor:JABlackColor];
        [self addSubview:_labelName];
    }
    return _labelName;
}

- (UILabel *)labelPrice
{
    if (!VALID_NOTEMPTY(_labelPrice, UILabel)) {
        _labelPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelPrice setFont:JACaptionFont];
        [_labelPrice setTextColor:JABlackColor];
        [self addSubview:_labelPrice];
    }
    return _labelPrice;
}

- (UIImageView *)imageViewItem
{
    if (!VALID_NOTEMPTY(_imageViewItem, UIImageView)) {
        _imageViewItem = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageViewItem];
    }
    return _imageViewItem;
}

- (void)setProduct:(RIProduct *)product
{
    if (VALID_NOTEMPTY(product.images, NSOrderedSet))
    {
        RIImage *imageTemp = [product.images firstObject];
        UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder_scrollable"];
        [self.imageViewItem setY:6.f];
//        [self.imageViewItem setWidth:placeHolderImage.size.width];
//        [self.imageViewItem setHeight:placeHolderImage.size.height];
        
        
        CGFloat ratio = placeHolderImage.size.height/placeHolderImage.size.width;
        self.imageViewItem.width = self.width - 30;
        self.imageViewItem.height = self.imageViewItem.width*ratio;
        
//        __weak typeof (self) weakSelf = self;
        [self.imageViewItem setImageWithURL:[NSURL URLWithString:imageTemp.url]
                           placeholderImage:placeHolderImage success:^(UIImage *image, BOOL cached) {
                           } failure:^(NSError *error) {
                               NSLog(@"error getting image [%@] %@", imageTemp.url, error);
                           }];
        [self.imageViewItem setXCenterAligned];
    }
    
    [self.labelPrice setX:6];
    [self.labelPrice setHeight:20];
    [self.labelPrice setWidth:self.width - 12];
    if (VALID_NOTEMPTY(product.specialPrice, NSNumber) && 0.0f == [product.specialPrice floatValue]) {
        self.labelPrice.text = product.priceFormatted;
    } else {
        self.labelPrice.text = product.specialPriceFormatted;
    }
    [self.labelPrice setYBottomAligned:0];
    
    [self.labelName setX:6];
    [self.labelName setYTopOf:self.labelPrice at:20];
    [self.labelName setWidth:self.width - 12];
    [self.labelName setHeight:20];
    self.labelName.text = product.name;
    
    [self.labelBrand setX:6];
    [self.labelBrand setYTopOf:self.labelName at:20];
    [self.labelBrand setWidth:self.width - 12];
    [self.labelBrand setHeight:20];
    self.labelBrand.text = product.brand;
    
}

- (void)setSearchTypeProduct:(RISearchTypeProduct *)product
{
    if (VALID_NOTEMPTY(product.imagesArray, NSOrderedSet))
    {
        RIImage *imageTemp = [product.imagesArray firstObject];
        
        [self.imageViewItem setImageWithURL:[NSURL URLWithString:imageTemp.url]
                           placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
    }
    
    self.labelBrand.text = product.brand;
    self.labelName.text = product.name;
    self.labelPrice.text = product.priceFormatted;
    
}

@end
