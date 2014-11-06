//
//  JATeaserPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserPageView.h"
#import "RITeaserGroup.h"
#import "JAMainTeaserView.h"
#import "JATopSellersTeaserView.h"
#import "JATopBrandsTeaserView.h"
#import "JASmallTeaserView.h"
#import "JACampaignsTeaserView.h"
#import "JATopCategoriesTeaserView.h"
#import "JAPopularBrandsTeaserView.h"

@interface JATeaserPageView()

@property (nonatomic, assign)CGFloat currentY;

@property (nonatomic, strong)UIScrollView* mainScrollView;
@property (nonatomic, strong)UIScrollView* landscapeScrollView;

@end

@implementation JATeaserPageView

- (void)loadTeasers;
{
    self.accessibilityLabel = @"teaserPageScrollView";
    
    [self.mainScrollView removeFromSuperview];
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.mainScrollView];
    
    if (NOTEMPTY(self.teaserCategory)) {
        
        self.backgroundColor = JABackgroundGrey;
        
        self.currentY = self.bounds.origin.y; //shared between methods
        
        [self loadMainTeasersInScrollView:self.mainScrollView];
        [self loadBrandTeasersOrTopSellersInScrollView:self.mainScrollView];
        [self loadSmallTeasersInScrollView:self.mainScrollView];
        [self loadCampaignsInScrollView:self.mainScrollView];
        [self loadPopularCategoriesInScrollView:self.mainScrollView];
        [self loadTopBrandsInScrollView:self.mainScrollView];
        
        [self.mainScrollView setContentSize:CGSizeMake(self.frame.size.width,
                                                       self.currentY)];
    }
}

- (void)loadMainTeasersInScrollView:(UIScrollView*)scrollView
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (0 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JAMainTeaserView* mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                  self.currentY,
                                                                                                  scrollView.bounds.size.width,
                                                                                                  1)]; //height is set by the view itself
            [scrollView addSubview:mainTeaserView];
            [mainTeaserView setTeasers:teaserGroup.teasers];
            [mainTeaserView load];
            
            self.currentY += mainTeaserView.frame.size.height;
            
            break;
        }
    }
}

- (void)loadBrandTeasersOrTopSellersInScrollView:(UIScrollView*)scrollView
{
    if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"fashion"]) {
        
        //brand teasers
        for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
            
            if (4 == [teaserGroup.type integerValue]) {
                
                //found it
                
                JATopBrandsTeaserView* topSellersTeaserView = [[JATopBrandsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                      self.currentY,
                                                                                                                      scrollView.bounds.size.width,
                                                                                                                      1)]; //height is set by the view itself
                [scrollView addSubview:topSellersTeaserView];
                topSellersTeaserView.groupTitle = teaserGroup.title;
                [topSellersTeaserView setTeasers:teaserGroup.teasers];
                [topSellersTeaserView load];
                
                self.currentY += topSellersTeaserView.frame.size.height;
                
                break;
            }
        }
        
        
    } else if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"gm"]) {
        
        //top sellers
        for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
            
            if (2 == [teaserGroup.type integerValue] && VALID_NOTEMPTY(teaserGroup.teasers, NSOrderedSet)) {
                //found it
                JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                        self.currentY,
                                                                                                                        scrollView.bounds.size.width,
                                                                                                                        1)]; //height is set by the view itself
                [scrollView addSubview:topSellersTeaserView];
                topSellersTeaserView.groupTitle = teaserGroup.title;
                [topSellersTeaserView setTeasers:teaserGroup.teasers];
                [topSellersTeaserView load];
                
                self.currentY += topSellersTeaserView.frame.size.height;
                break;
            }
        }
        
    }
    
}

- (void)loadSmallTeasersInScrollView:(UIScrollView*)scrollView
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (1 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JASmallTeaserView* smallTeaserView = [[JASmallTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                     self.currentY,
                                                                                                     scrollView.bounds.size.width,
                                                                                                     1)]; //height is set by the view itself
            [scrollView addSubview:smallTeaserView];
            smallTeaserView.groupTitle = teaserGroup.title;
            [smallTeaserView setTeasers:teaserGroup.teasers];
            [smallTeaserView load];
            
            self.currentY += smallTeaserView.frame.size.height;
            
            break;
        }
    }
}

- (void)loadCampaignsInScrollView:(UIScrollView*)scrollView
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (6 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JACampaignsTeaserView* campaignsTeaserView = [[JACampaignsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                 self.currentY,
                                                                                                                 scrollView.bounds.size.width,
                                                                                                                 1)]; //height is set by the view itself
            [scrollView addSubview:campaignsTeaserView];
            campaignsTeaserView.groupTitle = teaserGroup.title;
            [campaignsTeaserView setTeasers:teaserGroup.teasers];
            [campaignsTeaserView load];
            
            self.currentY += campaignsTeaserView.frame.size.height;
            
            break;
        }
    }
}

- (void)loadPopularCategoriesInScrollView:(UIScrollView*)scrollView
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (3 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JATopCategoriesTeaserView* topCategoriesTeaserView = [[JATopCategoriesTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                             self.currentY,
                                                                                                                             scrollView.bounds.size.width,
                                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:topCategoriesTeaserView];
            topCategoriesTeaserView.groupTitle = teaserGroup.title;
            [topCategoriesTeaserView setTeasers:teaserGroup.teasers];
            [topCategoriesTeaserView load];
            
            self.currentY += topCategoriesTeaserView.frame.size.height;
            
            break;
        }
    }
}

- (void)loadTopBrandsInScrollView:(UIScrollView*)scrollView
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (5 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JAPopularBrandsTeaserView* popularBrandsTeaserView = [[JAPopularBrandsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                             self.currentY,
                                                                                                                             scrollView.bounds.size.width,
                                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:popularBrandsTeaserView];
            popularBrandsTeaserView.groupTitle = teaserGroup.title;
            [popularBrandsTeaserView setTeasers:teaserGroup.teasers];
            [popularBrandsTeaserView load];
            
            self.currentY += popularBrandsTeaserView.frame.size.height;
            
            break;
        }
    }
}

@end
