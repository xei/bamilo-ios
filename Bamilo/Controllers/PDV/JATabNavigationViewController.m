//
//  JATabNavigationViewController.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabNavigationViewController.h"
#import "JAProductDescriptionView.h"
#import "JAProductSpecificationView.h"
#import "JAProductReviewsView.h"
#import "JATopTabsView.h"

@interface JATabNavigationViewController () <UIScrollViewDelegate, JATopTabsViewDelegate>

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) JATopTabsView* topTabsView;

@property (nonatomic) JAProductDescriptionView *descriptionView;
@property (nonatomic) JAProductSpecificationView *spectificationView;
@property (nonatomic) JAProductReviewsView *reviewsView;

@end

@implementation JATabNavigationViewController

- (JATopTabsView *)topTabsView {
    CGRect frame = CGRectMake(0, 0, self.view.width, kTabsHeight);
    if (!VALID_NOTEMPTY(_topTabsView, JATopTabsView)) {
        _topTabsView = [[JATopTabsView alloc] initWithFrame:frame];
        _topTabsView.delegate = self;
        NSArray* content;
        if (RI_IS_RTL) {
            content = @[STRING_REVIEWS_RATINGS, STRING_SPECIFICATIONS, STRING_DESCRIPTION];
        } else {
            content = @[STRING_DESCRIPTION, STRING_SPECIFICATIONS, STRING_REVIEWS_RATINGS];
        }
        
        _topTabsView.startingIndex = RI_IS_RTL ? self.tabScreenEnum - 2 : self.tabScreenEnum;
        [_topTabsView setupWithTabNames:content];

    } else {
        if (!CGRectEqualToRect(frame, _topTabsView.frame)) {
            [_topTabsView setFrame:frame];
        }
    }

    return _topTabsView;
}

- (UIScrollView *)contentScrollView {
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.topTabsView.frame), self.view.width, self.view.height - CGRectGetMaxY(self.topTabsView.frame));
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
            [self selectedIndex:self.topTabsView.selectedIndex animated:YES];
        }
    }
    return _contentScrollView;
}


- (JAProductDescriptionView *)descriptionView {
    CGRect frame;
    if(RI_IS_RTL){
        frame = CGRectMake(self.view.width*2, 0, self.view.width, self.contentScrollView.height);
    } else{
        frame = CGRectMake(0, 0, self.view.width, self.contentScrollView.height);
    }
    if (!VALID_NOTEMPTY(_descriptionView, JAProductDescriptionView)) {
        _descriptionView = [[JAProductDescriptionView alloc] initWithFrame:frame];
    } else {
        if (!CGRectEqualToRect(frame, _descriptionView.frame)) {
            [_descriptionView setFrame:frame];
        }
    }
    if (self.product && !_descriptionView.product) {
        _descriptionView.product = self.product;
    }
    return _descriptionView;
}

- (JAProductSpecificationView *)spectificationView {
    CGRect frame = CGRectMake(self.view.width, 0, self.view.width, self.contentScrollView.height);
    if (!_spectificationView) {
        _spectificationView = [[JAProductSpecificationView alloc] initWithFrame:frame];
    } else {
        if (!CGRectEqualToRect(frame, _spectificationView.frame)) {
            [_spectificationView setFrame:frame];
        }
    }
    if (self.product && !_spectificationView.product) {
        _spectificationView.product = self.product;
    }
    return _spectificationView;
}

- (JAProductReviewsView *)reviewsView {
    CGRect frame;
    
    if(RI_IS_RTL) {
        frame = CGRectMake(0, 0, self.view.width, self.contentScrollView.height);
    } else {
        frame = CGRectMake(self.view.width*2, 0, self.view.width, self.contentScrollView.height);
    }
    if (!VALID_NOTEMPTY(_reviewsView, JAProductReviewsView)) {
        _reviewsView = [[JAProductReviewsView alloc] initWithFrame:frame];
    } else {
        if (!CGRectEqualToRect(frame, _reviewsView.frame)) {
            [_reviewsView setFrame:frame];
        }
    }
    if (self.product && !_reviewsView.product) {
        _reviewsView.product = self.product;
    }
    return _reviewsView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.title = self.product.brand;
    
    [self.view addSubview:self.topTabsView];
    [self.view addSubview:self.contentScrollView];
}

- (void)scrollToX:(CGFloat)x
{
    if (CGPointEqualToPoint(CGPointMake(x, self.contentScrollView.contentOffset.y), self.contentScrollView.contentOffset)) {
        return;
    }
    [UIView animateWithDuration:.3 animations:^{
        [self.contentScrollView setContentOffset:CGPointMake(x, 0)];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
    self.topTabsView.selectedIndex = index;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self topTabsView];
    [self contentScrollView];
}

#pragma mark JATopTabsViewDelegate

- (void)selectedIndex:(NSInteger)index animated:(BOOL)animated;
{
    [self scrollToX:index*self.view.frame.size.width];
}

@end
