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
#import "JAShopTeaserView.h"
#import "JABrandTeaserView.h"
#import "JAShopsWeekTeaserView.h"
#import "JANewsletterTeaserView.h"
#import "JAFeatureStoresTeaserView.h"
#import "JATopSellersTeaserView.h"
#import "JADynamicForm.h"

@interface JATeaserPageView()
{
    BOOL _needsRefresh;
}

@property (nonatomic, strong)UIScrollView* mainScrollView;
//we need to keep the main teaser because we have to access it to know about it's last position
@property (nonatomic, strong)JAMainTeaserView* mainTeaserView;
@property (nonatomic, assign)NSInteger mainTeaserLastIndex;

@end

@implementation JATeaserPageView

- (void)loadTeasersForFrame:(CGRect)frame;
{
    if (!_needsRefresh) {
        return;
    }
    self.frame = frame;
    _needsRefresh = NO;
    
    self.accessibilityLabel = @"teaserPageScrollView";
    
    self.backgroundColor = JAHomePageBackgroundGrey;
    
    self.mainTeaserLastIndex = self.mainTeaserView.currentPage;
    
    [self.mainScrollView removeFromSuperview];
    
    if (VALID_NOTEMPTY(self.teaserGroupings, NSDictionary)) {
        
        self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.mainScrollView];
        
        CGFloat mainScrollY = self.bounds.origin.y; //shared between methods
        
        CGFloat centerScrollX = self.mainScrollView.frame.origin.x;
        CGFloat centerScrollWidth = self.mainScrollView.frame.size.width;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            centerScrollWidth = 640.0f; //value by design
            centerScrollX = (self.mainScrollView.frame.size.width - centerScrollWidth) / 2;
        }
        
        mainScrollY = [self loadMainTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
        mainScrollY = [self loadSmallTeasersInScrollView:self.mainScrollView yPosition:mainScrollY];
        mainScrollY = [self loadCampaignTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadShopTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadBrandTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadShopsWeekTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadNewsletterForInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadFeatureStoresTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY = [self loadTopSellersTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        
        mainScrollY += 6.0f;
        
        [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, mainScrollY)];
        
    }
}

- (void)setNewsletterForm:(RIForm *)newsletterForm
{
    _newsletterForm = newsletterForm;
    _needsRefresh = YES;
}

- (void)layoutSubviews
{
    _needsRefresh = YES;
    [self loadTeasersForFrame:self.frame];
}

- (void)addTeaserGrouping:(NSString*)type {
    
    CGFloat mainScrollY = self.mainScrollView.contentSize.height - 6.f;
    CGFloat centerScrollX = self.mainScrollView.frame.origin.x;
    CGFloat centerScrollWidth = self.mainScrollView.frame.size.width;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        centerScrollWidth = 640.0f; //value by design
        centerScrollX = (self.mainScrollView.frame.size.width - centerScrollWidth) / 2;
    }
    
    if ([type isEqualToString:@"top_sellers"]) {
        mainScrollY = [self loadTopSellersTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:mainScrollY width:centerScrollWidth];
        mainScrollY += 6.0f;
        
        [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width,
                                                       mainScrollY)];
    }
}

- (CGFloat)loadMainTeasersInScrollView:(UIScrollView*)scrollView
                             yPosition:(CGFloat)yPosition
{
    if ([self.teaserGroupings objectForKey:@"main_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"main_teasers"];
        
        if (!self.mainTeaserView)
        {
            self.mainTeaserLastIndex = RI_IS_RTL?teaserGrouping.teaserComponents.count-1:0;
        }
        
        self.mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                 yPosition,
                                                                                 scrollView.bounds.size.width,
                                                                                 1)]; //height is set by the view itself
        [scrollView addSubview:self.mainTeaserView];
        self.mainTeaserView.teaserGrouping = teaserGrouping;
        [self.mainTeaserView load];
        [self.mainTeaserView scrollToIndex:self.mainTeaserLastIndex];
        
        yPosition += self.mainTeaserView.frame.size.height;
    }
    
    return yPosition;
}

