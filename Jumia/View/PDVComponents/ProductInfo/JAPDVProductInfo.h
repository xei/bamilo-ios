//
//  JAPDVProductInfo.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPDVProductInfo : UIView

@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet UIView *reviewsView;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToReviewsImageView;
@property (weak, nonatomic) IBOutlet UILabel *specificationsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToSpecificationsImageView;
@property (weak, nonatomic) IBOutlet UIButton *goToReviewsButton;
@property (weak, nonatomic) IBOutlet UIButton *goToSpecificationsButton;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImageViewSeparator;

+ (JAPDVProductInfo *)getNewPDVProductInfoSection;

- (void)setup;

- (void)setNumberOfStars:(NSInteger)stars;

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue;

- (void)removeSizeOptions;

@end
