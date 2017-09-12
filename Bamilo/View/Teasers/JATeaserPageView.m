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
    BOOL _keyboardEvent;
}

//we need to keep the main teaser because we have to access it to know about it's last position
@property (nonatomic, strong) JAMainTeaserView* mainTeaserView;
@property (nonatomic, assign) NSInteger mainTeaserLastIndex;
@property (nonatomic, strong) JANewsletterTeaserView* newsletterTeaserView;

@end

const CGFloat marginBottom = 6.0f;

@implementation JATeaserPageView {
    CGFloat currentMainScrollY;
    CGFloat centerScrollX;
    CGFloat centerScrollWidth;
}

- (void)loadTeasersForFrame:(CGRect)frame {
    if (!_needsRefresh) {
        return;
    }
    self.frame = frame;
    _needsRefresh = NO;
    
    self.accessibilityLabel = @"teaserPageScrollView";
    
    self.backgroundColor = [Theme color:kColorVeryLightGray];
    
    self.mainTeaserLastIndex = self.mainTeaserView.currentPage;
    
    [self.mainScrollView removeFromSuperview];
    
    if (self.teaserGroupings) {
        
        self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.mainScrollView];
        
        currentMainScrollY = self.bounds.origin.y; //shared between methods
        
        centerScrollX = self.mainScrollView.frame.origin.x;
        centerScrollWidth = self.mainScrollView.frame.size.width;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            centerScrollWidth = 640.0f; //value by design
            centerScrollX = (self.mainScrollView.frame.size.width - centerScrollWidth) / 2;
        }
        
        currentMainScrollY = [self loadMainTeasersInScrollView:self.mainScrollView yPosition:currentMainScrollY];
        currentMainScrollY = [self loadSmallTeasersInScrollView:self.mainScrollView yPosition:currentMainScrollY];
        currentMainScrollY = [self loadNewsletterForInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadCampaignTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadShopTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadBrandTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadShopsWeekTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadFeatureStoresTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY = [self loadTopSellersTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY += marginBottom;
        [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, currentMainScrollY)];
    }
    [self.delegate teaserPageIsReady:self];
}

- (void)setNewsletterForm:(RIForm *)newsletterForm {
    _newsletterForm = newsletterForm;
    _needsRefresh = YES;
}

//- (void)layoutSubviews {
//    if (!_keyboardEvent) {
//        _needsRefresh = YES;
//        [self loadTeasersForFrame:self.frame];
//    }
//    _keyboardEvent = NO;
//}

- (void)addCustomViewToScrollView:(UIView *)view {
    currentMainScrollY -= marginBottom;
    [view setFrame:CGRectMake(centerScrollX, currentMainScrollY, centerScrollWidth, view.frame.size.height)];
    currentMainScrollY += view.frame.size.height;
    currentMainScrollY += marginBottom;
    
    [self.mainScrollView addSubview:view];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, currentMainScrollY)];
}

- (void)addTeaserGrouping:(NSString*)type {

    if ([type isEqualToString:@"top_sellers"]) {
        currentMainScrollY -= marginBottom;
        currentMainScrollY = [self loadTopSellersTeasersInScrollView:self.mainScrollView xPosition:centerScrollX yPosition:currentMainScrollY width:centerScrollWidth];
        currentMainScrollY += marginBottom;
        
        [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, currentMainScrollY)];
    }
}

- (CGFloat)loadMainTeasersInScrollView:(UIScrollView*)scrollView yPosition:(CGFloat)yPosition {
    if ([self.teaserGroupings objectForKey:@"main_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"main_teasers"];
        
        if (!self.mainTeaserView) {
            self.mainTeaserLastIndex = RI_IS_RTL ? teaserGrouping.teaserComponents.count - 1 : 0;
        }
        
        self.mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                 yPosition,
                                                                                 scrollView.bounds.size.width,
                                                                                 1)];
        [scrollView addSubview:self.mainTeaserView];
        self.mainTeaserView.teaserGrouping = teaserGrouping;
        [self.mainTeaserView load];
        [self.mainTeaserView scrollToIndex:self.mainTeaserLastIndex];
        
        yPosition += self.mainTeaserView.frame.size.height;
    }
    
    return yPosition;
}

