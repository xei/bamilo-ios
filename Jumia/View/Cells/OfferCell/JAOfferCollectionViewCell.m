//
//  JAOfferCollectionViewCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAOfferCollectionViewCell.h"
#import "RISeller.h"
#import "JARatingsView.h"
#import "JAClickableView.h"

@interface JAOfferCollectionViewCell()
@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (nonatomic, strong) JARatingsView* ratingsView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (nonatomic, strong) RIProductOffer *productOfferSeller;

@end

@implementation JAOfferCollectionViewCell

- (void)loadWithProductOffer:(RIProductOffer*)productOffer
{
    self.backgroundColor = [UIColor clearColor];
    self.productOfferSeller = productOffer;
    [self.backgroundContentView setX:0.f];
    [self.backgroundContentView setWidth:self.width];
    self.backgroundContentView.backgroundColor = [UIColor whiteColor];
    self.backgroundContentView.layer.cornerRadius = 5.0f;
    
    [self.priceLabel setX:6.f];
    self.priceLabel.font = [UIFont fontWithName:kFontBoldName size:self.priceLabel.font.pointSize];
    self.priceLabel.textColor = UIColorFromRGB(0xcc0000);
    if (VALID_NOTEMPTY(productOffer.specialPriceFormatted, NSString)) {
        self.priceLabel.text = productOffer.specialPriceFormatted;
    } else {
        self.priceLabel.text = productOffer.priceFormatted;
    }
    [self.priceLabel sizeToFit];
    
    [self.sellerLabel setX:6.f];
    self.sellerLabel.font = [UIFont fontWithName:kFontBoldName size:self.sellerLabel.font.pointSize];
    self.sellerLabel.textColor = UIColorFromRGB(0x666666);
    self.sellerLabel.text = productOffer.seller.name;
    [self.sellerLabel sizeToFit];
    
    self.clickableView.layer.cornerRadius = 5.0f;
    [self.clickableView setX:0.f];
    [self.clickableView setWidth:self.backgroundContentView.width];
    [self.clickableView addTarget:self action:@selector(gotoCatalogSeller) forControlEvents:UIControlEventTouchUpInside];
    
    [self.deliveryLabel setX:6.f];
    self.deliveryLabel.font = [UIFont fontWithName:kFontLightName size:self.deliveryLabel.font.pointSize];
    self.deliveryLabel.textColor = UIColorFromRGB(0x666666);
    self.deliveryLabel.text = [NSString stringWithFormat:@"%@ %ld - %ld %@", STRING_DELIVERY_WITHIN, (long)[productOffer.minDeliveryTime integerValue], (long)[productOffer.maxDeliveryTime integerValue], STRING_DAYS];
    [self.deliveryLabel sizeToFit];
    
    [self.ratingsView removeFromSuperview];
    self.ratingsView = [JARatingsView getNewJARatingsView];
    [self.ratingsView setFrame:CGRectMake(self.deliveryLabel.frame.origin.x,
                                          self.deliveryLabel.frame.origin.y - self.ratingsView.frame.size.height - 5.0f,
                                          self.ratingsView.frame.size.width,
                                          self.ratingsView.frame.size.height)];
    [self.ratingsView setRating:[productOffer.seller.reviewAverage integerValue]];
    [self.backgroundContentView addSubview:self.ratingsView];
    [self.ratingsView sizeToFit];
    
    [self.ratingLabel setX:CGRectGetMaxX(self.ratingsView.frame) + 5.f];
    [self.ratingLabel setY:self.ratingsView.y];
    self.ratingLabel.font = [UIFont fontWithName:kFontLightName size:self.ratingLabel.font.pointSize];
    self.ratingLabel.textColor = UIColorFromRGB(0xcccccc);
    
    if (1 == [productOffer.seller.reviewTotal integerValue]) {
        self.ratingLabel.text = STRING_REVIEW;
    } else {
        self.ratingLabel.text = [NSString stringWithFormat:STRING_REVIEWS, [productOffer.seller.reviewTotal integerValue]];
    }
    [self.ratingLabel sizeToFit];
    
    [self.addToCartButton setXRightAligned:6.f];
    self.addToCartButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.addToCartButton.titleLabel.font.pointSize];
    [self.addToCartButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.addToCartButton setTitle:STRING_ADD_TO_SHOPPING_CART forState:UIControlStateNormal];
    
    if (RI_IS_RTL) {
        [self.backgroundContentView flipAllSubviews];
    }
}

-(void)gotoCatalogSeller
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    
    if(VALID_NOTEMPTY(self.productOfferSeller.seller, RISeller))
    {
        [userInfo setObject:self.productOfferSeller.seller.name forKey:@"name"];
    }
    
    if(VALID_NOTEMPTY(self.productOfferSeller.seller, RISeller))
    {
        [userInfo setObject:self.productOfferSeller.seller.url forKey:@"url"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSellerPage object:self.productOfferSeller.seller userInfo:userInfo];
}


@end
