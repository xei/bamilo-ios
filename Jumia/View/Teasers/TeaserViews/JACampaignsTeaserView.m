//
//  JACampaignsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JACampaignsTeaserView()

@property (nonatomic, strong)UILabel* clockLabel;
@property (nonatomic, assign)NSInteger elapsedTimeInSeconds;
@property (nonatomic, strong)NSTimer* timer;

@end

@implementation JACampaignsTeaserView

- (void)load
{
    [super load];
    
    if (VALID_NOTEMPTY(self.teaserGrouping.teaserComponents, NSOrderedSet)) {
        CGFloat margin = 6.0f; //value by design
        CGFloat mainAreaHeight = 103.0f; //value by design
        CGFloat moreButtonHeight = 24.0f;
        CGFloat totalHeight = mainAreaHeight;
        if (1 < self.teaserGrouping.teaserComponents.count) {
            //add the height of the button
            totalHeight += moreButtonHeight;
        }
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  totalHeight)];
        
        JAClickableView* mainClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + margin,
                                                                                           self.bounds.origin.y,
                                                                                           self.bounds.size.width - margin*2,
                                                                                           mainAreaHeight)];
        mainClickableView.tag = 0;
        mainClickableView.backgroundColor = [UIColor whiteColor];
        [mainClickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mainClickableView];
        
        RITeaserComponent* mainCampaign = [self.teaserGrouping.teaserComponents firstObject];
        
        CGFloat labelTopMargin = 14.0f;
        
        CGFloat halfWidth = mainClickableView.bounds.size.width/2;
        UILabel* titleLabel = [UILabel new];
        titleLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = mainCampaign.title;
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(margin,
                                        labelTopMargin,
                                        halfWidth - margin*2,
                                        titleLabel.frame.size.height)];
        [mainClickableView addSubview:titleLabel];
        
        [self.clockLabel removeFromSuperview];
        self.clockLabel = [UILabel new];
        self.clockLabel.font = [UIFont fontWithName:kFontMediumName size:25.0f];
        self.clockLabel.textColor = UIColorFromRGB(0xcc0000);
        self.clockLabel.textAlignment = NSTextAlignmentCenter;
        self.clockLabel.text = @"00:00:00";
        [self.clockLabel sizeToFit];
        [self.clockLabel setFrame:CGRectMake(margin,
                                             CGRectGetMaxY(titleLabel.frame) + margin,
                                             halfWidth - margin*2,
                                             self.clockLabel.frame.size.height)];
        [mainClickableView addSubview:self.clockLabel];
        
        self.elapsedTimeInSeconds = 0;
        [self updateTimeLabelText];
        if (ISEMPTY(self.timer)) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTimeLabelText)
                                                        userInfo:nil
                                                         repeats:YES];
        }

        
        UILabel* subTitleLabel = [UILabel new];
        subTitleLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
        subTitleLabel.textColor = [UIColor blackColor];
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        subTitleLabel.text = mainCampaign.subTitle;
        [subTitleLabel sizeToFit];
        [subTitleLabel setFrame:CGRectMake(margin,
                                           CGRectGetMaxY(self.clockLabel.frame) + margin,
                                           halfWidth - margin*2,
                                           subTitleLabel.frame.size.height)];
        [mainClickableView addSubview:subTitleLabel];
        
        NSString* imageUrl = mainCampaign.imagePortraitUrl;
        UIImageView* imageView = [UIImageView new];
        [imageView setFrame:CGRectMake(halfWidth,
                                       self.bounds.origin.y,
                                       halfWidth,
                                       mainAreaHeight)];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [mainClickableView addSubview:imageView];
        
        if (1 < self.teaserGrouping.teaserComponents.count) {
            
            JAClickableView* moreView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + margin,
                                                                                          mainAreaHeight,
                                                                                          self.bounds.size.width - margin*2,
                                                                                          moreButtonHeight)];
            moreView.tag = 0; //all the campaigns open when one of them is clicked
            moreView.backgroundColor = [UIColor clearColor];
            [moreView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:moreView];
            
            UILabel* moreLabel = [UILabel new];
            moreLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
            moreLabel.textColor = UIColorFromRGB(0x06739e);
            moreLabel.text = @"See More Offers";
            [moreLabel sizeToFit];
            [moreView addSubview:moreLabel];
            
            UIImage* arrowImage = [UIImage imageNamed:@"campaignTeaserMoreArrow"];
            UIImageView* arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
            [moreView addSubview:arrowImageView];
            
            CGFloat marginBetweenLabelAndImage = 12.0f;
            CGFloat labelPlusImageWidth = moreLabel.frame.size.width + arrowImage.size.width + marginBetweenLabelAndImage;
            
            [moreLabel setFrame:CGRectMake((moreView.frame.size.width - labelPlusImageWidth) / 2,
                                           moreView.bounds.origin.y,
                                           moreLabel.bounds.size.width,
                                           moreView.bounds.size.height)];

            [arrowImageView setFrame:CGRectMake(CGRectGetMaxX(moreLabel.frame) + marginBetweenLabelAndImage,
                                                (moreView.frame.size.height - arrowImage.size.height) / 2,
                                                arrowImage.size.width,
                                                arrowImage.size.height)];

        }
    }
}

- (void)updateTimeLabelText
{
    self.elapsedTimeInSeconds++;
    
    RITeaserComponent* component = [self.teaserGrouping.teaserComponents firstObject];
    
    if (ISEMPTY(component.remainingTime)) {
        self.clockLabel.text = @"00:00:00";
    } else {
        NSInteger remainingSeconds = [component.remainingTime integerValue];
        remainingSeconds -= self.elapsedTimeInSeconds;
        
        NSInteger days = remainingSeconds / (24 * 3600);
        remainingSeconds = remainingSeconds % (24 * 3600); //keep the remainder
        NSInteger hours = remainingSeconds / 3600;
        remainingSeconds = remainingSeconds % 3600; //keep the remainder
        NSInteger minutes = remainingSeconds / 60;
        remainingSeconds = remainingSeconds % 60; //keep the remainder
        
        NSString* timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)remainingSeconds];
        
        if (days > 0) {
            timeString = [NSString stringWithFormat:@"%02ld:%@",(long)days,timeString];
        }
        
        self.clockLabel.text = timeString;
        [self.clockLabel sizeToFit];
    }
}

@end