- (CGFloat)loadSmallTeasersInScrollView:(UIScrollView*)scrollView yPosition:(CGFloat)yPosition {
    if ([self.teaserGroupings objectForKey:@"small_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"small_teasers"];
        
        JASmallTeaserView* smallTeaserView = [[JASmallTeaserView alloc] initWithFrame:CGRectMake(scrollView.bounds.origin.x,
                                                                                                 yPosition,
                                                                                                 scrollView.bounds.size.width, 1)];
        [scrollView addSubview:smallTeaserView];
        smallTeaserView.teaserGrouping = teaserGrouping;
        [smallTeaserView load];
        
        yPosition += smallTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadNewsletterForInScrollView:(UIScrollView*)scrollView
                               xPosition:(CGFloat)xPosition
                               yPosition:(CGFloat)yPosition
                                   width:(CGFloat)width {
    if ([self.teaserGroupings objectForKey:@"form_newsletter"] && self.newsletterForm) {
        if (!self.newsletterTeaserView) {
            
            //height is set by the view itself
            self.newsletterTeaserView = [[JANewsletterTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
            [self.newsletterTeaserView setGenderPickerDelegate:self.genderPickerDelegate?:nil];
            [self.newsletterTeaserView setForm:self.newsletterForm];
        } else {
            [self.newsletterTeaserView setFrame:CGRectMake(xPosition, yPosition, width, self.newsletterTeaserView.height)];
        }
        if (self.newsletterTeaserView.superview != self.mainScrollView) {
            [scrollView addSubview:self.newsletterTeaserView];
        }
        yPosition += self.newsletterTeaserView.frame.size.height + 10.f;
    }
    return yPosition;
}

- (CGFloat)loadCampaignTeasersInScrollView:(UIScrollView*)scrollView xPosition:(CGFloat)xPosition yPosition:(CGFloat)yPosition width:(CGFloat)width {
    if ([self.teaserGroupings objectForKey:@"campaigns"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"campaigns"];
        
        //height is set by the view itself
        JACampaignsTeaserView* campaignsTeaserView = [[JACampaignsTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
        [scrollView addSubview:campaignsTeaserView];
        campaignsTeaserView.teaserGrouping = teaserGrouping;
        [campaignsTeaserView load];
        
        yPosition += campaignsTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadShopTeasersInScrollView:(UIScrollView*)scrollView xPosition:(CGFloat)xPosition yPosition:(CGFloat)yPosition width:(CGFloat)width {
    if ([self.teaserGroupings objectForKey:@"shop_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"shop_teasers"];
        
        //height is set by the view itself
        JAShopTeaserView* shopTeaserView = [[JAShopTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
        [scrollView addSubview:shopTeaserView];
        shopTeaserView.teaserGrouping = teaserGrouping;
        [shopTeaserView load];
        
        yPosition += shopTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadBrandTeasersInScrollView:(UIScrollView*)scrollView xPosition:(CGFloat)xPosition yPosition:(CGFloat)yPosition width:(CGFloat)width {
    if ([self.teaserGroupings objectForKey:@"brand_teasers"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"brand_teasers"];
        
        //height is set by the view itself
        JABrandTeaserView* brandTeaserView = [[JABrandTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
        [scrollView addSubview:brandTeaserView];
        brandTeaserView.teaserGrouping = teaserGrouping;
        [brandTeaserView load];
        
        yPosition += brandTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadShopsWeekTeasersInScrollView:(UIScrollView*)scrollView xPosition:(CGFloat)xPosition yPosition:(CGFloat)yPosition width:(CGFloat)width {
    if ([self.teaserGroupings objectForKey:@"shop_of_week"]) {
        RITeaserGrouping* teaserGrouping = [self.teaserGroupings objectForKey:@"shop_of_week"];
        
        //height is set by the view itself
        JAShopsWeekTeaserView* shopsWeekTeaserView = [[JAShopsWeekTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
        [scrollView addSubview:shopsWeekTeaserView];
        shopsWeekTeaserView.teaserGrouping = teaserGrouping;
        [shopsWeekTeaserView load];
        
        yPosition += shopsWeekTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (CGFloat)loadFeatureStoresTeasersInScrollView:(UIScrollView*)scrollView
                                      xPosition:(CGFloat)xPosition
                                      yPosition:(CGFloat)yPosition
                                          width:(CGFloat)width {
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
        
        //height is set by the view itself
        JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, 1)];
        [scrollView addSubview:topSellersTeaserView];
        topSellersTeaserView.teaserGrouping = teaserGrouping;
        [topSellersTeaserView load];
        
        yPosition += topSellersTeaserView.frame.size.height;
        
    }
    return yPosition;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    CGFloat yoffset = [UIScreen mainScreen].bounds.size.height - [self.mainScrollView convertPoint:CGPointMake(1, CGRectGetMaxY(self.mainScrollView.frame)) toView:nil].y;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height-yoffset, 0.0);
    self.mainScrollView.contentInset = contentInsets;
    self.mainScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.mainScrollView.contentInset = contentInsets;
    self.mainScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard
{
    [self endEditing:YES];
}

@end
