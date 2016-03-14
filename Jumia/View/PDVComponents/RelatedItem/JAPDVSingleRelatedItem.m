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
@property (nonatomic) UIImageView *favoriteImage;

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
        [_labelBrand setFont:JABodyFont];
        [_labelBrand setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelBrand];
    }
    return _labelBrand;
}

- (UILabel *)labelName
{
    if (!VALID_NOTEMPTY(_labelName, UILabel)) {
        _labelName = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelName setFont:JATitleFont];
        [_labelName setTextColor:JABlackColor];
        [_labelBrand setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelName];
    }
    return _labelName;
}

- (UILabel *)labelPrice
{
    if (!VALID_NOTEMPTY(_labelPrice, UILabel)) {
        _labelPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelPrice setFont:JABodyFont];
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

- (UIImageView *)favoriteImage
{
    if (!VALID_NOTEMPTY(_favoriteImage, UIImageView)) {
        _favoriteImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_favoriteImage setContentMode:UIViewContentModeCenter];
        [_favoriteImage setImage:[UIImage imageNamed:@"FavButton"]];
        [_favoriteImage setHidden:YES];
        [self addSubview:_favoriteImage];
    }
    return _favoriteImage;
}

- (void)setTeaserComponent:(RITeaserComponent *)teaserComponent
{
    RIProduct *product = [[RIProduct alloc] init];
    product.sku = teaserComponent.sku;
    product.name = teaserComponent.name;
    product.brand = teaserComponent.brand;
    RIImage *image = [RIImage parseImage:@{@"url" : teaserComponent.imagePortraitUrl}];
    product.images = @[image];
    product.specialPrice = teaserComponent.specialPrice;
    product.priceFormatted = teaserComponent.priceFormatted;
    product.specialPriceFormatted = teaserComponent.specialPriceFormatted;
    [self setProduct:product];
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder_scrollable"];
    [self.imageViewItem setY:6.f];
    CGFloat ratio = placeHolderImage.size.height/placeHolderImage.size.width;
    self.imageViewItem.width = self.width - 30;
    self.imageViewItem.height = self.imageViewItem.width*ratio;
    [self.imageViewItem setXCenterAligned];
    
    if (VALID_NOTEMPTY(product.images, NSArray))
    {
        RIImage *imageTemp = [product.images firstObject];
        [self.imageViewItem setImageWithURL:[NSURL URLWithString:imageTemp.url]
                           placeholderImage:placeHolderImage success:^(UIImage *image, BOOL cached) {
                           } failure:nil];
    }else{
        [self.imageViewItem setImage:placeHolderImage];
    }
    
    [self.labelPrice setX:6];
    [self.labelPrice setHeight:20];
    [self.labelPrice setWidth:self.width - 12];
    if (!VALID_NOTEMPTY(product.specialPrice, NSNumber) || 0.0f == [product.specialPrice floatValue]) {
        self.labelPrice.text = product.priceFormatted;
    } else {
        self.labelPrice.text = product.specialPriceFormatted;
    }
    [self.labelPrice setYBottomAligned:10];
    [self.labelPrice setTextAlignment:NSTextAlignmentLeft];
    
    [self.labelName setX:6];
    [self.labelName setYTopOf:self.labelPrice at:20];
    [self.labelName setWidth:self.width - 12];
    [self.labelName setHeight:20];
    self.labelName.text = product.name;
    [self.labelName setTextAlignment:NSTextAlignmentLeft];
    
    [self.labelBrand setX:6];
    [self.labelBrand setYTopOf:self.labelName at:20];
    [self.labelBrand setWidth:self.width - 12];
    [self.labelBrand setHeight:20];
    self.labelBrand.text = product.brand;
    [self.labelBrand setTextAlignment:NSTextAlignmentLeft];
    
    [self.favoriteImage setFrame:CGRectMake(self.width - 28, 10, 22, 22)];
    [self setFavorite:VALID_NOTEMPTY(self.product.favoriteAddDate, NSDate)];
}

- (void)setFavorite:(BOOL)favorite
{
    if (favorite) {
        [self.favoriteImage setImage:[UIImage imageNamed:@"FavButtonPressed"]];
    }else{
        [self.favoriteImage setImage:[UIImage imageNamed:@"FavButton"]];
    }
}

- (void)setSearchTypeProduct:(RISearchTypeProduct *)product
{
    if (VALID_NOTEMPTY(product.image, NSString))
    {
        [self.imageViewItem setImageWithURL:[NSURL URLWithString:product.image]
                           placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
        [self.imageViewItem setX:30.f];
        [self.imageViewItem setY:6.f];
        
        CGFloat ratio = self.imageViewItem.image.size.height/self.imageViewItem.image.size.width;
        self.imageViewItem.width = self.width - 60;
        self.imageViewItem.height = self.imageViewItem.width*ratio;
    }
    if (VALID_NOTEMPTY(product.priceFormatted, NSString)) {
        self.labelPrice.text = product.priceFormatted;
        [self.labelPrice setX:6];
        [self.labelPrice setY:self.height - 13];
        [self.labelPrice setTextAlignment:NSTextAlignmentCenter];
        [self.labelPrice setTextColor:[UIColor redColor]];
        [self.labelPrice setHeight:10];
        [self.labelPrice setWidth:self.width - 12];
    }
    if (VALID_NOTEMPTY(product.name, NSString)) {
        self.labelName.text = product.name;
        [self.labelName setX:6];
        [self.labelName setYTopOf:self.labelPrice at:13];
        [self.labelName setTextAlignment:NSTextAlignmentCenter];
        [self.labelName setFont:JACaptionFont];
        [self.labelName setTextColor:JABlack800Color];
        [self.labelName setHeight:10];
        [self.labelName setWidth:self.width - 12];
    }
    if (VALID_NOTEMPTY(product.brand, NSString)) {
        self.labelBrand.text = product.brand;
        [self.labelBrand setX:6];
        [self.labelBrand setYTopOf:self.labelName at:13];
        [self.labelBrand setTextAlignment:NSTextAlignmentCenter];
        [self.labelBrand setHeight:10];
        [self.labelBrand setWidth:self.width - 12];
    }
}

@end
