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
#import "JAClickableView.h"
#import "JAProductInfoPriceLine.h"

@interface JAOfferCollectionViewCell()
@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;
@property (weak, nonatomic) IBOutlet UILabel *sellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (nonatomic, strong) RIProductOffer *productOfferSeller;
@property (nonatomic) UIView *separator;
@property (nonatomic) UIImageView *shopFirstImageView;

@end

@implementation JAOfferCollectionViewCell

- (UIImageView*)shopFirstImageView
{
    if (!VALID_NOTEMPTY(_shopFirstImageView, UIImageView)) {
        
        UIImage *shopFirstImage = [UIImage imageNamed:@"shop_first_logo"];
        _shopFirstImageView = [[UIImageView alloc] initWithImage:shopFirstImage];
        [_shopFirstImageView setFrame:CGRectMake(10.f, CGRectGetMaxY(self.sellerLabel.frame), shopFirstImage.size.width, shopFirstImage.size.height)];
    }
    return _shopFirstImageView;
}

- (void)loadWithProductOffer:(RIProductOffer*)productOffer withProductSimple:(RIProductSimple* )productSimple
{
    self.backgroundColor = [UIColor clearColor];
    
    if (VALID_NOTEMPTY(self.priceLine, JAProductInfoPriceLine)) {
        [self.priceLine removeFromSuperview];
    }
    
    
    self.priceLine = [[JAProductInfoPriceLine alloc]initWithFrame:CGRectMake(10.f, 10.f, self.width-10.f, 15.f)];
    [self.priceLine setLineContentXOffset:0.f];
    self.priceLine.priceSize = kPriceSizeSmall;
    [self addSubview:self.priceLine];
    
    self.productOfferSeller = productOffer;
    [self setProductSimple:productSimple];
    
    [self.backgroundContentView setX:0.f];
    [self.backgroundContentView setWidth:self.width];
    self.backgroundContentView.backgroundColor = [UIColor whiteColor];
    self.backgroundContentView.layer.cornerRadius = 5.0f;
    
    [self.addToCartButton setBackgroundColor:JAOrange1Color];
    [self.addToCartButton setXRightAligned:16.f];
    [self.addToCartButton setYCenterAligned];
    self.addToCartButton.titleLabel.font = JABodyFont;
    [self.addToCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addToCartButton setTitle:STRING_BUY_NOW forState:UIControlStateNormal];
    
    [self.priceLabel setWidth:self.addToCartButton.x - 20];
    [self.priceLabel setX:10.f];
    self.priceLabel.font = JABodyFont;
    self.priceLabel.textColor = JABlackColor;
    [self.priceLabel setHidden:YES];
    
    [self.sellerLabel setX:10.f];
    [self.sellerLabel setWidth:self.addToCartButton.x - 20];
    self.sellerLabel.font = JABodyFont;
    self.sellerLabel.textColor = JABlackColor;
    self.sellerLabel.numberOfLines = 1;
    self.sellerLabel.text = productOffer.seller.name;
    [self.sellerLabel sizeToFit];
    
    self.clickableView.layer.cornerRadius = 5.0f;
    [self.clickableView setX:0.f];
    [self.clickableView setWidth:self.backgroundContentView.width];
    [self.clickableView addTarget:self action:@selector(gotoCatalogSeller) forControlEvents:UIControlEventTouchUpInside];
    
    [self.deliveryLabel setWidth:self.addToCartButton.x - 20];
    [self.deliveryLabel setX:10.f];
    self.deliveryLabel.font = JACaptionFont;
    self.deliveryLabel.textColor = JABlack800Color;
    self.deliveryLabel.text = [NSString stringWithFormat:@"%@ %ld - %ld %@", STRING_DELIVERY_WITHIN, (long)[productOffer.minDeliveryTime integerValue], (long)[productOffer.maxDeliveryTime integerValue], STRING_DAYS];
    [self.deliveryLabel sizeToFit];
    
    if (!VALID_NOTEMPTY(self.separator, UIView)) {
        self.separator = [[UIView alloc] initWithFrame:CGRectZero];
        [self.separator setBackgroundColor:JABlack300Color];
        [self addSubview:self.separator];
    }
    [self.separator setFrame:CGRectMake(0, self.height - 1, self.width, 1)];
    
    if (!VALID(self.shopFirstImageView.superview, UIView)) {
        [self.backgroundContentView addSubview:self.shopFirstImageView];
    }
    [self.shopFirstImageView setX:10.f];
    if (VALID_NOTEMPTY(productOffer.shopFirst, NSNumber) && [productOffer.shopFirst boolValue]) {
        self.shopFirstImageView.hidden = NO;
    } else {
        self.shopFirstImageView.hidden = YES;
    }
    
    CGFloat sellerLabelMaxWidth = self.addToCartButton.x - self.sellerLabel.x - 6.f;
    if (self.sellerLabel.width > sellerLabelMaxWidth) {
        [self.sellerLabel setWidth:sellerLabelMaxWidth];
    }
    
    if (RI_IS_RTL) {
        [self.backgroundContentView flipAllSubviews];
        [self.priceLine flipViewPositionInsideSuperview];
        [self.priceLine flipAllSubviews];
    }
}

-(void)setProductSimple:(RIProductSimple*)productSimple {
    if (VALID_NOTEMPTY(productSimple.specialPriceFormatted, NSString)) {
        self.priceLabel.text = productSimple.specialPriceFormatted;
        [self.priceLine setPrice:productSimple.specialPriceFormatted];
        [self.priceLine setOldPrice:productSimple.priceFormatted];
    } else {
        self.priceLabel.text = productSimple.priceFormatted;
        [self.priceLine setPrice:productSimple.priceFormatted];
        [self.priceLine setOldPrice:@""];
    }
    [self.priceLabel sizeToFit];
    
    if ([self.productOfferSeller.productSimples count] > 1) {
        [self.sizeButton setWidth:self.width-10-self.addToCartButton.x];
        [self.sizeButton setX:10.f];
        self.sizeButton.titleLabel.font = JABodyFont;
        [self.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE,productSimple.variation]
                         forState:UIControlStateNormal];
        [self.sizeButton sizeToFit];
        [self.sizeButton setHidden:NO];
    } else
        [self.sizeButton setHidden:YES];
}

-(void)gotoCatalogSeller
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    
    if(VALID_NOTEMPTY(self.productOfferSeller.seller, RISeller))
    {
        if (VALID_NOTEMPTY(self.productOfferSeller.seller.targetString, NSString)) {
        [userInfo setObject:self.productOfferSeller.seller.name forKey:@"name"];
        [userInfo setObject:self.productOfferSeller.seller.targetString forKey:@"targetString"];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSellerPage object:self.productOfferSeller.seller userInfo:userInfo];
        }
    }
}


@end
