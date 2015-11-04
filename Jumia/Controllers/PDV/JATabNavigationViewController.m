//
//  JATabNavigationViewController.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabNavigationViewController.h"
#import "JATabButton.h"
#import "JAProductDescriptionView.h"
#import "JAProductSpecificationView.h"
#import "JAProductReviewsView.h"

@interface JATabNavigationViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic) JATabButton *descriptionTabButton;
@property (nonatomic) JATabButton *spectificationTabButton;
@property (nonatomic) JATabButton *reviewsTabButton;

@property (nonatomic) JAProductDescriptionView *descriptionView;
@property (nonatomic) JAProductSpecificationView *spectificationView;
@property (nonatomic) JAProductReviewsView *reviewsView;

@end

@implementation JATabNavigationViewController

@synthesize tabScreenEnum = _tabScreenEnum;

- (UIView *)tabBarView
{
    CGRect frame = CGRectMake(0, 0, self.view.width, kTabsHeight);
    if (!VALID_NOTEMPTY(_tabBarView, UIView)) {
        _tabBarView = [[UIView alloc] initWithFrame:frame];
        [_tabBarView addSubview:self.descriptionTabButton];
        [_tabBarView addSubview:self.spectificationTabButton];
        [_tabBarView addSubview:self.reviewsTabButton];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, _tabBarView.height-1, _tabBarView.width, 1)];
        [separator setBackgroundColor:JABlack300Color];
        [_tabBarView addSubview:separator];
        [self.descriptionTabButton setSelected:YES];
    }else{
        if (!CGRectEqualToRect(frame, _tabBarView.frame)) {
            [_tabBarView setFrame:frame];
            [self descriptionTabButton];
            [self spectificationTabButton];
            [self reviewsTabButton];
        }
    }
    return _tabBarView;
}

- (UIScrollView *)contentScrollView
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.tabBarView.frame), self.view.width, self.view.height - CGRectGetMaxY(self.tabBarView.frame));
    if (!VALID_NOTEMPTY(_contentScrollView, UIScrollView)) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
        [_contentScrollView setDelegate:self];
        [_contentScrollView addSubview:self.descriptionView];
        [_contentScrollView addSubview:self.spectificationView];
        [_contentScrollView addSubview:self.reviewsView];
        [self.reviewsView setViewControllerEvents:self];
        [_contentScrollView setPagingEnabled:YES];
        [_contentScrollView setShowsHorizontalScrollIndicator:NO];
        [_contentScrollView setContentSize:CGSizeMake(_contentScrollView.width*3, _contentScrollView.height)];
    }else{
        if (!CGRectEqualToRect(frame, _contentScrollView.frame)) {
            [_contentScrollView setFrame:frame];
            [self descriptionView];
            [self spectificationView];
            [self reviewsView];
            [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width*3, self.contentScrollView.height)];
            [self scrollToTabScreen:self.tabScreenEnum];
        }
    }
    return _contentScrollView;
}

- (JATabButton *)descriptionTabButton
{
    CGRect frame = CGRectMake(0, 0, self.view.width/3, kTabsHeight);
    if (!VALID_NOTEMPTY(_descriptionTabButton, JATabButton)) {
        _descriptionTabButton = [[JATabButton alloc] initWithFrame:frame];
#warning TODO String
        [_descriptionTabButton.titleButton setTitle:@"Description" forState:UIControlStateNormal];
        [_descriptionTabButton.titleButton addTarget:self action:@selector(goToDescription) forControlEvents:UIControlEventTouchUpInside];
    }else{
        if (!CGRectEqualToRect(frame, _descriptionTabButton.frame)) {
            [_descriptionTabButton setFrame:frame];
        }
    }
    return _descriptionTabButton;
}

- (JATabButton *)spectificationTabButton
{
    CGRect frame = CGRectMake(self.view.width/3, 0, self.view.width/3, kTabsHeight);
    if (!VALID_NOTEMPTY(_spectificationTabButton, JATabButton)) {
        _spectificationTabButton = [[JATabButton alloc] initWithFrame:frame];
#warning TODO String
        [_spectificationTabButton.titleButton setTitle:@"Specifications" forState:UIControlStateNormal];
        [_spectificationTabButton.titleButton addTarget:self action:@selector(goToSpecifications) forControlEvents:UIControlEventTouchUpInside];
    }else{
        if (!CGRectEqualToRect(frame, _spectificationTabButton.frame)) {
            [_spectificationTabButton setFrame:frame];
        }
    }
    return _spectificationTabButton;
}

