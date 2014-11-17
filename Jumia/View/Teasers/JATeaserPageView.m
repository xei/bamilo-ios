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

@property (nonatomic, strong)UIScrollView* mainScrollView;
@property (nonatomic, strong)UIScrollView* landscapeScrollView;

@end

@implementation JATeaserPageView

- (void)loadTeasersForFrame:(CGRect)frame;
{
    self.frame = frame;
    BOOL isLandscape = frame.size.width>frame.size.height?YES:NO;
    
    self.accessibilityLabel = @"teaserPageScrollView";
    
    self.backgroundColor = JABackgroundGrey;
    
    [self.mainScrollView removeFromSuperview];
    [self.landscapeScrollView removeFromSuperview];
    
    if (NOTEMPTY(self.teaserCategory)) {
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && isLandscape) {
            
            self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                                 self.bounds.origin.y,
                                                                                 self.bounds.size.width / 2,
                                                                                 self.bounds.size.height)];
            [self addSubview:self.mainScrollView];
            self.landscapeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.mainScrollView.frame),
                                                                                      self.bounds.origin.y,
                                                                                      self.bounds.size.width / 2,
                                                                                      self.bounds.size.height)];
            [self addSubview:self.landscapeScrollView];
            
            CGFloat mainScrollY = self.bounds.origin.y; //shared between methods
            
            mainScrollY = [self loadMainTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadBrandTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadSmallTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadCampaignsInScrollView:self.mainScrollView yPosition:mainScrollY];
            
            [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width,
                                                           mainScrollY)];
            
            CGFloat landscapeScrollY = self.bounds.origin.y; //shared between methods
            
            landscapeScrollY = [self loadPopularCategoriesAndTopBrandsForLandscapeInScrollView:self.landscapeScrollView yPosition:landscapeScrollY];
            landscapeScrollY = [self loadTopSellersInScrollView:self.landscapeScrollView yPosition:landscapeScrollY];
            
            [self.landscapeScrollView setContentSize:CGSizeMake(self.landscapeScrollView.frame.size.width,
                                                                landscapeScrollY)];
        } else {
            
            self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            [self addSubview:self.mainScrollView];
            
            CGFloat mainScrollY = self.bounds.origin.y; //shared between methods
            
            mainScrollY = [self loadMainTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"fashion"]) {
                mainScrollY = [self loadBrandTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            } else if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"gm"]) {
                mainScrollY = [self loadTopSellersInScrollView:self.mainScrollView yPosition:mainScrollY];
            }
            mainScrollY = [self loadSmallTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadCampaignsInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadPopularCategoriesInScrollView:self.mainScrollView yPosition:mainScrollY];
            mainScrollY = [self loadTopBrandsInScrollView:self.mainScrollView yPosition:mainScrollY];
            
            [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width,
                                                           mainScrollY)];
        }
    }
}

