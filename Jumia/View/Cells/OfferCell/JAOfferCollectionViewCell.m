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

@interface JAOfferCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (nonatomic, strong) JARatingsView* ratingsView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

@end

@implementation JAOfferCollectionViewCell

- (void)loadWithProductOffer:(RIProductOffer*)productOffer
{
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundContentView.backgroundColor = [UIColor whiteColor];
    self.backgroundContentView.layer.cornerRadius = 5.0f;
    
    self.priceLabel.textColor = UIColorFromRGB(0xcc0000);
    self.priceLabel.text = productOffer.priceFormatted;
    
    self.sellerLabel.textColor = UIColorFromRGB(0x666666);
    self.sellerLabel.text = productOffer.seller.name;
    
    self.deliveryLabel.textColor = UIColorFromRGB(0x666666);
    self.deliveryLabel.text = [NSString stringWithFormat:@"%@ %d - %d %@", STRING_DELIVERY_WITHIN, [productOffer.minDeliveryTime integerValue], [productOffer.maxDeliveryTime integerValue], STRING_DAYS];
    
    [self.ratingsView removeFromSuperview];
    self.ratingsView = [JARatingsView getNewJARatingsView];
    [self.ratingsView setFrame:CGRectMake(self.deliveryLabel.frame.origin.x,
                                          self.deliveryLabel.frame.origin.y - self.ratingsView.frame.size.height - 5.0f,
                                          self.ratingsView.frame.size.width,
                                          self.ratingsView.frame.size.height)];
    [self.ratingsView setRating:[productOffer.seller.reviewAverage integerValue]];
    [self.backgroundContentView addSubview:self.ratingsView];
    
    self.ratingLabel.textColor = UIColorFromRGB(0xcccccc);
    
    if (1 == [productOffer.seller.reviewTotal integerValue]) {
        self.ratingLabel.text = STRING_REVIEW;
    } else {
        self.ratingLabel.text = [NSString stringWithFormat:STRING_REVIEWS, [productOffer.seller.reviewTotal integerValue]];
    }
    
    [self.addToCartButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.addToCartButton setTitle:STRING_ADD_TO_SHOPPING_CART forState:UIControlStateNormal];
}

@end
