//
//  JATopCategoriesTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopCategoriesTeaserView.h"

#define JATopCategoriesTeaserViewHorizontalMargin 6.0f
#define JATopCategoriesTeaserViewContentY 4.0f
#define JATopCategoriesTeaserViewContentCornerRadius 3.0f
#define JATopCategoriesTeaserViewTitleHeight 26.0f
#define JATopCategoriesTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
#define JATopCategoriesTeaserViewTitleColor UIColorFromRGB(0x4e4e4e)
#define JATopCategoriesTeaserViewLineColor UIColorFromRGB(0xfaa41a)
#define JATopCategoriesTeaserViewCellMargin 16.0f
#define JATopCategoriesTeaserViewCellHeight 30.0f
#define JATopCategoriesTeaserViewCellFont [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f]
#define JATopCategoriesTeaserViewCellColor UIColorFromRGB(0x4e4e4e)
#define JATopCategoriesTeaserViewAllCategoriesCellFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f]

@implementation JATopCategoriesTeaserView

- (void)load;
{
    [super load];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JATopCategoriesTeaserViewHorizontalMargin,
                                                                   JATopCategoriesTeaserViewContentY,
                                                                   self.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                   1)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = JATopCategoriesTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    CGFloat currentY = contentView.bounds.origin.y;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JATopCategoriesTeaserViewHorizontalMargin,
                                                                    currentY,
                                                                    contentView.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                    JATopCategoriesTeaserViewTitleHeight)];
    titleLabel.text = @"Top Categories";
    titleLabel.font = JATopCategoriesTeaserViewTitleFont
    titleLabel.textColor = JATopCategoriesTeaserViewTitleColor;
    [contentView addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                contentView.bounds.origin.y + JATopCategoriesTeaserViewTitleHeight,
                                                                contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JATopCategoriesTeaserViewLineColor;
    [contentView addSubview:lineView];

    currentY += lineView.frame.size.height;
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        for (RITeaserText* teaserText in teaser.teaserTexts) {
            UILabel* teaserLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JATopCategoriesTeaserViewCellMargin,
                                                                             currentY,
                                                                             contentView.bounds.size.width - JATopCategoriesTeaserViewCellMargin*2,
                                                                             JATopCategoriesTeaserViewCellHeight)];
            teaserLabel.text = teaserText.name;
            teaserLabel.font = JATopCategoriesTeaserViewCellFont;
            teaserLabel.textColor = JATopCategoriesTeaserViewCellColor;
            [contentView addSubview:teaserLabel];
            
            UIControl* control = [UIControl new];
            [control setFrame:teaserLabel.frame];
            [contentView addSubview:control];
            control.tag = i;
            [control addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            currentY += teaserLabel.frame.size.height;
        }
    }
    
    //all categories cell
    
    UILabel* allCategoriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JATopCategoriesTeaserViewHorizontalMargin,
                                                                             currentY,
                                                                             contentView.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                             JATopCategoriesTeaserViewCellHeight)];
    allCategoriesLabel.text = @"All Categories";
    allCategoriesLabel.font = JATopCategoriesTeaserViewAllCategoriesCellFont;
    allCategoriesLabel.textColor = JATopCategoriesTeaserViewCellColor;
    [contentView addSubview:allCategoriesLabel];
    
    currentY += allCategoriesLabel.frame.size.height;
    
    [contentView setFrame:CGRectMake(contentView.frame.origin.x,
                                     contentView.frame.origin.y,
                                     contentView.frame.size.width,
                                     currentY)];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              currentY + JATopCategoriesTeaserViewHorizontalMargin)];
}

- (void)teaserTextPressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    RITeaser* teaser = [self.teasers objectAtIndex:index];
    
    RITeaserText* teaserText = [teaser.teaserTexts firstObject];
    
    [self teaserPressedWithTeaserText:teaserText];
}

@end
