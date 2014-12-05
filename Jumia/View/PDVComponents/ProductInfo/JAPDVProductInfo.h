//
//  JAPDVProductInfo.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIProduct;

@interface JAPDVProductInfo : UIView

@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet JAClickableView *sizeClickableView;
@property (weak, nonatomic) IBOutlet JAClickableView *reviewsClickableView;
@property (weak, nonatomic) IBOutlet JAClickableView* specificationsClickableView;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *specificationsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToSpecificationsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *priceSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImageViewSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *ratingsSeparator;

@property (weak, nonatomic) IBOutlet UIButton *productFeaturesMore;
@property (weak, nonatomic) IBOutlet UIButton *productDescriptionMore;

+ (JAPDVProductInfo *)getNewPDVProductInfoSection;

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize numberOfRatings:(NSString*)numberOfRatings;

@end