- (JATabButton *)reviewsTabButton
{
    CGRect frame = CGRectMake(2*self.view.width/3, 0, self.view.width/3, kTabsHeight);
    if (!VALID_NOTEMPTY(_reviewsTabButton, JATabButton)) {
        _reviewsTabButton = [[JATabButton alloc] initWithFrame:frame];
#warning TODO String
        [_reviewsTabButton.titleButton setTitle:@"Ratings / Reviews" forState:UIControlStateNormal];
        [_reviewsTabButton.titleButton addTarget:self action:@selector(goToReviews) forControlEvents:UIControlEventTouchUpInside];
    }else{
        if (!CGRectEqualToRect(frame, _reviewsTabButton.frame)) {
            [_reviewsTabButton setFrame:frame];
        }
    }
    return _reviewsTabButton;
}

- (JAProductDescriptionView *)descriptionView
{
    CGRect frame = CGRectMake(0, 0, self.view.width, self.contentScrollView.height);
    if (!VALID_NOTEMPTY(_descriptionView, JAProductDescriptionView))
    {
        _descriptionView = [[JAProductDescriptionView alloc] initWithFrame:frame];
    }else{
        if (!CGRectEqualToRect(frame, _descriptionView.frame)) {
            [_descriptionView setFrame:frame];
        }
    }
    if (VALID_NOTEMPTY(self.product, RIProduct) && !VALID_NOTEMPTY(_descriptionView.product, RIProduct)) {
        _descriptionView.product = self.product;
    }
    return _descriptionView;
}

- (JAProductSpecificationView *)spectificationView
{
    CGRect frame = CGRectMake(self.view.width, 0, self.view.width, self.contentScrollView.height);
    if (!VALID_NOTEMPTY(_spectificationView, JAProductSpecificationView))
    {
        _spectificationView = [[JAProductSpecificationView alloc] initWithFrame:frame];
    }else{
        if (!CGRectEqualToRect(frame, _spectificationView.frame)) {
            [_spectificationView setFrame:frame];
        }
    }
    if (VALID_NOTEMPTY(self.product, RIProduct) && !VALID_NOTEMPTY(_spectificationView.product, RIProduct)) {
        _spectificationView.product = self.product;
    }
    return _spectificationView;
}

- (JAProductReviewsView *)reviewsView
{
    CGRect frame = CGRectMake(self.view.width*2, 0, self.view.width, self.contentScrollView.height);
    if (!VALID_NOTEMPTY(_reviewsView, JAProductReviewsView))
    {
        _reviewsView = [[JAProductReviewsView alloc] initWithFrame:frame];
    }else{
        if (!CGRectEqualToRect(frame, _reviewsView.frame)) {
            [_reviewsView setFrame:frame];
        }
    }
    if (VALID_NOTEMPTY(self.product, RIProduct) && !VALID_NOTEMPTY(_reviewsView.product, RIProduct)) {
        _reviewsView.product = self.product;
    }
    return _reviewsView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.title = self.product.brand;
    
    [self.view addSubview:self.tabBarView];
    [self.view addSubview:self.contentScrollView];
    
    if (self.tabScreenEnum) {
        [self scrollToTabScreen:self.tabScreenEnum];
    }
}

- (void)goToDescription
{
    [self scrollToX:self.descriptionView.x];
}

- (void)goToSpecifications
{
    [self scrollToX:self.spectificationView.x];
}

- (void)goToReviews
{
    [self scrollToX:self.reviewsView.x];
}

- (void)scrollToTabScreen:(JATabScreenEnum)tabScreen
{
    if (tabScreen == kTabScreenDescription) {
        [self scrollToX:self.descriptionView.x];
    }else if (tabScreen == kTabScreenSpecifications) {
        [self scrollToX:self.spectificationView.x];
    }else if (tabScreen == kTabScreenReviews) {
        [self scrollToX:self.reviewsView.x];
    }
}

- (void)scrollToX:(CGFloat)x
{
    if (CGPointEqualToPoint(CGPointMake(x, self.contentScrollView.contentOffset.y), self.contentScrollView.contentOffset)) {
        return;
    }
    [UIView animateWithDuration:.3 animations:^{
        [self.contentScrollView setContentOffset:CGPointMake(x, 0)];
        [self reloadTabs];
    }];
}

- (void)reloadTabs
{
    BOOL desc = NO, spec = NO, rev = NO;
    if (self.contentScrollView.contentOffset.x == self.descriptionView.x) {
        desc = YES;
        [self setTabScreenEnum:kTabScreenDescription];
    }else if (self.contentScrollView.contentOffset.x == self.spectificationView.x) {
        spec = YES;
        [self setTabScreenEnum:kTabScreenSpecifications];
    }else if (self.contentScrollView.contentOffset.x == self.reviewsView.x) {
        rev = YES;
        [self setTabScreenEnum:kTabScreenReviews];
    }
    [self.descriptionTabButton setSelected:desc];
    [self.spectificationTabButton setSelected:spec];
    [self.reviewsTabButton setSelected:rev];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadTabs];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self tabBarView];
    [self contentScrollView];
}

@end
