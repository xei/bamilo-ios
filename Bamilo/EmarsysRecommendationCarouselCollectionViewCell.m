//
//  EmarsysRecommendationCarouselCollectionViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselCollectionViewCell.h"

@interface EmarsysRecommendationCarouselCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;
@end

@implementation EmarsysRecommendationCarouselCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    self.cellBackgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.cellBackgroundView.layer.shadowOpacity = 0.2;
    self.cellBackgroundView.layer.shadowOffset = CGSizeMake(0, 1);
    self.cellBackgroundView.layer.shadowRadius = 1;
    self.cellBackgroundView.layer.cornerRadius = 3;
}

+ (CGSize)preferedSize {
    return CGSizeMake(133, 230);
}

@end
