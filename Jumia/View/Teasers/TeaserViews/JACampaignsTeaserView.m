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
@property (nonatomic, strong)NSTimer* timer;

@property (nonatomic, strong)NSMutableArray* teaserComponentsToUse;

@end

@implementation JACampaignsTeaserView

- (void)load
{
    [super load];
    
    self.teaserComponentsToUse = [NSMutableArray new];
    for (RITeaserComponent* component in self.teaserGrouping.teaserComponents) {
        if (VALID_NOTEMPTY(component.endingDate, NSDate)) {
            NSInteger remainingSeconds = (NSInteger)[component.endingDate timeIntervalSinceNow];
            if (0 < remainingSeconds) {
                [self.teaserComponentsToUse addObject:component];
            }
        } else {
            [self.teaserComponentsToUse addObject:component];
        }
    }
    
    if (VALID_NOTEMPTY(self.teaserComponentsToUse, NSMutableArray)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self loadForIPad];
        } else {
            [self loadForIPhone];
        }
    }
}

- (void)loadForIPhone
{
    CGFloat marginX = 6.0f; //value by design
    CGFloat marginY = 12.0f; //value b design
    CGFloat mainAreaHeight = 103.0f; //value by design
    CGFloat moreButtonHeight = 24.0f;
    CGFloat totalHeight = mainAreaHeight;
    if (1 < self.teaserComponentsToUse.count) {
        //add the height of the button
        totalHeight += moreButtonHeight;
    } else {
        totalHeight += marginY;
    }
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    JAClickableView* mainClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + marginX,
                                                                                           self.bounds.origin.y,
                                                                                           self.bounds.size.width - marginX*2,
                                                                                           mainAreaHeight)];
    mainClickableView.tag = 0;
    mainClickableView.backgroundColor = [UIColor whiteColor];
    [mainClickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mainClickableView];


    UIView* clockView = [UIView new];
    [mainClickableView addSubview:clockView];
    
    RITeaserComponent* mainCampaign = [self.teaserComponentsToUse firstObject];
    
    CGFloat labelTopMargin = 6.0f;
    CGFloat marginBetweenLabels = 6.0f;
    CGFloat currentY = labelTopMargin;
    CGFloat halfWidth = mainClickableView.bounds.size.width/2;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, halfWidth, 50)];
    titleLabel.font = JATitleFont;
    titleLabel.textColor = JABlackColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    titleLabel.numberOfLines=2;
    titleLabel.text = mainCampaign.title;
    [titleLabel sizeToFit];
    [titleLabel setY:currentY];
    [titleLabel setWidth:halfWidth];
    
    [clockView addSubview:titleLabel];
    
    [self.clockLabel removeFromSuperview];
    self.clockLabel = [UILabel new];
    if (VALID_NOTEMPTY(mainCampaign.endingDate, NSDate)) {
        self.clockLabel.font = JADisplay1Font;
    } else {
        self.clockLabel.font = JADisplay2Font;
    }
    self.clockLabel.textColor = JARed1Color;
    self.clockLabel.textAlignment = NSTextAlignmentCenter;
    [self.clockLabel sizeToFit];
    [clockView addSubview:self.clockLabel];
    
    [self updateTimeLabelText];
    if (ISEMPTY(self.timer)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimeLabelText)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    currentY = CGRectGetMaxY(titleLabel.frame) + marginBetweenLabels;
    
    CGFloat clockViewWidth = mainClickableView.width/2;
    
    [self.clockLabel setFrame:CGRectMake(0,
                                         currentY,
                                         halfWidth,
                                         self.clockLabel.frame.size.height)];
    
    if (0 < self.clockLabel.frame.size.height) {
        currentY += self.clockLabel.frame.size.height + marginBetweenLabels;
    }
    
    UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, halfWidth, 50)];
    subTitleLabel.font = JACaptionFont;
    subTitleLabel.textColor = [UIColor blackColor];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.numberOfLines=2;
    subTitleLabel.text = mainCampaign.subTitle;
    [subTitleLabel sizeToFit];
    [clockView addSubview:subTitleLabel];
    
    [subTitleLabel setFrame:CGRectMake(0,
                                       currentY,
                                       halfWidth,
                                       subTitleLabel.frame.size.height)];
    
    currentY = CGRectGetMaxY(subTitleLabel.frame) + labelTopMargin;
    
    [clockView setFrame:CGRectMake(0,
                                   (mainAreaHeight - currentY) / 2,
                                   clockViewWidth,
                                   currentY)];
    
    NSString* imageUrl = mainCampaign.imagePortraitUrl;
    UIImageView* imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setFrame:CGRectMake(halfWidth,
                                   self.bounds.origin.y,
                                   halfWidth,
                                   mainAreaHeight)];
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
    [mainClickableView addSubview:imageView];
    
    
    if (1 < self.teaserComponentsToUse.count) {
        
        JAClickableView* moreView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + marginX,
                                                                                      mainAreaHeight,
                                                                                      self.bounds.size.width - marginX*2,
                                                                                      moreButtonHeight)];
        moreView.tag = 0; //all the campaigns open when one of them is clicked
        moreView.backgroundColor = [UIColor clearColor];
        [moreView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreView];
        
        CGFloat marginBetweenLabelAndImage = 12.0f;
        
        UIImage* arrowImage = [UIImage imageNamed:@"campaignTeaserMoreArrow"];
        UIImageView* arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        [moreView addSubview:arrowImageView];
        if (RI_IS_RTL) {
            [arrowImageView flipViewImage];
        }
        
        CGFloat moreLabelMaxWidth = moreView.frame.size.width - arrowImage.size.width - marginBetweenLabelAndImage;
        
        UILabel* moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, moreLabelMaxWidth, 1)];
        moreLabel.font = JABodyFont;
        moreLabel.textColor = JABlue1Color;
        moreLabel.numberOfLines=2;
        moreLabel.text = STRING_SEE_MORE_OFFERS;
        [moreLabel sizeToFit];
        [moreView addSubview:moreLabel];
        
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
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)loadForIPad
{
    CGFloat marginX = 6.0f; //value by design
    CGFloat marginY = 10.0f; //value by design
    CGFloat moreOffersComponentWidth = 125.0f; //value by design
    if (1 == self.teaserComponentsToUse.count) {
        moreOffersComponentWidth = 0.0f;
    }
    CGFloat mainAreaHeight = 132.0f; //value by design
    CGFloat totalHeight = mainAreaHeight + marginY;
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    CGFloat mainAreaWidth = self.frame.size.width - 2*marginX - moreOffersComponentWidth;
    
    JAClickableView* mainClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + marginX,
                                                                                           self.bounds.origin.y,
                                                                                           mainAreaWidth,
                                                                                           mainAreaHeight)];
    mainClickableView.tag = 0;
    mainClickableView.backgroundColor = [UIColor whiteColor];
    [mainClickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mainClickableView];

    UIView* clockView = [UIView new];
    [mainClickableView addSubview:clockView];
    
    RITeaserComponent* mainCampaign = [self.teaserComponentsToUse firstObject];
    
    CGFloat labelTopMargin = 6.0f;
    
    UILabel* titleLabel = [UILabel new];
    titleLabel.font = JATitleFont;
    titleLabel.textColor = JABlackColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines=2;
    titleLabel.text = mainCampaign.title;
    [titleLabel sizeToFit];
    [clockView addSubview:titleLabel];
    
    [self.clockLabel removeFromSuperview];
    self.clockLabel = [UILabel new];
    if (VALID_NOTEMPTY(mainCampaign.endingDate, NSDate)) {
        self.clockLabel.font = JADisplay1Font;
    } else {
        self.clockLabel.font = JADisplay2Font;
    }
    self.clockLabel.textColor = JARed1Color;
    self.clockLabel.textAlignment = NSTextAlignmentCenter;
    [self.clockLabel sizeToFit];
    [clockView addSubview:self.clockLabel];

    [self updateTimeLabelText];
    if (ISEMPTY(self.timer)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimeLabelText)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    CGFloat imageViewWidth = 153.0f; //value by design
    UILabel* subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, imageViewWidth, 1)];
    subTitleLabel.font = JACaptionFont;
    subTitleLabel.textColor = JABlackColor;
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.numberOfLines=2;
    subTitleLabel.text = mainCampaign.subTitle;
    [subTitleLabel sizeToFit];
    [clockView addSubview:subTitleLabel];
    
    CGFloat clockViewWidth = mainClickableView.width/2;
    
    CGFloat currentY = labelTopMargin;
    CGFloat marginBetweenLabels = 6.0f;
    
    [titleLabel setFrame:CGRectMake(0,
                                    currentY,
                                    clockViewWidth,
                                    titleLabel.frame.size.height)];
    
    currentY += titleLabel.frame.size.height + marginBetweenLabels;
    
    [self.clockLabel setFrame:CGRectMake(clockView.bounds.origin.x,
                                         currentY,
                                         clockViewWidth,
                                         self.clockLabel.frame.size.height)];
    
    if (0 < self.clockLabel.frame.size.height) {
        currentY += self.clockLabel.frame.size.height + marginBetweenLabels;
    }
    
    [subTitleLabel setFrame:CGRectMake(0,
                                       currentY,
                                       clockViewWidth,
                                       subTitleLabel.frame.size.height)];
    
    currentY += subTitleLabel.frame.size.height;
    
    CGFloat imageViewHeight = 103.0f; //value by design
    NSString* imageUrl = mainCampaign.imagePortraitUrl;
    UIImageView* imageView = [UIImageView new];
    [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
    [mainClickableView addSubview:imageView];
    
    CGFloat totalOcuppiedWidth = imageViewWidth + clockViewWidth;
    CGFloat totalEmptyArea = mainAreaWidth - totalOcuppiedWidth;
    CGFloat mainAreaViewsMargin = totalEmptyArea / 3;
    
    [clockView setFrame:CGRectMake(mainAreaViewsMargin,
                                   (mainAreaHeight - currentY) / 2,
                                   clockViewWidth,
                                   currentY)];
    [imageView setFrame:CGRectMake(CGRectGetMaxX(clockView.frame) + mainAreaViewsMargin,
                                   (mainAreaHeight - imageViewHeight) / 2,
                                   imageViewWidth,
                                   imageViewHeight)];
    
    
    if (1 < self.teaserComponentsToUse.count) {
        
        JAClickableView* moreView = [[JAClickableView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mainClickableView.frame),
                                                                                      self.bounds.origin.y,
                                                                                      moreOffersComponentWidth,
                                                                                      mainAreaHeight)];
        moreView.tag = 0; //all the campaigns open when one of them is clicked
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            moreView.backgroundColor = [UIColor whiteColor];
        } else {
            moreView.backgroundColor = [UIColor clearColor];
        }
        [moreView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreView];
        
        CGFloat marginBetweenLabelAndImage = 12.0f;
        
        UIImage* arrowImage = [UIImage imageNamed:@"campaignTeaserMoreArrow"];
        UIImageView* arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        [moreView addSubview:arrowImageView];
        if (RI_IS_RTL) {
            [arrowImageView flipViewImage];
        }
        
        CGFloat moreLabelMaxWidth = moreView.frame.size.width - arrowImage.size.width - marginBetweenLabelAndImage;
        
        UILabel* moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, moreLabelMaxWidth, 1)];
        moreLabel.font = JABodyFont;
        moreLabel.textColor = JABlue1Color;
        moreLabel.numberOfLines=-1;
        moreLabel.text = STRING_SEE_MORE_OFFERS;
        [moreLabel sizeToFit];
        [moreView addSubview:moreLabel];
        
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
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }

}

