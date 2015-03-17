//
//  JACampaignsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsTeaserView.h"
#import "JAClickableView.h"

#define JACampaignsTeaserViewHeight 72.0f
#define JACampaignsTeaserBackgroundHeight 72.0f
#define JACampaignsTeaserViewHorizontalMargin 6.0f
#define JACampaignsTeaserViewContentY 4.0f
#define JACampaignsTeaserViewContentCornerRadius 3.0f
#define JACampaignsTeaserViewHotLabelFont [UIFont fontWithName:kFontBoldName size:18.0f]
#define JACampaignsTeaserViewHotLabelColor UIColorFromRGB(0xac1716)
#define JACampaignsTeaserViewHotLabelOffset 4.0f
#define JACampaignsTeaserViewGraySquareX 4.0f
#define JACampaignsTeaserViewGraySquareWidth 61.0f
#define JACampaignsTeaserViewOffersLabelFont [UIFont fontWithName:kFontBoldName size:10.0f];
#define JACampaignsTeaserViewOffersLabelColor [UIColor blackColor]
#define JACampaignsTeaserViewTitleOffset 80.0f
#define JACampaignsTeaserViewTitleRightOffset 20.0f
#define JACampaignsTeaserViewTitleFont [UIFont fontWithName:kFontBoldName size:17.0f]
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
    else
    {
        float newHeight = JACampaignsTeaserViewHeight + 4;
        
        CGRect frame = self.frame;
        frame.size.height = newHeight;
        self.frame = frame;
    }
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JACampaignsTeaserViewHorizontalMargin,
                                                                   JACampaignsTeaserViewContentY,
                                                                   self.bounds.size.width - JACampaignsTeaserViewHorizontalMargin*2,
                                                                   self.bounds.size.height - JACampaignsTeaserViewContentY)];
    if (self.teasers.count > 1)
    {
        contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        contentView.backgroundColor = [UIColor clearColor];
    }
    
    contentView.layer.cornerRadius = JACampaignsTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    //TOP PART
    
    JAClickableView* topClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                                          contentView.bounds.origin.y,
                                                                                          contentView.bounds.size.width,
                                                                                          JACampaignsTeaserBackgroundHeight)];
    topClickableView.tag = 0;
    [topClickableView addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:topClickableView];
    
    UIImage* backgroundImage = [UIImage imageNamed:@"CampaignsTeaserBackground"];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.isLandscape) {
            backgroundImage = [UIImage imageNamed:@"CampaignsTeaserBackground_ipad_landscape"];
        } else {
            backgroundImage = [UIImage imageNamed:@"CampaignsTeaserBackground_ipad_portrait"];
        }
    }
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundImageView setFrame:topClickableView.bounds];
    [topClickableView addSubview:backgroundImageView];
    
    //there's a white rectangle where these two labels will go in. its measures are (4, 0, 61, 56)
    
    UILabel* hotLabel = [[UILabel alloc] init];
    hotLabel.text = STRING_HOT;
    hotLabel.font = JACampaignsTeaserViewHotLabelFont;
    hotLabel.textColor = JACampaignsTeaserViewHotLabelColor;
    hotLabel.textAlignment = NSTextAlignmentCenter;
    [hotLabel sizeToFit];
    [hotLabel setFrame:CGRectMake(topClickableView.bounds.origin.x + JACampaignsTeaserViewGraySquareX,
                                  backgroundImageView.bounds.size.height/2 - hotLabel.frame.size.height + JACampaignsTeaserViewHotLabelOffset,
                                  JACampaignsTeaserViewGraySquareWidth,
                                  hotLabel.frame.size.height)];
    [topClickableView addSubview:hotLabel];
    
    UILabel* offersLabel = [[UILabel alloc] init];
    offersLabel.text = STRING_OFFERS;
    offersLabel.font = JACampaignsTeaserViewOffersLabelFont;
    offersLabel.textColor = JACampaignsTeaserViewOffersLabelColor;
    offersLabel.textAlignment = NSTextAlignmentCenter;
    [offersLabel sizeToFit];
    [offersLabel setFrame:CGRectMake(topClickableView.bounds.origin.x + JACampaignsTeaserViewGraySquareX,
                                     CGRectGetMaxY(hotLabel.frame) - JACampaignsTeaserViewHotLabelOffset,
                                     JACampaignsTeaserViewGraySquareWidth,
                                     offersLabel.frame.size.height)];
    
    [topClickableView addSubview:offersLabel];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(topClickableView.bounds.origin.x + JACampaignsTeaserViewTitleOffset,
                                                                    topClickableView.bounds.origin.y,
                                                                    topClickableView.bounds.size.width - JACampaignsTeaserViewTitleOffset - JACampaignsTeaserViewTitleRightOffset,
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
    [topClickableView addSubview:titleLabel];
    
    //BOTTOM PART
    
    if (self.teasers.count > 1)
    {
        // Add teasers
        float startingY = topClickableView.frame.size.height;
        NSInteger tag = 0;
        
        for (RITeaser *teaser in self.teasers)
        {
            JAClickableView* listClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0,
                                                                                                   startingY,
                                                                                                   contentView.frame.size.width,
                                                                                                   30)];
            [listClickableView addTarget:self action:@selector(teaserTextPressed:) forControlEvents:UIControlEventTouchUpInside];
            listClickableView.tag = tag;
            [contentView addSubview:listClickableView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f,
                                                                       listClickableView.bounds.origin.y,
                                                                       listClickableView.bounds.size.width - 30.0f,
                                                                       listClickableView.bounds.size.height)];
            RITeaserText* teaserText = [teaser.teaserTexts firstObject];
            label.font = [UIFont fontWithName:kFontLightName size:13.0f];
            label.textColor = UIColorFromRGB(0x4e4e4e);
            label.text = teaserText.name;
            [listClickableView addSubview:label];
            startingY += listClickableView.frame.size.height;
            tag++;
        }
    }
}

- (void)teaserTextPressed:(UIControl*)control
{
    RITeaser* teaser = [self.teasers objectAtIndex:control.tag];
    
    RITeaserText* teaserText = [teaser.teaserTexts firstObject];
    
    [self teaserPressedWithTitle:teaserText.name inCampaignTeasers:[self.teasers array]];
}

@end
