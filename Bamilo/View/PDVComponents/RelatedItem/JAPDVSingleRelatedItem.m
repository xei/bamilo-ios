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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

- (UILabel *)labelBrand {
    if (!_labelBrand) {
        _labelBrand = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelBrand setTextColor:JABlack800Color];
        [_labelBrand setFont:JABodyFont];
        [_labelBrand setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelBrand];
    }
    return _labelBrand;
}

- (UILabel *)labelName {
    if (!_labelName) {
        _labelName = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelName setFont:JATitleFont];
        [_labelName setTextColor:JABlackColor];
        [_labelBrand setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelName];
    }
    return _labelName;
}

- (UILabel *)labelPrice {
    if (!_labelPrice) {
        _labelPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labelPrice setFont:JABodyFont];
        [_labelPrice setTextColor:JABlackColor];
        [self addSubview:_labelPrice];
    }
    return _labelPrice;
}

- (UIImageView *)imageViewItem {
    if (!_imageViewItem) {
        _imageViewItem = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageViewItem];
    }
    return _imageViewItem;
}

- (UIImageView *)favoriteImage {
    if (!_favoriteImage) {
        _favoriteImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_favoriteImage setContentMode:UIViewContentModeCenter];
        [_favoriteImage setImage:[UIImage imageNamed:@"FavButton"]];
        [_favoriteImage setHidden:YES];
        [self addSubview:_favoriteImage];
    }
    return _favoriteImage;
}

- (void)setTeaserComponent:(RITeaserComponent *)teaserComponent {
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

- (void)setProduct:(RIProduct *)product {
    _product = product;
    
    UIImage *placeHolderImage = [UIImage imageNamed:@"placeholder_scrollable"];
    [self.imageViewItem setY:10.f];
    CGFloat ratio = placeHolderImage.size.height/placeHolderImage.size.width;
    self.imageViewItem.width = self.width - 36;
    self.imageViewItem.height = self.imageViewItem.width*ratio;
    [self.imageViewItem setXCenterAligned];
    
    if (product.images.count) {
        RIImage *imageTemp = [product.images firstObject];
        [self.imageViewItem sd_setImageWithURL:[NSURL URLWithString:imageTemp.url] placeholderImage:placeHolderImage completed:nil];
    } else {
        [self.imageViewItem setImage:placeHolderImage];
    }
    
    self.labelBrand.text = product.brand;
    [self.labelBrand setTextAlignment:NSTextAlignmentLeft];
    [self.labelBrand setX:6];
    [self.labelBrand setYBottomOf:self.imageViewItem at:10];
    [self.labelBrand setHeight:10];
    [self.labelBrand sizeToFit];
    [self.labelBrand setWidth:self.width - 12];
    
    self.labelName.text = product.name;
    [self.labelName setTextAlignment:NSTextAlignmentLeft];
    [self.labelName setX:6];
    [self.labelName setYBottomOf:self.labelBrand at:1];
    [self.labelName setHeight:20];
    [self.labelName sizeToFit];
    [self.labelName setWidth:self.width - 12];
    
    if (!product.specialPrice || 0.0f == [product.specialPrice floatValue]) {
        self.labelPrice.text = product.priceFormatted;
    } else {
        self.labelPrice.text = product.specialPriceFormatted;
    }
    [self.labelPrice setYBottomOf:self.labelName at:1];
    [self.labelPrice setTextAlignment:NSTextAlignmentLeft];
    [self.labelPrice setX:6];
    [self.labelPrice setHeight:10];
    [self.labelPrice sizeToFit];
    [self.labelPrice setWidth:self.width - 12];
    
    [self.favoriteImage setFrame:CGRectMake(self.width - 28, 10, 22, 22)];
    [self setFavorite:self.product.favoriteAddDate];
}

- (void)setFavorite:(BOOL)favorite {
    if (favorite) {
        [self.favoriteImage setImage:[UIImage imageNamed:@"FavButtonPressed"]];
    }else{
        [self.favoriteImage setImage:[UIImage imageNamed:@"FavButton"]];
    }
}

- (void)setSearchTypeProduct:(RISearchTypeProduct *)product {
    if (product.image.length) {
        [self.imageViewItem setImageWithURL:[NSURL URLWithString:product.image]
                           placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
        [self.imageViewItem setX:30.f];
        [self.imageViewItem setY:6.f];
        
        CGFloat ratio = self.imageViewItem.image.size.height/self.imageViewItem.image.size.width;
        self.imageViewItem.width = self.width - 60;
        self.imageViewItem.height = self.imageViewItem.width*ratio;
    }
    if (product.priceFormatted.length) {
        self.labelPrice.text = product.priceFormatted;
        [self.labelPrice setX:6];
        [self.labelPrice setY:self.height - 13];
        [self.labelPrice setTextAlignment:NSTextAlignmentCenter];
        [self.labelPrice setTextColor:JARed1Color];
        [self.labelPrice setHeight:10];
        [self.labelPrice setWidth:self.width - 12];
    }
    if (product.name.length) {
        self.labelName.text = product.name;
        [self.labelName setX:6];
        [self.labelName setYTopOf:self.labelPrice at:13];
        [self.labelName setTextAlignment:NSTextAlignmentCenter];
        [self.labelName setFont:JACaptionFont];
        [self.labelName setTextColor:JABlack800Color];
        [self.labelName setHeight:10];
        [self.labelName setWidth:self.width - 12];
    }
    if (product.brand.length) {
        self.labelBrand.text = product.brand;
        [self.labelBrand setX:6];
        [self.labelBrand setYTopOf:self.labelName at:13];
        [self.labelBrand setTextAlignment:NSTextAlignmentCenter];
        [self.labelBrand setHeight:10];
        [self.labelBrand setWidth:self.width - 12];
    }
}

@end
