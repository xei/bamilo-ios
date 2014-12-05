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
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.labelPrice setTextColor:UIColorFromRGB(0x666666)];
    [self.labelAppearance setTextColor:UIColorFromRGB(0x666666)];
    [self.labelQuality setTextColor:UIColorFromRGB(0x666666)];
    [self.labelTitle setTextColor:UIColorFromRGB(0x666666)];
    [self.labelDescription setTextColor:UIColorFromRGB(0x666666)];
    [self.labelAuthorDate setTextColor:UIColorFromRGB(0x666666)];
    
    self.priceRatingsView = [JARatingsView getNewJARatingsView];
    [self.viewPrice addSubview:self.priceRatingsView];
    
    self.appearanceRatingsView = [JARatingsView getNewJARatingsView];
    [self.viewAppearance addSubview:self.appearanceRatingsView];
    
    self.qualityRatingsView = [JARatingsView getNewJARatingsView];
    [self.viewQuality addSubview:self.qualityRatingsView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setupCell:(CGRect)frame
{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              frame.size.width,
                              self.frame.size.height)];    
    
    [self setFrame:CGRectMake(self.separator.frame.origin.x,
                              self.frame.size.height - self.separator.frame.size.height,
                              frame.size.width,
                              self.separator.frame.size.height)];

    [self.priceRatingsView setFrame:CGRectMake(self.labelPrice.frame.origin.x,
                                               CGRectGetMaxY(self.labelPrice.frame) + 2.0f,
                                               self.priceRatingsView.frame.size.width,
                                               self.priceRatingsView.frame.size.height)];
    
    [self.appearanceRatingsView setFrame:CGRectMake(self.labelAppearance.frame.origin.x,
                                                    CGRectGetMaxY(self.labelAppearance.frame) + 2.0f,
                                                    self.appearanceRatingsView.frame.size.width,
                                                    self.appearanceRatingsView.frame.size.height)];
    
    [self.qualityRatingsView setFrame:CGRectMake(self.labelQuality.frame.origin.x,
                                                 CGRectGetMaxY(self.labelQuality.frame),
                                                 self.qualityRatingsView.frame.size.width + 2.0f,
                                                 self.qualityRatingsView.frame.size.height)];
}

- (void)setPriceRating:(NSInteger)stars
{
    [self.priceRatingsView setRating:stars];
}

- (void)setAppearanceRating:(NSInteger)stars
{
    [self.appearanceRatingsView setRating:stars];
}

- (void)setQualityRating:(NSInteger)stars
{
    [self.qualityRatingsView setRating:stars];
}

@end
