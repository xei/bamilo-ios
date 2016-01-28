//
//  JACampaignBannerCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignBannerCell.h"

@interface JACampaignBannerCell()

@property (nonatomic, strong)UIImageView* imageView;

@end

@implementation JACampaignBannerCell

- (void)loadWithImageView:(UIImageView*)imageView;
{
    [self.imageView removeFromSuperview];
    [self.feedbackView removeFromSuperview];
    self.imageView = imageView;
    [self setFrame:CGRectMake(0.0f, 0.0f, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    [self addSubview:self.imageView];
    
    self.feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    [self addSubview:self.feedbackView];
}

@end
