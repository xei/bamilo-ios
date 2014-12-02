//
//  JACampaignPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignPageView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+JA.h"
#import "RICampaign.h"

@interface JACampaignPageView()

@property (nonatomic, strong)NSString* campaignsName;
@property (nonatomic, strong)NSArray* campaigns;
@property (nonatomic, strong)NSString* bannerImageUrl;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, assign)CGFloat campaignsCurrentY;
@property (nonatomic, strong)NSMutableArray* campaignSingleViewsArray;

@end

@implementation JACampaignPageView

- (void)loadWithCampaignUrl:(NSString*)campaignUrl
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    self.campaignsCurrentY = self.scrollView.frame.origin.y;
    
    if (VALID_NOTEMPTY(campaignUrl, NSString))
    {
        [RICampaign getCampaignsWithUrl:campaignUrl successBlock:^(NSString* name, NSArray *campaigns, NSString* bannerImageUrl)
         {
             self.campaigns = campaigns;
             self.campaignsName = name;
             
             if (VALID_NOTEMPTY(bannerImageUrl, NSString))
             {
                 self.bannerImageUrl = bannerImageUrl;
                 [self loadBanner];
             }
             else
             {
                 [self finishingCampaingLoading];
             }
         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
             if (self.delegate && [self.delegate respondsToSelector:@selector(loadFailedWithResponse:)]) {
                 [self.delegate loadFailedWithResponse:apiResponse];
             }
         }];
    }
}

- (void)loadWithCampaignId:(NSString*)campaignId
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    self.campaignsCurrentY = self.scrollView.frame.origin.y;
    
    if (VALID_NOTEMPTY(campaignId, NSString))
    {
        [RICampaign getCampaignsWitId:campaignId successBlock:^(NSString *name, NSArray *campaigns, NSString* bannerImageUrl)
         {
             self.campaigns = campaigns;
             self.campaignsName = name;
             
             if (VALID_NOTEMPTY(bannerImageUrl, NSString))
             {
                 self.bannerImageUrl = bannerImageUrl;
                 [self loadBanner];
             }
             else
             {
                 [self finishingCampaingLoading];
             }
         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
             if (self.delegate && [self.delegate respondsToSelector:@selector(loadFailedWithResponse:)]) {
                 [self.delegate loadFailedWithResponse:apiResponse];
             }
         }];
    }
}

- (void)finishingCampaingLoading
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadSuccessWithName:)]) {
        [self.delegate loadSuccessWithName:self.campaignsName];
    }
    
    [self loadCampaignViews];
}

- (void)loadBanner
{
    self.bannerImageUrl = [self.bannerImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    __block UIImageView *blockedImageView = imageView;
    [imageView setImageWithURL:[NSURL URLWithString:self.bannerImageUrl]
                       success:^(UIImage *image, BOOL cached)
     {
         [blockedImageView changeImageSize:0.0f andWidth:self.scrollView.frame.size.width];
         [self.scrollView addSubview:blockedImageView];
         self.campaignsCurrentY = blockedImageView.frame.size.height;
         
         [self finishingCampaingLoading];
         
     }
                       failure:^(NSError *error)
     {
         [self finishingCampaingLoading];
     }];
}

- (void)loadCampaignViews
{
    self.campaignSingleViewsArray = [NSMutableArray new];
    
    NSInteger numberOfColumns = 1;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        numberOfColumns = 2;
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            numberOfColumns = 3;
        }
    }
    
    if(VALID_NOTEMPTY(self.campaigns, NSArray))
    {
        // Left maring
        CGFloat originX = self.scrollView.frame.origin.x + 6.0f;

        // Add top margin to current y
        self.campaignsCurrentY += 6.0f;
        
        CGFloat campaingViewHeight = 0.0f;
        
        for (int i = 0; i < [self.campaigns count]; i++)
        {
            RICampaign* campaign = [self.campaigns objectAtIndex:i];
            JACampaignSingleView* campaignView = [JACampaignSingleView getNewJACampaignSingleView:self.interfaceOrientation];
            campaignView.delegate = self.singleViewDelegate;
            [campaignView setFrame:CGRectMake(originX,
                                              self.campaignsCurrentY,
                                              campaignView.frame.size.width,
                                              campaignView.frame.size.height)];
            [self.scrollView addSubview:campaignView];
            [self.campaignSingleViewsArray addObject:campaignView];
            [campaignView loadWithCampaign:campaign];

            campaingViewHeight = campaignView.frame.size.height;
            originX += campaignView.frame.size.width + 6.0f;
            if(0 == ((i + 1) % numberOfColumns))
            {
                originX = self.scrollView.frame.origin.x + 6.0f;
                self.campaignsCurrentY += campaingViewHeight + 6.0f;
            }
        }
        
        // This means that there is an extra row, so we need to add the space for that
        if(originX != self.scrollView.frame.origin.x + 6.0f)
        {
            self.campaignsCurrentY += campaingViewHeight + 6.0f;
        }
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.campaignsCurrentY);
    }
}

- (void)updateTimerOnAllCampaigns:(NSInteger)elapsedTimeInSeconds
{
    if (VALID_NOTEMPTY(self.campaignSingleViewsArray, NSMutableArray)) {
        for (JACampaignSingleView* campaignSingleView in self.campaignSingleViewsArray) {
            [campaignSingleView updateTimeLabelText:elapsedTimeInSeconds];
        }
    }
}

- (void)reloadViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.interfaceOrientation = interfaceOrientation;
    [self.scrollView setFrame:self.bounds];
    
    self.campaignsCurrentY = self.scrollView.frame.origin.y;
    
    for(UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.bannerImageUrl, NSString))
    {
        [self loadBanner];
    }
    else
    {
        [self loadCampaignViews];
    }
}

@end
