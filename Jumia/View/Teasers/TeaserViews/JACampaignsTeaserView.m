//
//  JACampaignsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsTeaserView.h"

#define JACampaignsTeaserViewHeight 72.0f
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
#define JACampaignsTeaserViewTitleOffset 90.0f
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
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JACampaignsTeaserViewHorizontalMargin,
                                                                   JACampaignsTeaserViewContentY,
                                                                   self.bounds.size.width - JACampaignsTeaserViewHorizontalMargin*2,
                                                                   self.bounds.size.height - JACampaignsTeaserViewContentY*2)];
    contentView.layer.cornerRadius = JACampaignsTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    UIImage* backgroundImage = [UIImage imageNamed:@"CampaignsTeaserBackground"];
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundImageView setFrame:CGRectMake(contentView.bounds.origin.x,
                                             contentView.bounds.origin.y,
                                             contentView.bounds.size.width,
                                             contentView.bounds.size.height)];
    [contentView addSubview:backgroundImageView];
    
    //there's a white rectangle where these two labels will go in. its measures are (4, 0, 61, 56)
    
    UILabel* hotLabel = [[UILabel alloc] init];
    hotLabel.text = @"HOT";
    hotLabel.font = JACampaignsTeaserViewHotLabelFont;
    hotLabel.textColor = JACampaignsTeaserViewHotLabelColor;
    hotLabel.textAlignment = NSTextAlignmentCenter;
    [hotLabel sizeToFit];
    [hotLabel setFrame:CGRectMake(contentView.bounds.origin.x + JACampaignsTeaserViewGraySquareX,
                                  contentView.bounds.size.height/2 - hotLabel.frame.size.height + JACampaignsTeaserViewHotLabelOffset,
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
    
    
    RITeaser* teaser = [self.teasers firstObject];
    RITeaserText* teaserText = [teaser.teaserTexts firstObject];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JACampaignsTeaserViewTitleOffset,
                                                                    contentView.bounds.origin.y,
                                                                    contentView.bounds.size.width - JACampaignsTeaserViewTitleOffset,
                                                                    contentView.bounds.size.height)];
    titleLabel.text = teaserText.name;
    titleLabel.font = JACampaignsTeaserViewTitleFont;
    titleLabel.textColor = JACampaignsTeaserViewTitleColor;
    [contentView addSubview:titleLabel];
    
    UIControl* control = [UIControl new];
    [control setFrame:self.bounds];
    [contentView addSubview:control];
    [control addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)teaserTextPressed:(UIControl*)control
{
//    RITeaser* teaser = [self.teasers firstObject];
//    
//    RITeaserText* teaserText = [teaser.teaserTexts firstObject];
}

@end
