//
//  JAReviewCell.h
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (weak, nonatomic) IBOutlet UIView *viewAppearance;
@property (weak, nonatomic) IBOutlet UIView *viewQuality;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelAppearance;
@property (weak, nonatomic) IBOutlet UILabel *labelQuality;
@property (weak, nonatomic) IBOutlet UIImageView *priceStar1;
@property (weak, nonatomic) IBOutlet UIImageView *priceStar2;
@property (weak, nonatomic) IBOutlet UIImageView *priceStar3;
@property (weak, nonatomic) IBOutlet UIImageView *priceStar4;
@property (weak, nonatomic) IBOutlet UIImageView *priceStar5;
@property (weak, nonatomic) IBOutlet UIImageView *appearanceStar1;
@property (weak, nonatomic) IBOutlet UIImageView *appearanceStar2;
@property (weak, nonatomic) IBOutlet UIImageView *appearanceStar3;
@property (weak, nonatomic) IBOutlet UIImageView *appearanceStar4;
@property (weak, nonatomic) IBOutlet UIImageView *appearanceStar5;
@property (weak, nonatomic) IBOutlet UIImageView *qualityStar1;
@property (weak, nonatomic) IBOutlet UIImageView *qualityStar2;
@property (weak, nonatomic) IBOutlet UIImageView *qualityStar3;
@property (weak, nonatomic) IBOutlet UIImageView *qualityStar4;
@property (weak, nonatomic) IBOutlet UIImageView *qualityStar5;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelAuthorDate;

- (void)setPriceRating:(NSInteger)stars;

- (void)setAppearanceRating:(NSInteger)stars;

- (void)setQualityRating:(NSInteger)stars;

@end
