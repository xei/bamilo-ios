//
//  JACampaignPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignPageView.h"
#import "RICampaign.h"

@interface JACampaignPageView()

@property (nonatomic, strong)NSArray* campaigns;
@property (nonatomic, strong)NSString* bannerImageUrl;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)NSMutableArray* campaignSingleViewsArray;

@end

@implementation JACampaignPageView

- (void)loadWithCampaignUrl:(NSString*)campaignUrl
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    if (VALID_NOTEMPTY(campaignUrl, NSString)) {
        [RICampaign getCampaignsWithUrl:campaignUrl successBlock:^(NSArray *campaigns, NSString* bannerImageUrl) {
            if (VALID_NOTEMPTY(bannerImageUrl, NSString)) {
                self.bannerImageUrl = bannerImageUrl;
                [self loadBanner];
            }
            self.campaigns = campaigns;
            [self loadCampaignViews];
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
    
    if (VALID_NOTEMPTY(campaignId, NSString)) {
        [RICampaign getCampaignsWitId:campaignId successBlock:^(NSString *name, NSArray *campaigns, NSString* bannerImageUrl) {
            if (VALID_NOTEMPTY(bannerImageUrl, NSString)) {
                self.bannerImageUrl = bannerImageUrl;
                [self loadBanner];
            }
            self.campaigns = campaigns;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadSuccessWithName:)]) {
                [self.delegate loadSuccessWithName:name];
            }
            
            [self loadCampaignViews];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(loadFailedWithResponse:)]) {
                [self.delegate loadFailedWithResponse:apiResponse];
            }
        }];
    }
}

- (void)loadBanner
{
    
}

- (void)loadCampaignViews
{
    self.campaignSingleViewsArray = [NSMutableArray new];
    CGFloat currentY = self.scrollView.bounds.origin.y;
    for (RICampaign* campaign in self.campaigns) {
        JACampaignSingleView* campaignView = [JACampaignSingleView getNewJACampaignSingleView];
        campaignView.delegate = self.singleViewDelegate;
        [campaignView setFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                          currentY,
                                          self.scrollView.frame.size.width,
                                          338.0f)];
        [self.scrollView addSubview:campaignView];
        [self.campaignSingleViewsArray addObject:campaignView];
        [campaignView loadWithCampaign:campaign];
        currentY += campaignView.frame.size.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             currentY + 4.0f);
}

- (void)updateTimerOnAllCampaigns:(NSInteger)elapsedTimeInSeconds
{
    if (VALID_NOTEMPTY(self.campaignSingleViewsArray, NSMutableArray)) {
        for (JACampaignSingleView* campaignSingleView in self.campaignSingleViewsArray) {
            [campaignSingleView updateTimeLabelText:elapsedTimeInSeconds];
        }
    }
}

@end
