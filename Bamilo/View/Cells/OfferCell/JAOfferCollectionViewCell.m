//
//  JAOfferCollectionViewCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAOfferCollectionViewCell.h"
#import "RISeller.h"
#import "RIProductSimple.h"
#import "JARatingsView.h"
#import "JAProductInfoPriceLine.h"
#import "Bamilo-Swift.h"

@interface JAOfferCollectionViewCell()

@property (nonatomic, strong) JAClickableView *clickableView;
@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;
@property (nonatomic, strong) UILabel *sellerLabel;
@property (nonatomic, strong) UILabel *deliveryLabel;
@property (nonatomic, strong) RIProductOffer *productOfferSeller;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UIImageView *shopFirstImageView;
@property (nonatomic, strong) UIImageView* freeShippingImageView;
@property (nonatomic, strong) UILabel* freeShippingLabel;
@property (nonatomic, strong) UILabel* sizeLabel;

@end

@implementation JAOfferCollectionViewCell

- (void)loadWithProductOffer:(RIProductOffer*)productOffer withProductSimple:(RIProductSimple* )productSimple {
    self.productOfferSeller = productOffer;
    
    if (!self.clickableView) {
        self.clickableView = [[JAClickableView alloc] init];
        [self.clickableView addTarget:self action:@selector(gotoCatalogSeller) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clickableView];
    }
    self.clickableView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    if (!self.priceLine) {
        self.priceLine = [[JAProductInfoPriceLine alloc]initWithFrame:CGRectMake(10.f, 10.f, self.width-10.f, 15.f)];
        [self.priceLine setLineContentXOffset:0.f];
        self.priceLine.priceSize = JAPriceSizeSmall;
        [self.clickableView addSubview:self.priceLine];
    }
    self.priceLine.frame = CGRectMake(10.f, 10.f, self.width-10.f, 15.f);
    
    
    CGFloat cellHeight = 114.0f;
    if (!self.addToCartClicableView) {
        self.addToCartClicableView = [[JAClickableView alloc] init];
        [self.addToCartClicableView setBackgroundColor:JAOrange1Color];
        self.addToCartClicableView.titleLabel.font = JABodyFont;
        [self.addToCartClicableView setTitleColor:JAWhiteColor forState:UIControlStateNormal];
        [self.addToCartClicableView setTitle:[STRING_BUY_NOW uppercaseString] forState:UIControlStateNormal];
        [self addSubview:self.addToCartClicableView];
    }
    [self.addToCartClicableView setFrame:CGRectMake(self.frame.size.width - 120.0f - 16.0f,
                                              (cellHeight - 40.0f) / 2,
                                              120.0f,
                                              40.0f)];
    
    if (!self.sizeClickableView) {
        self.sizeClickableView = [[JAClickableView alloc] init];
        [self addSubview:self.sizeClickableView];
    }
    self.sizeClickableView.frame = CGRectMake(10.0f,
                                              CGRectGetMaxY(self.priceLine.frame),
                                              50.0f,
                                              25.0f);
    
    if (!self.sizeLabel) {
        self.sizeLabel = [[UILabel alloc] init];
        self.sizeLabel.font = JABodyFont;
        self.sizeLabel.textColor = JABlue1Color;
        [self.sizeClickableView addSubview:self.sizeLabel];
    }
    self.sizeLabel.frame = self.sizeClickableView.bounds;
    
    if (!self.sellerLabel) {
        self.sellerLabel = [[UILabel alloc] init];

        self.sellerLabel.font = JABodyFont;
        self.sellerLabel.textColor = JABlackColor;
        self.sellerLabel.numberOfLines = 1;
        [self.clickableView addSubview:self.sellerLabel];
    }
    [self.sellerLabel setFrame:CGRectMake(10.0f, CGRectGetMaxY(self.priceLine.frame) + 25.0f, self.addToCartClicableView.x - 20.0f, 1.0f)];
    self.sellerLabel.text = productOffer.seller.name;
    [self.sellerLabel sizeToFit];
    
    if (!self.shopFirstImageView) {
        UIImage* shopFirstImage = [UIImage imageNamed:@"shop_first_logo"];
        self.shopFirstImageView = [[UIImageView alloc] initWithImage:shopFirstImage];
        
        self.shopFirstImageView.frame = CGRectMake(0.0f,
                                                   0.0f,
                                                   shopFirstImage.size.width,
                                                   shopFirstImage.size.height);
        [self.clickableView addSubview:self.shopFirstImageView];
    }
    self.shopFirstImageView.frame = CGRectMake(10.0f,
                                               CGRectGetMaxY(self.sellerLabel.frame) + 5.0f,
                                               self.shopFirstImageView.frame.size.width,
                                               self.shopFirstImageView.frame.size.height);

    if (VALID_NOTEMPTY(productOffer.shopFirst, NSNumber) && [productOffer.shopFirst boolValue]) {
        self.shopFirstImageView.hidden = NO;
    } else {
        self.shopFirstImageView.hidden = YES;
    }
    
    
    if (!self.freeShippingImageView) {
        UIImage* freeShippingImage = [UIImage imageNamed:@"freeShipping"];
        self.freeShippingImageView = [[UIImageView alloc] initWithImage:freeShippingImage];
        [self.clickableView addSubview:self.freeShippingImageView];
        [self.freeShippingImageView setFrame:CGRectMake(0.0f,
                                                        0.0f,
                                                        freeShippingImage.size.width,
                                                        freeShippingImage.size.height)];
    }
    [self.freeShippingImageView setFrame:CGRectMake(10.0f,
                                                    CGRectGetMaxY(self.shopFirstImageView.frame) + 5.0f,
                                                    self.freeShippingImageView.frame.size.width,
                                                    self.freeShippingImageView.frame.size.height)];
    
    if (!self.freeShippingLabel) {
        self.freeShippingLabel = [UILabel new];
        [self.freeShippingLabel setFont: [UIFont fontWithName:kFontRegularName size:11]];
        [self.freeShippingLabel setTextColor:JABlack800Color];
        [self.freeShippingLabel setText:STRING_FREE_SHIPPING_POSSIBLE];
        [self.freeShippingLabel sizeToFit];
        [self.clickableView addSubview:self.freeShippingLabel];
    }
    [self.freeShippingLabel setFrame:CGRectMake(CGRectGetMaxX(self.freeShippingImageView.frame) + 4.0f,
                                                self.freeShippingImageView.frame.origin.y,
                                                self.freeShippingLabel.frame.size.width,
                                                self.freeShippingLabel.frame.size.height)];
    
    
    CGFloat deliveryLabelY;
    if (productOffer.freeShippingPossible) {
        deliveryLabelY = CGRectGetMaxY(self.freeShippingImageView.frame) + 5.0f;
        self.freeShippingImageView.hidden = NO;
        self.freeShippingLabel.hidden = NO;
    } else {
        deliveryLabelY = CGRectGetMaxY(self.shopFirstImageView.frame) + 5.0f;
        self.freeShippingImageView.hidden = YES;
        self.freeShippingLabel.hidden = YES;
    }
    
    if (!self.deliveryLabel) {
        self.deliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, //set this after this if scope
                                                                       0.0f, //set this after this if scope
                                                                       self.addToCartClicableView.x - 20.0f,
                                                                       1.0)];
        self.deliveryLabel.font = JACaptionFont;
        self.deliveryLabel.textColor = JABlack800Color;
        self.deliveryLabel.text = [NSString stringWithFormat:@"%@ %ld - %ld %@", STRING_DELIVERY_WITHIN, (long)[productOffer.minDeliveryTime integerValue], (long)[productOffer.maxDeliveryTime integerValue], STRING_DAYS];
        [self.deliveryLabel sizeToFit];
        [self.clickableView addSubview:self.deliveryLabel];
    }
    [self.deliveryLabel setFrame:CGRectMake(10.0f, deliveryLabelY, self.deliveryLabel.frame.size.width, self.deliveryLabel.frame.size.height)];
    
    if (!VALID_NOTEMPTY(self.separator, UIView)) {
        self.separator = [[UIView alloc] initWithFrame:CGRectZero];
        [self.separator setBackgroundColor:JABlack300Color];
        [self addSubview:self.separator];
    }
    [self.separator setFrame:CGRectMake(0, self.height - 1, self.width, 1)];
    [self setProductSimple:productSimple];
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
        [self.sizeClickableView flipViewPositionInsideSuperview];
        [self.addToCartClicableView flipViewPositionInsideSuperview];
        [self.sizeLabel flipViewAlignment];
    }
}

-(void)setProductSimple:(RIProductSimple*)productSimple {
    if (VALID_NOTEMPTY(productSimple.specialPriceFormatted, NSString)) {
        [self.priceLine setPrice:productSimple.specialPriceFormatted];
        [self.priceLine setOldPrice:productSimple.priceFormatted];
    } else {
        [self.priceLine setPrice:productSimple.priceFormatted];
        [self.priceLine setOldPrice:@""];
    }
    
    if ([self.productOfferSeller.productSimples count] > 1) {
        self.sizeLabel.text = [NSString stringWithFormat:STRING_SIZE_WITH_VALUE,productSimple.variation];
        [self.sizeLabel setTextAlignment:NSTextAlignmentLeft];
        [self.sizeClickableView setHidden:NO];
    } else {
        [self.sizeClickableView setHidden:YES];
    }
}

-(void)gotoCatalogSeller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sellerNameTappedByProductOffer:)]) {
        [self.delegate sellerNameTappedByProductOffer:self.productOfferSeller];
    }
}


@end
