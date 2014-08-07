//
//  JAReviewCell.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAReviewCell.h"

@implementation JAReviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

    }
    
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setPriceRating:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.priceStar1.image = [self getEmptyStar];
            self.priceStar2.image = [self getEmptyStar];
            self.priceStar3.image = [self getEmptyStar];
            self.priceStar4.image = [self getEmptyStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.priceStar1.image = [self getFilledStar];
            self.priceStar2.image = [self getEmptyStar];
            self.priceStar3.image = [self getEmptyStar];
            self.priceStar4.image = [self getEmptyStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.priceStar1.image = [self getFilledStar];
            self.priceStar2.image = [self getFilledStar];
            self.priceStar3.image = [self getEmptyStar];
            self.priceStar4.image = [self getEmptyStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.priceStar1.image = [self getFilledStar];
            self.priceStar2.image = [self getFilledStar];
            self.priceStar3.image = [self getFilledStar];
            self.priceStar4.image = [self getEmptyStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.priceStar1.image = [self getFilledStar];
            self.priceStar2.image = [self getFilledStar];
            self.priceStar3.image = [self getFilledStar];
            self.priceStar4.image = [self getFilledStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.priceStar1.image = [self getFilledStar];
            self.priceStar2.image = [self getFilledStar];
            self.priceStar3.image = [self getFilledStar];
            self.priceStar4.image = [self getFilledStar];
            self.priceStar5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.priceStar1.image = [self getEmptyStar];
            self.priceStar2.image = [self getEmptyStar];
            self.priceStar3.image = [self getEmptyStar];
            self.priceStar4.image = [self getEmptyStar];
            self.priceStar5.image = [self getEmptyStar];
            
        }
            break;
    }
}

- (void)setAppearanceRating:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.appearanceStar1.image = [self getEmptyStar];
            self.appearanceStar2.image = [self getEmptyStar];
            self.appearanceStar3.image = [self getEmptyStar];
            self.appearanceStar4.image = [self getEmptyStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.appearanceStar1.image = [self getFilledStar];
            self.appearanceStar2.image = [self getEmptyStar];
            self.appearanceStar3.image = [self getEmptyStar];
            self.appearanceStar4.image = [self getEmptyStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.appearanceStar1.image = [self getFilledStar];
            self.appearanceStar2.image = [self getFilledStar];
            self.appearanceStar3.image = [self getEmptyStar];
            self.appearanceStar4.image = [self getEmptyStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.appearanceStar1.image = [self getFilledStar];
            self.appearanceStar2.image = [self getFilledStar];
            self.appearanceStar3.image = [self getFilledStar];
            self.appearanceStar4.image = [self getEmptyStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.appearanceStar1.image = [self getFilledStar];
            self.appearanceStar2.image = [self getFilledStar];
            self.appearanceStar3.image = [self getFilledStar];
            self.appearanceStar4.image = [self getFilledStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.appearanceStar1.image = [self getFilledStar];
            self.appearanceStar2.image = [self getFilledStar];
            self.appearanceStar3.image = [self getFilledStar];
            self.appearanceStar4.image = [self getFilledStar];
            self.appearanceStar5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.appearanceStar1.image = [self getEmptyStar];
            self.appearanceStar2.image = [self getEmptyStar];
            self.appearanceStar3.image = [self getEmptyStar];
            self.appearanceStar4.image = [self getEmptyStar];
            self.appearanceStar5.image = [self getEmptyStar];
            
        }
            break;
    }
}

- (void)setQualityRating:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.qualityStar1.image = [self getEmptyStar];
            self.qualityStar2.image = [self getEmptyStar];
            self.qualityStar3.image = [self getEmptyStar];
            self.qualityStar4.image = [self getEmptyStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.qualityStar1.image = [self getFilledStar];
            self.qualityStar2.image = [self getEmptyStar];
            self.qualityStar3.image = [self getEmptyStar];
            self.qualityStar4.image = [self getEmptyStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.qualityStar1.image = [self getFilledStar];
            self.qualityStar2.image = [self getFilledStar];
            self.qualityStar3.image = [self getEmptyStar];
            self.qualityStar4.image = [self getEmptyStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.qualityStar1.image = [self getFilledStar];
            self.qualityStar2.image = [self getFilledStar];
            self.qualityStar3.image = [self getFilledStar];
            self.qualityStar4.image = [self getEmptyStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.qualityStar1.image = [self getFilledStar];
            self.qualityStar2.image = [self getFilledStar];
            self.qualityStar3.image = [self getFilledStar];
            self.qualityStar4.image = [self getFilledStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.qualityStar1.image = [self getFilledStar];
            self.qualityStar2.image = [self getFilledStar];
            self.qualityStar3.image = [self getFilledStar];
            self.qualityStar4.image = [self getFilledStar];
            self.qualityStar5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.qualityStar1.image = [self getEmptyStar];
            self.qualityStar2.image = [self getEmptyStar];
            self.qualityStar3.image = [self getEmptyStar];
            self.qualityStar4.image = [self getEmptyStar];
            self.qualityStar5.image = [self getEmptyStar];
            
        }
            break;
    }
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end