- (CGFloat)loadMainTeasersInScrollView:(UIScrollView*)scrollView
                             yPosition:(CGFloat)yPosition
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (0 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JAMainTeaserView* mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                  yPosition,
                                                                                                  scrollView.bounds.size.width,
                                                                                                  1)]; //height is set by the view itself
            [scrollView addSubview:mainTeaserView];
            [mainTeaserView setTeasers:teaserGroup.teasers];
            [mainTeaserView load];
            
            yPosition += mainTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadBrandTeasersInScrollView:(UIScrollView*)scrollView
                              yPosition:(CGFloat)yPosition
{
    //brand teasers
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (4 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JATopBrandsTeaserView* topSellersTeaserView = [[JATopBrandsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                  yPosition,
                                                                                                                  scrollView.bounds.size.width,
                                                                                                                  1)]; //height is set by the view itself
            [scrollView addSubview:topSellersTeaserView];
            topSellersTeaserView.groupTitle = teaserGroup.title;
            [topSellersTeaserView setTeasers:teaserGroup.teasers];
            [topSellersTeaserView load];
            
            yPosition += topSellersTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadTopSellersInScrollView:(UIScrollView*)scrollView
                            yPosition:(CGFloat)yPosition
{
    //top sellers
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (2 == [teaserGroup.type integerValue] && VALID_NOTEMPTY(teaserGroup.teasers, NSOrderedSet)) {
            //found it
            JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                    yPosition,
                                                                                                                    scrollView.bounds.size.width,
                                                                                                                    1)]; //height is set by the view itself
            [scrollView addSubview:topSellersTeaserView];
            topSellersTeaserView.groupTitle = teaserGroup.title;
            [topSellersTeaserView setTeasers:teaserGroup.teasers];
            [topSellersTeaserView load];
            
            yPosition += topSellersTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadSmallTeasersInScrollView:(UIScrollView*)scrollView
                              yPosition:(CGFloat)yPosition
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (1 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JASmallTeaserView* smallTeaserView = [[JASmallTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                     yPosition,
                                                                                                     scrollView.bounds.size.width,
                                                                                                     1)]; //height is set by the view itself
            [scrollView addSubview:smallTeaserView];
            smallTeaserView.groupTitle = teaserGroup.title;
            [smallTeaserView setTeasers:teaserGroup.teasers];
            [smallTeaserView load];
            
            yPosition += smallTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadCampaignsInScrollView:(UIScrollView*)scrollView
                           yPosition:(CGFloat)yPosition
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (6 == [teaserGroup.type integerValue]) {
            
            //found it
            
            CGFloat marginNegation = 0;
            BOOL isLandscape = self.frame.size.width>self.frame.size.height?YES:NO;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && isLandscape) {
                marginNegation = 6;
            }
            
            JACampaignsTeaserView* campaignsTeaserView = [[JACampaignsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                 yPosition,
                                                                                                                 scrollView.bounds.size.width + marginNegation,
                                                                                                                 1)]; //height is set by the view itself
            [scrollView addSubview:campaignsTeaserView];
            campaignsTeaserView.groupTitle = teaserGroup.title;
            [campaignsTeaserView setTeasers:teaserGroup.teasers];
            campaignsTeaserView.isLandscape = isLandscape;
            [campaignsTeaserView load];
            
            yPosition += campaignsTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadPopularCategoriesInScrollView:(UIScrollView*)scrollView
                                   yPosition:(CGFloat)yPosition
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (3 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JATopCategoriesTeaserView* topCategoriesTeaserView = [[JATopCategoriesTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                             yPosition,
                                                                                                                             scrollView.bounds.size.width,
                                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:topCategoriesTeaserView];
            topCategoriesTeaserView.groupTitle = teaserGroup.title;
            [topCategoriesTeaserView setTeasers:teaserGroup.teasers];
            [topCategoriesTeaserView load];
            
            yPosition += topCategoriesTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadTopBrandsInScrollView:(UIScrollView*)scrollView
                           yPosition:(CGFloat)yPosition
{
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (5 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JAPopularBrandsTeaserView* popularBrandsTeaserView = [[JAPopularBrandsTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                                             yPosition,
                                                                                                                             scrollView.bounds.size.width,
                                                                                                                             1)]; //height is set by the view itself
            [scrollView addSubview:popularBrandsTeaserView];
            popularBrandsTeaserView.groupTitle = teaserGroup.title;
            [popularBrandsTeaserView setTeasers:teaserGroup.teasers];
            [popularBrandsTeaserView load];
            
            yPosition += popularBrandsTeaserView.frame.size.height;
            
            break;
        }
    }
    return yPosition;
}

- (CGFloat)loadPopularCategoriesAndTopBrandsForLandscapeInScrollView:(UIScrollView*)scrollView
                                                           yPosition:(CGFloat)yPosition
{
    RITeaserGroup* topCategoriesTeaserGroup;
    RITeaserGroup* popularBrandsTeaserGroup;
    
    JATopCategoriesTeaserView* topCategoriesTeaserView;
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (3 == [teaserGroup.type integerValue]) {
            
            //found it
            topCategoriesTeaserGroup = teaserGroup;
            break;
        }
    }
    
    JAPopularBrandsTeaserView* popularBrandsTeaserView;
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
        
        if (5 == [teaserGroup.type integerValue]) {
            
            //found it
            popularBrandsTeaserGroup = teaserGroup;
            break;
        }
    }
    
    CGRect topCategoriesRect;
    CGRect popularBrandsRect;
    
    if (VALID_NOTEMPTY(topCategoriesTeaserGroup, RITeaserGroup) && VALID_NOTEMPTY(popularBrandsTeaserGroup, RITeaserGroup)) {
        
        topCategoriesRect = CGRectMake(scrollView.bounds.origin.x,
                                       yPosition,
                                       scrollView.bounds.size.width / 2 + 3, //manually removing the border because it would be too much hussle otherwise
                                       1); //height is set by the view itself
        popularBrandsRect = CGRectMake(CGRectGetMaxX(topCategoriesRect) - 6, //manually removing the border because it would be too much hussle otherwise
                                       yPosition,
                                       scrollView.bounds.size.width / 2 + 3, //manually removing the border because it would be too much hussle otherwise
                                       1); //height is set by the view itself
        
    } else if (VALID_NOTEMPTY(topCategoriesTeaserGroup, RITeaserGroup)) {
    
        topCategoriesRect = CGRectMake(scrollView.bounds.origin.x,
                                       yPosition,
                                       scrollView.bounds.size.width,
                                       1); //height is set by the view itself
        
    } else if (VALID_NOTEMPTY(popularBrandsTeaserGroup, RITeaserGroup)) {
    
        popularBrandsRect = CGRectMake(scrollView.bounds.origin.x,
                                       yPosition,
                                       scrollView.bounds.size.width,
                                       1); //height is set by the view itself
    }
    
    if (VALID_NOTEMPTY(topCategoriesTeaserGroup, RITeaserGroup)) {
        topCategoriesTeaserView = [[JATopCategoriesTeaserView alloc] initWithFrame:topCategoriesRect];
        [scrollView addSubview:topCategoriesTeaserView];
        topCategoriesTeaserView.groupTitle = topCategoriesTeaserGroup.title;
        [topCategoriesTeaserView setTeasers:topCategoriesTeaserGroup.teasers];
        [topCategoriesTeaserView load];
    }
    
    if (VALID_NOTEMPTY(popularBrandsTeaserGroup, RITeaserGroup)) {
        popularBrandsTeaserView = [[JAPopularBrandsTeaserView alloc] initWithFrame:popularBrandsRect];
        [scrollView addSubview:popularBrandsTeaserView];
        popularBrandsTeaserView.groupTitle = popularBrandsTeaserGroup.title;
        [popularBrandsTeaserView setTeasers:popularBrandsTeaserGroup.teasers];
        [popularBrandsTeaserView load];
    }

    CGFloat maxHeight = MAX(topCategoriesTeaserView.frame.size.height, popularBrandsTeaserView.frame.size.height);
    [topCategoriesTeaserView adjustHeight:maxHeight];
    [popularBrandsTeaserView adjustHeight:maxHeight];
    
    yPosition += MAX(topCategoriesTeaserView.frame.size.height, popularBrandsTeaserView.frame.size.height);
    
    return yPosition;
}

@end
