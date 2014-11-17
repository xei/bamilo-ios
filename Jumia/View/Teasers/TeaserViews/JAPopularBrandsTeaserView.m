//
//  JAPopularBrandsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPopularBrandsTeaserView.h"
#import "JAClickableView.h"

#define JAPopularBrandsTeaserViewHorizontalMargin 6.0f
#define JAPopularBrandsTeaserViewContentY 4.0f
#define JAPopularBrandsTeaserViewContentCornerRadius 3.0f
#define JAPopularBrandsTeaserViewTitleHeight 26.0f
#define JAPopularBrandsTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
#define JAPopularBrandsTeaserViewTitleColor UIColorFromRGB(0x4e4e4e)
#define JAPopularBrandsTeaserViewLineColor UIColorFromRGB(0xfaa41a)
#define JAPopularBrandsTeaserViewCellMargin 16.0f
#define JAPopularBrandsTeaserViewCellHeight 30.0f
#define JAPopularBrandsTeaserViewCellFont [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]
#define JAPopularBrandsTeaserViewCellColor UIColorFromRGB(0x4e4e4e)

@interface JAPopularBrandsTeaserView()

@property (nonatomic, strong)UIView* contentView;

@end

@implementation JAPopularBrandsTeaserView

- (void)load;
{
    [super load];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(JAPopularBrandsTeaserViewHorizontalMargin,
                                                                JAPopularBrandsTeaserViewContentY,
                                                                self.bounds.size.width - JAPopularBrandsTeaserViewHorizontalMargin*2,
                                                                1)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = JAPopularBrandsTeaserViewContentCornerRadius;
    [self addSubview:self.contentView];
    
    CGFloat currentY = self.contentView.bounds.origin.y;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x + JAPopularBrandsTeaserViewHorizontalMargin,
                                                                    currentY,
                                                                    self.contentView.bounds.size.width - JAPopularBrandsTeaserViewHorizontalMargin*2,
                                                                    JAPopularBrandsTeaserViewTitleHeight)];
    titleLabel.text = self.groupTitle;
    titleLabel.font = JAPopularBrandsTeaserViewTitleFont
    titleLabel.textColor = JAPopularBrandsTeaserViewTitleColor;
    [self.contentView addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                self.contentView.bounds.origin.y + JAPopularBrandsTeaserViewTitleHeight,
                                                                self.contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JAPopularBrandsTeaserViewLineColor;
    [self.contentView addSubview:lineView];
    
    currentY += lineView.frame.size.height;
    
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        for (RITeaserText* teaserText in teaser.teaserTexts) {
            
            JAClickableView* listClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                                                   currentY,
                                                                                                   self.contentView.bounds.size.width,
                                                                                                   JAPopularBrandsTeaserViewCellHeight)];
            [listClickableView addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
            listClickableView.tag = i;
            [self.contentView addSubview:listClickableView];
            
            UILabel* teaserLabel = [[UILabel alloc] initWithFrame:CGRectMake(listClickableView.bounds.origin.x + JAPopularBrandsTeaserViewCellMargin,
                                                                             listClickableView.bounds.origin.y,
                                                                             listClickableView.bounds.size.width - JAPopularBrandsTeaserViewCellMargin*2,
                                                                             listClickableView.bounds.size.height)];
            teaserLabel.text = teaserText.name;
            teaserLabel.font = JAPopularBrandsTeaserViewCellFont;
            teaserLabel.textColor = JAPopularBrandsTeaserViewCellColor;
            [listClickableView addSubview:teaserLabel];
            
            currentY += teaserLabel.frame.size.height;
        }
    }
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
                                          currentY)];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              currentY + JAPopularBrandsTeaserViewHorizontalMargin)];
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
                                        height - JAPopularBrandsTeaserViewHorizontalMargin);
}

@end
