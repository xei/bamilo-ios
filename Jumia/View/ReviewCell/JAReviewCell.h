//
//  JAReviewCell.h
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARatingsView.h"

@interface JAReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (weak, nonatomic) IBOutlet UIView *viewAppearance;
@property (weak, nonatomic) IBOutlet UIView *viewQuality;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelAppearance;
@property (weak, nonatomic) IBOutlet UILabel *labelQuality;
@property (weak, nonatomic) JARatingsView *priceRatingsView;;
@property (weak, nonatomic) JARatingsView *appearanceRatingsView;
@property (weak, nonatomic) JARatingsView *qualityRatingsView;;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelAuthorDate;
@property (weak, nonatomic) IBOutlet UIView *separator;

- (void)setupCell:(CGRect)frame;

- (void)setPriceRating:(NSInteger)stars;

- (void)setAppearanceRating:(NSInteger)stars;

- (void)setQualityRating:(NSInteger)stars;

@end
