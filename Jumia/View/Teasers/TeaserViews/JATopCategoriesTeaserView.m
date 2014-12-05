//
//  JATopCategoriesTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopCategoriesTeaserView.h"
#import "JAClickableView.h"

#define JATopCategoriesTeaserViewHorizontalMargin 6.0f
#define JATopCategoriesTeaserViewContentY 4.0f
#define JATopCategoriesTeaserViewContentCornerRadius 3.0f
#define JATopCategoriesTeaserViewTitleHeight 26.0f
#define JATopCategoriesTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
#define JATopCategoriesTeaserViewTitleColor UIColorFromRGB(0x4e4e4e)
#define JATopCategoriesTeaserViewLineColor UIColorFromRGB(0xfaa41a)
#define JATopCategoriesTeaserViewCellMargin 16.0f
#define JATopCategoriesTeaserViewCellHeight 30.0f
#define JATopCategoriesTeaserViewCellFont [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]
#define JATopCategoriesTeaserViewCellColor UIColorFromRGB(0x4e4e4e)
#define JATopCategoriesTeaserViewAllCategoriesCellFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]

@interface JATopCategoriesTeaserView()

@property (nonatomic, strong)UIView* contentView;

@end

@implementation JATopCategoriesTeaserView

- (void)load;
{
    [super load];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(JATopCategoriesTeaserViewHorizontalMargin,
                                                                JATopCategoriesTeaserViewContentY,
                                                                self.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                1)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = JATopCategoriesTeaserViewContentCornerRadius;
    [self addSubview:self.contentView];
    
    CGFloat currentY = self.contentView.bounds.origin.y;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x + JATopCategoriesTeaserViewHorizontalMargin,
                                                                    currentY,
                                                                    self.contentView.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                    JATopCategoriesTeaserViewTitleHeight)];
    titleLabel.text = self.groupTitle;
    titleLabel.font = JATopCategoriesTeaserViewTitleFont
    titleLabel.textColor = JATopCategoriesTeaserViewTitleColor;
    [self.contentView addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                self.contentView.bounds.origin.y + JATopCategoriesTeaserViewTitleHeight,
                                                                self.contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JATopCategoriesTeaserViewLineColor;
    [self.contentView addSubview:lineView];
    
    currentY += lineView.frame.size.height;
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        for (RITeaserText* teaserText in teaser.teaserTexts) {
            
            JAClickableView* listClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                   currentY,
                                                                                                   self.contentView.bounds.size.width,
                                                                                                   JATopCategoriesTeaserViewCellHeight)];
            listClickableView.tag = i;
            [listClickableView addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:listClickableView];
            
            UILabel* teaserLabel = [[UILabel alloc] initWithFrame:CGRectMake(listClickableView.bounds.origin.x + JATopCategoriesTeaserViewCellMargin,
                                                                             listClickableView.bounds.origin.y,
                                                                             listClickableView.bounds.size.width - JATopCategoriesTeaserViewCellMargin*2,
                                                                             listClickableView.bounds.size.height)];
            teaserLabel.text = teaserText.name;
            teaserLabel.font = JATopCategoriesTeaserViewCellFont;
            teaserLabel.textColor = JATopCategoriesTeaserViewCellColor;
            [listClickableView addSubview:teaserLabel];
            
            currentY += teaserLabel.frame.size.height;
        }
    }
    
    //all categories cell
    
    JAClickableView* allCategoriesClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                                                    currentY,
                                                                                                    self.contentView.bounds.size.width,
                                                                                                    JATopCategoriesTeaserViewCellHeight)];
    [allCategoriesClickableView addTarget:self action:@selector(teaserAllCategoriesPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:allCategoriesClickableView];
    
    UILabel* allCategoriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(allCategoriesClickableView.bounds.origin.x + JATopCategoriesTeaserViewHorizontalMargin,
                                                                            allCategoriesClickableView.bounds.origin.y,
                                                                            allCategoriesClickableView.bounds.size.width - JATopCategoriesTeaserViewHorizontalMargin*2,
                                                                            allCategoriesClickableView.bounds.size.height)];
    allCategoriesLabel.text = STRING_ALL_CATEGORIES;
    allCategoriesLabel.font = JATopCategoriesTeaserViewAllCategoriesCellFont;
    allCategoriesLabel.textColor = JATopCategoriesTeaserViewCellColor;
    [allCategoriesClickableView addSubview:allCategoriesLabel];
    
    currentY += allCategoriesLabel.frame.size.height;
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
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

- (void)adjustHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width,
                                        height - JATopCategoriesTeaserViewHorizontalMargin);
}

@end