- (void)updateTimeLabelText
{
    RITeaserComponent* component = [self.teaserComponentsToUse firstObject];
    
    if (ISEMPTY(component.endingDate)) {
        self.clockLabel.text = @" ";
        [self.timer invalidate];
    } else {
        NSInteger remainingSeconds = (NSInteger)[component.endingDate timeIntervalSinceNow];
        
        if (0 >= remainingSeconds) {
            [self.timer invalidate];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCampaignMainTeaserTimerEndedNotification object:nil];
        }
        
//        NSInteger days = remainingSeconds / (24 * 3600);
//        remainingSeconds = remainingSeconds % (24 * 3600); //keep the remainder
        NSInteger hours = remainingSeconds / 3600;
        remainingSeconds = remainingSeconds % 3600; //keep the remainder
        NSInteger minutes = remainingSeconds / 60;
        remainingSeconds = remainingSeconds % 60; //keep the remainder
        
        NSString* timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)remainingSeconds];
        
//        if (days > 0) {
//            timeString = [NSString stringWithFormat:@"%02ld:%@",(long)days,timeString];
//        }
        
        self.clockLabel.text = timeString;
        CGFloat width = self.clockLabel.width;
        [self.clockLabel sizeToFit];
        [self.clockLabel setWidth:width];
    }
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index;
{
    NSString* teaserTrackingInfo = @"Campaigns_Teaser";
    return teaserTrackingInfo;
}

@end
