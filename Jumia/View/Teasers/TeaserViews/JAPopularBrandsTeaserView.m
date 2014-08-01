//
//  JAPopularBrandsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPopularBrandsTeaserView.h"

#define JAPopularBrandsTeaserViewHorizontalMargin 6.0f
#define JAPopularBrandsTeaserViewContentY 4.0f
#define JAPopularBrandsTeaserViewContentCornerRadius 3.0f
#define JAPopularBrandsTeaserViewTitleHeight 26.0f
#define JAPopularBrandsTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
#define JAPopularBrandsTeaserViewTitleColor UIColorFromRGB(0x4e4e4e)
#define JAPopularBrandsTeaserViewLineColor UIColorFromRGB(0xfaa41a)
#define JAPopularBrandsTeaserViewCellMargin 16.0f
#define JAPopularBrandsTeaserViewCellHeight 30.0f
#define JAPopularBrandsTeaserViewCellFont [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f]
#define JAPopularBrandsTeaserViewCellColor UIColorFromRGB(0x4e4e4e)

@implementation JAPopularBrandsTeaserView

- (void)load;
{
    [super load];
    
    self.backgroundColor = [UIColor grayColor];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JAPopularBrandsTeaserViewHorizontalMargin,
                                                                   JAPopularBrandsTeaserViewContentY,
                                                                   self.bounds.size.width - JAPopularBrandsTeaserViewHorizontalMargin*2,
                                                                   1)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = JAPopularBrandsTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    CGFloat currentY = contentView.bounds.origin.y;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JAPopularBrandsTeaserViewHorizontalMargin,
                                                                    currentY,
                                                                    contentView.bounds.size.width - JAPopularBrandsTeaserViewHorizontalMargin*2,
                                                                    JAPopularBrandsTeaserViewTitleHeight)];
    titleLabel.text = @"Top Brands";
    titleLabel.font = JAPopularBrandsTeaserViewTitleFont
    titleLabel.textColor = JAPopularBrandsTeaserViewTitleColor;
    [contentView addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                contentView.bounds.origin.y + JAPopularBrandsTeaserViewTitleHeight,
                                                                contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JAPopularBrandsTeaserViewLineColor;
    [contentView addSubview:lineView];
    
    currentY += lineView.frame.size.height;
    
    for (RITeaser* teaser in self.teasers) {
        
        for (RITeaserText* teaserText in teaser.teaserTexts) {
            
            UILabel* teaserLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JAPopularBrandsTeaserViewCellMargin,
                                                                             currentY,
                                                                             contentView.bounds.size.width - JAPopularBrandsTeaserViewCellMargin*2,
                                                                             JAPopularBrandsTeaserViewCellHeight)];
            teaserLabel.text = teaserText.name;
            teaserLabel.font = JAPopularBrandsTeaserViewCellFont;
            teaserLabel.textColor = JAPopularBrandsTeaserViewCellColor;
            [contentView addSubview:teaserLabel];
            
            currentY += teaserLabel.frame.size.height;
        }
    }
    
    [contentView setFrame:CGRectMake(contentView.frame.origin.x,
                                     contentView.frame.origin.y,
                                     contentView.frame.size.width,
                                     currentY)];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              currentY + JAPopularBrandsTeaserViewHorizontalMargin)];
}

@end
