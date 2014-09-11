//
//  JACampaignsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsTeaserView.h"

#define JACampaignsTeaserViewHeight 72.0f
#define JACampaignsTeaserBackgroundHeight 72.0f
#define JACampaignsTeaserViewHorizontalMargin 6.0f
#define JACampaignsTeaserViewContentY 4.0f
#define JACampaignsTeaserViewContentCornerRadius 3.0f
#define JACampaignsTeaserViewHotLabelFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]
#define JACampaignsTeaserViewHotLabelColor UIColorFromRGB(0xac1716)
#define JACampaignsTeaserViewHotLabelOffset 4.0f
#define JACampaignsTeaserViewGraySquareX 4.0f
#define JACampaignsTeaserViewGraySquareWidth 61.0f
#define JACampaignsTeaserViewOffersLabelFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
#define JACampaignsTeaserViewOffersLabelColor [UIColor blackColor]
#define JACampaignsTeaserViewTitleOffset 80.0f
#define JACampaignsTeaserViewTitleRightOffset 20.0f
#define JACampaignsTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]
#define JACampaignsTeaserViewTitleColor [UIColor whiteColor]


@implementation JACampaignsTeaserView

- (void)load
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              JACampaignsTeaserViewHeight)];
    
    // Calculate new height
    if (self.teasers.count > 1)
    {
        float newHeight = JACampaignsTeaserViewHeight + (self.teasers.count * 30.0) + 5;
        
        CGRect frame = self.frame;
        frame.size.height = newHeight;
        self.frame = frame;
    }
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JACampaignsTeaserViewHorizontalMargin,
                                                                   JACampaignsTeaserViewContentY,
                                                                   self.bounds.size.width - JACampaignsTeaserViewHorizontalMargin*2,
                                                                   self.bounds.size.height - JACampaignsTeaserViewContentY)];
    contentView.backgroundColor = [UIColor whiteColor];
    
    contentView.layer.cornerRadius = JACampaignsTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    UIImage* backgroundImage = [UIImage imageNamed:@"CampaignsTeaserBackground"];
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundImageView setFrame:CGRectMake(contentView.bounds.origin.x,
                                             contentView.bounds.origin.y,
                                             contentView.bounds.size.width,
                                             JACampaignsTeaserBackgroundHeight)];
    [contentView addSubview:backgroundImageView];
    
    //there's a white rectangle where these two labels will go in. its measures are (4, 0, 61, 56)
    
    UILabel* hotLabel = [[UILabel alloc] init];
    hotLabel.text = @"HOT";
    hotLabel.font = JACampaignsTeaserViewHotLabelFont;
    hotLabel.textColor = JACampaignsTeaserViewHotLabelColor;
    hotLabel.textAlignment = NSTextAlignmentCenter;
    [hotLabel sizeToFit];
    [hotLabel setFrame:CGRectMake(contentView.bounds.origin.x + JACampaignsTeaserViewGraySquareX,
                                  backgroundImageView.bounds.size.height/2 - hotLabel.frame.size.height + JACampaignsTeaserViewHotLabelOffset,
                                  JACampaignsTeaserViewGraySquareWidth,
                                  hotLabel.frame.size.height)];
    [contentView addSubview:hotLabel];
    
    UILabel* offersLabel = [[UILabel alloc] init];
    offersLabel.text = @"OFFERS";
    offersLabel.font = JACampaignsTeaserViewOffersLabelFont;
    offersLabel.textColor = JACampaignsTeaserViewOffersLabelColor;
    offersLabel.textAlignment = NSTextAlignmentCenter;
    [offersLabel sizeToFit];
    [offersLabel setFrame:CGRectMake(contentView.bounds.origin.x + JACampaignsTeaserViewGraySquareX,
                                     CGRectGetMaxY(hotLabel.frame) - JACampaignsTeaserViewHotLabelOffset,
                                     JACampaignsTeaserViewGraySquareWidth,
                                     offersLabel.frame.size.height)];
    
    [contentView addSubview:offersLabel];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JACampaignsTeaserViewTitleOffset,
                                                                    contentView.bounds.origin.y,
                                                                    contentView.bounds.size.width - JACampaignsTeaserViewTitleOffset - JACampaignsTeaserViewTitleRightOffset,
                                                                    backgroundImageView.bounds.size.height)];
    if (self.teasers.count > 1) {
        titleLabel.text = self.groupTitle;
    } else {
        RITeaser *teaser = [self.teasers firstObject];
        RITeaserText *teaserText = [teaser.teaserTexts firstObject];
        titleLabel.text = teaserText.name;
    }
    
    titleLabel.font = JACampaignsTeaserViewTitleFont;
    titleLabel.textColor = JACampaignsTeaserViewTitleColor;
    [contentView addSubview:titleLabel];
    
    UILabel *fakeLabel = [[UILabel alloc] initWithFrame:backgroundImageView.frame];
    fakeLabel.tag = 0;
    fakeLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(teaserTextPressed:)];
    [fakeLabel addGestureRecognizer:tap];
    
    [contentView addSubview:fakeLabel];
    
    if (self.teasers.count > 1)
    {
        // Add teasers
        float startingY = backgroundImageView.frame.size.height;
        NSInteger tag = 0;
        
        for (RITeaser *teaser in self.teasers)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, startingY, contentView.frame.size.width - 30, 30)];
            RITeaserText* teaserText = [teaser.teaserTexts firstObject];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
            label.textColor = UIColorFromRGB(0x4e4e4e);
            label.text = teaserText.name;
            label.tag = tag;
            [contentView addSubview:label];
            startingY += 30;
            tag++;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(teaserTextPressed:)];
            label.userInteractionEnabled = YES;
            [label addGestureRecognizer:tap];
        }
    }
}

- (void)teaserTextPressed:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    
    RITeaser* teaser = [self.teasers objectAtIndex:label.tag];
    
    RITeaserText* teaserText = [teaser.teaserTexts firstObject];
    
    [self teaserPressedWithTeaserTextForCampaigns:teaserText];
}

@end
