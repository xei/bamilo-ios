//
//  JATeaserPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserPageView.h"

#import "JAMainTeaserView.h"
#import "JASmallTeaserView.h"
#import "JACampaignsTeaserView.h"
#import "JAShopTeaserView.h"
#import "JABrandTeaserView.h"
#import "JAShopsWeekTeaserView.h"
#import "JAFeatureStoresTeaserView.h"
#import "JATopSellersTeaserView.h"

@interface JATeaserPageView()

@property (nonatomic, strong)UIScrollView* mainScrollView;

@end

@implementation JATeaserPageView

- (void)loadTeasersForFrame:(CGRect)frame;
{
    self.frame = frame;
    BOOL isLandscape = frame.size.width>frame.size.height?YES:NO;
    
    self.accessibilityLabel = @"teaserPageScrollView";
    
    self.backgroundColor = JAHomePageBackgroundGrey;
    
    [self.mainScrollView removeFromSuperview];
    
    if (VALID_NOTEMPTY(self.teaserGroupings, NSArray)) {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && isLandscape) {
            

        } else {
            
            self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            [self addSubview:self.mainScrollView];
            
            CGFloat mainScrollY = self.bounds.origin.y; //shared between methods
            
            mainScrollY = [self loadMainTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadSmallTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadCampaignTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadShopTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadBrandTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadShopsWeekTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadFeatureStoresTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadTopSellersTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            
            mainScrollY += 6.0f;
            
            [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width,
                                                           mainScrollY)];
        }
    }
}

- (CGFloat)loadMainTeasersInScrollView:(UIScrollView*)scrollView
                             yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"main_teasers"]) {
            //found it
            
            JAMainTeaserView* mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                  yPosition,
                                                                                                  scrollView.bounds.size.width,
                                                                                                  1)]; //height is set by the view itself
            [scrollView addSubview:mainTeaserView];
            mainTeaserView.teaserGrouping = teaserGrouping;
            [mainTeaserView load];
            
            yPosition += mainTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadSmallTeasersInScrollView:(UIScrollView*)scrollView
                              yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"small_teasers"]) {
            //found it
            
            JASmallTeaserView* smallTeaserView = [[JASmallTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                    yPosition,
                                                                                                    scrollView.bounds.size.width,
                                                                                                    1)]; //height is set by the view itself
            [scrollView addSubview:smallTeaserView];
            smallTeaserView.teaserGrouping = teaserGrouping;
            [smallTeaserView load];
            
            yPosition += smallTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadCampaignTeasersInScrollView:(UIScrollView*)scrollView
                                 yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"campaigns"]) {
            //found it
            
            JACampaignsTeaserView* campaignsTeaserView = [[JACampaignsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                             yPosition,
                                                                                                             scrollView.bounds.size.width,
                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:campaignsTeaserView];
            campaignsTeaserView.teaserGrouping = teaserGrouping;
            [campaignsTeaserView load];
            
            yPosition += campaignsTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadShopTeasersInScrollView:(UIScrollView*)scrollView
                             yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"shop_teasers"]) {
            //found it
            
            JAShopTeaserView* shopTeaserView = [[JAShopTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                 yPosition,
                                                                                                                 scrollView.bounds.size.width,
                                                                                                                 1)]; //height is set by the view itself
            [scrollView addSubview:shopTeaserView];
            shopTeaserView.teaserGrouping = teaserGrouping;
            [shopTeaserView load];
            
            yPosition += shopTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadBrandTeasersInScrollView:(UIScrollView*)scrollView
                              yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"shop_teasers"]) {
            //found it
            
            JABrandTeaserView* brandTeaserView = [[JABrandTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                     yPosition,
                                                                                                     scrollView.bounds.size.width,
                                                                                                     1)]; //height is set by the view itself
            [scrollView addSubview:brandTeaserView];
            brandTeaserView.teaserGrouping = teaserGrouping;
            [brandTeaserView load];
            
            yPosition += brandTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadShopsWeekTeasersInScrollView:(UIScrollView*)scrollView
                                  yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"shop_of_week"]) {
            //found it
            
            JAShopsWeekTeaserView* shopsWeekTeaserView = [[JAShopsWeekTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                 yPosition,
                                                                                                                 scrollView.bounds.size.width,
                                                                                                                 1)]; //height is set by the view itself
            [scrollView addSubview:shopsWeekTeaserView];
            shopsWeekTeaserView.teaserGrouping = teaserGrouping;
            [shopsWeekTeaserView load];
            
            yPosition += shopsWeekTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadFeatureStoresTeasersInScrollView:(UIScrollView*)scrollView
                                      yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"featured_stores"]) {
            //found it
            
            JAFeatureStoresTeaserView* featureStoresTeaserView = [[JAFeatureStoresTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                             yPosition,
                                                                                                                             scrollView.bounds.size.width,
                                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:featureStoresTeaserView];
            featureStoresTeaserView.teaserGrouping = teaserGrouping;
            [featureStoresTeaserView load];
            
            yPosition += featureStoresTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadTopSellersTeasersInScrollView:(UIScrollView*)scrollView
                                   yPosition:(CGFloat)yPosition
{
    for (RITeaserGrouping* teaserGrouping in self.teaserGroupings) {
        if ([teaserGrouping.type isEqualToString:@"top_sellers"]) {
            //found it
            
            JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                    yPosition,
                                                                                                                    scrollView.bounds.size.width,
                                                                                                                    1)]; //height is set by the view itself
            [scrollView addSubview:topSellersTeaserView];
            topSellersTeaserView.teaserGrouping = teaserGrouping;
            [topSellersTeaserView load];
            
            yPosition += topSellersTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

@end