- (CGFloat)loadSmallTeasersInScrollView:(UIScrollView*)scrollView
                              yPosition:(CGFloat)yPosition
{
    if ([self.teaserGroupings objectForKey:@"small_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"small_teasers"];
        
        JASmallTeaserView* smallTeaserView = [[JASmallTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                 yPosition,
                                                                                                 scrollView.bounds.size.width,
                                                                                                 1)]; //height is set by the view itself
        [scrollView addSubview:smallTeaserView];
        smallTeaserView.teaserGrouping = teaserGrouping;
        [smallTeaserView load];
        
        yPosition += smallTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadCampaignTeasersInScrollView:(UIScrollView*)scrollView
                                 xPosition:(CGFloat)xPosition
                                 yPosition:(CGFloat)yPosition
                                     width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"campaigns"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"campaigns"];
        
        JACampaignsTeaserView* campaignsTeaserView = [[JACampaignsTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                             yPosition,
                                                                                                             width,
                                                                                                             1)]; //height is set by the view itself
        [scrollView addSubview:campaignsTeaserView];
        campaignsTeaserView.teaserGrouping = teaserGrouping;
        [campaignsTeaserView load];
        
        yPosition += campaignsTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadShopTeasersInScrollView:(UIScrollView*)scrollView
                             xPosition:(CGFloat)xPosition
                             yPosition:(CGFloat)yPosition
                                 width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"shop_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"shop_teasers"];
        
        JAShopTeaserView* shopTeaserView = [[JAShopTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                              yPosition,
                                                                                              width,
                                                                                              1)]; //height is set by the view itself
        [scrollView addSubview:shopTeaserView];
        shopTeaserView.teaserGrouping = teaserGrouping;
        [shopTeaserView load];
        
        yPosition += shopTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadBrandTeasersInScrollView:(UIScrollView*)scrollView
                              xPosition:(CGFloat)xPosition
                              yPosition:(CGFloat)yPosition
                                  width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"brand_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"brand_teasers"];
        
        JABrandTeaserView* brandTeaserView = [[JABrandTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                 yPosition,
                                                                                                 width,
                                                                                                 1)]; //height is set by the view itself
        [scrollView addSubview:brandTeaserView];
        brandTeaserView.teaserGrouping = teaserGrouping;
        [brandTeaserView load];
        
        yPosition += brandTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadShopsWeekTeasersInScrollView:(UIScrollView*)scrollView
                                  xPosition:(CGFloat)xPosition
                                  yPosition:(CGFloat)yPosition
                                      width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"shop_of_week"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"shop_of_week"];
        
        JAShopsWeekTeaserView* shopsWeekTeaserView = [[JAShopsWeekTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                             yPosition,
                                                                                                             width,
                                                                                                             1)]; //height is set by the view itself
        [scrollView addSubview:shopsWeekTeaserView];
        shopsWeekTeaserView.teaserGrouping = teaserGrouping;
        [shopsWeekTeaserView load];
        
        yPosition += shopsWeekTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadNewsletterForInScrollView:(UIScrollView*)scrollView
                                      xPosition:(CGFloat)xPosition
                                      yPosition:(CGFloat)yPosition
                                          width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"form_newsletter"] && self.newsletterForm) {
        JANewsletterTeaserView* newsletterTeaserView = [[JANewsletterTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                                yPosition,
                                                                                                                width,
                                                                                                                1)]; //height is set by the view itself
        [newsletterTeaserView setGenderPickerDelegate:self.genderPickerDelegate?:nil];
        [newsletterTeaserView setForm:self.newsletterForm];
        [scrollView addSubview:newsletterTeaserView];
        
        yPosition += newsletterTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadFeatureStoresTeasersInScrollView:(UIScrollView*)scrollView
                                      xPosition:(CGFloat)xPosition
                                      yPosition:(CGFloat)yPosition
                                          width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"featured_stores"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"featured_stores"];
        
        JAFeatureStoresTeaserView* featureStoresTeaserView = [[JAFeatureStoresTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                                         yPosition,
                                                                                                                         width,
                                                                                                                         1)]; //height is set by the view itself
        [scrollView addSubview:featureStoresTeaserView];
        featureStoresTeaserView.teaserGrouping = teaserGrouping;
        [featureStoresTeaserView load];
        
        yPosition += featureStoresTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadTopSellersTeasersInScrollView:(UIScrollView*)scrollView
                                   xPosition:(CGFloat)xPosition
                                   yPosition:(CGFloat)yPosition
                                       width:(CGFloat)width
{
    if ([self.teaserGroupings objectForKey:@"top_sellers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"top_sellers"];
        
        JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(xPosition,
                                                                                                                yPosition,
                                                                                                                width,
                                                                                                                1)]; //height is set by the view itself
        [scrollView addSubview:topSellersTeaserView];
        topSellersTeaserView.teaserGrouping = teaserGrouping;
        [topSellersTeaserView load];
        
        yPosition += topSellersTeaserView.frame.size.height;
        
    }
    return yPosition;
}

@end
