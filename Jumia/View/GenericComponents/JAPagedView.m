//
//  JAPagedScrollView.m
//  testing
//
//  Created by josemota on 6/9/15.
//  Copyright (c) 2015 josemota. All rights reserved.
//

#import "JAPagedView.h"

//#define kPointSize 10
//#define kPointDistanceBetween 5

@interface JAPagedView () <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    UIView *_pageComponentView;
    BOOL _first;
    NSMutableArray *_processedViews;
    SelectPageBlock _selectPageBlock;
    id _targetSelector;
    SEL _selector;
}

@end

@implementation JAPagedView

@synthesize views = _views, selectedIndexPage = _selectedIndexPage, navigationCursorBottomPercentage = _navigationCursorBottomPercentage;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _scrollView.delegate = self;
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [self addSubview:_scrollView];
    
    if (_infinite)
        _selectedIndexPage = 1;
    else
        _selectedIndexPage = 0;
    
    _infinite = NO;
    _first = NO;
    _navigationCursorBottomPercentage = .05;
    
}

- (void)setViews:(NSArray *)views
{
    NSMutableArray *validViews = [NSMutableArray new];
    for (id view in views) {
        if ([view isKindOfClass:[UIView class]]) {
            [validViews addObject:view];
        }
    }
    _views = [validViews copy];
    [self loadViews];
}

- (void)loadViews
{
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!_views || [_views count] == 0) {
        return;
    }
    _processedViews = [_views mutableCopy];
    if (_infinite && _processedViews.count > 1) {
        /*
         http://stackoverflow.com/questions/15351231/duplicate-existing-uiview-in-a-scrollview-programmatically-storyboard
         It probably doesn't archive/unarchive "everything" (or I probably should RTFM) because for example it doesn't "bring back" the UIView in the same "configuration" I archived it. I have a CAGradientLayer among other things and it seems to me the "newView" (or archivedData) has the View being fully Opaque.
         */
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: [_processedViews firstObject]];
        UIView *firstView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        archivedData = [NSKeyedArchiver archivedDataWithRootObject: [_processedViews lastObject]];
        UIView *lastView = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
        
        [_processedViews addObject:firstView];
        [_processedViews insertObject:lastView atIndex:0];
    }
    [_scrollView setContentSize:CGSizeMake(self.width*[_processedViews count], self.height)];
    int j = 0;
    NSMutableArray* modifiedArray = [NSMutableArray new];
    for (int i = RI_IS_RTL?(int)[_processedViews count]-1:0;RI_IS_RTL?i>=0:i<=([_processedViews count]-1);RI_IS_RTL?i--:i++) {
        UIView *view = [_processedViews objectAtIndex:i];
        UIView *baseView = [[UIView alloc] initWithFrame:_scrollView.frame];
        [baseView addSubview:view];
        [baseView setX:j*self.width];
        [baseView setY:0];
        [baseView setTag:i];
        [modifiedArray addObject:baseView];
        [_scrollView addSubview:baseView];
        j++;
        
    }
    _processedViews = [modifiedArray copy];
    if (_processedViews.count > 1) {
        [self loadPageComponent];
    }
    if (!_first) {
        [self scrollToTag:_infinite?1:0];
    }
    _first = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_scrollView setWidth:self.width];
    [_scrollView setHeight:self.height];
    if (_processedViews) {
        [self loadViews];
    }
}

- (void)loadPageComponent
{
    [_pageComponentView removeFromSuperview];
    NSUInteger numberOfViews = [_processedViews count];
    int i = RI_IS_RTL?(int)numberOfViews-1:0;
    if (_infinite) {
        numberOfViews = [_processedViews count] - 1;
        i = RI_IS_RTL?((int)numberOfViews-1):1;
    }
    
    NSString* imageIndicatorString = @"image_indicator";
    if (self.hasSmallDots) {
        imageIndicatorString = @"small_image_indicator";
    }
    UIImage *dotImageTemp = [UIImage imageNamed:imageIndicatorString];
    CGFloat dotImageWidth = [dotImageTemp size].width;
    
    _pageComponentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (_infinite?numberOfViews-1:numberOfViews)*(dotImageWidth), dotImageWidth)];
    [_pageComponentView setX:self.width/2-_pageComponentView.width/2];
    [self addSubview:_pageComponentView];
    [_pageComponentView setYBottomAligned:self.height*_navigationCursorBottomPercentage];
    
    int j= _infinite?1:0;
    for (; RI_IS_RTL?i>=_infinite?1:0:i<=numberOfViews-1; RI_IS_RTL?i--:i++) {
        
        if (_selectedIndexPage == i) {
            imageIndicatorString = [imageIndicatorString stringByAppendingString:@"_selected"];
        }
        UIImage *dotImage = [UIImage imageNamed:imageIndicatorString];
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:dotImage];
        [dotImageView setWidth:[dotImage size].width];
        [dotImageView setHeight:dotImageWidth];
        [dotImageView setX:(_infinite?j-1:j)*(dotImageWidth)];
        dotImageView.tag = i;
        [_pageComponentView addSubview:dotImageView];
        
        j++;
    }
}

- (void)reloadPageComponent
{
    for (UIImageView *view in _pageComponentView.subviews)
    {
        NSString* imageIndicatorString = @"image_indicator";
        if (self.hasSmallDots) {
            imageIndicatorString = @"small_image_indicator";
        }
        if (_selectedIndexPage == view.tag) {
            imageIndicatorString = [imageIndicatorString stringByAppendingString:@"_selected"];
        }
        UIImage *dotImage = [UIImage imageNamed:imageIndicatorString];
        [view setImage:dotImage];
    }
}

- (void)setSelectedIndexPage:(NSInteger)selectedPage
{
    _selectedIndexPage = selectedPage;
    NSUInteger numberOfViews = [_processedViews count];
    if (_infinite) {
        numberOfViews = [_processedViews count];
    }
    [self sendEvent];
    [_scrollView setContentOffset:CGPointMake([self getViewWithTag:_selectedIndexPage].x, 0)];
    [self reloadPageComponent];
}

- (NSInteger)selectedIndexPage
{
    return _selectedIndexPage;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger newPage = [self getVisibleViewNumber];
    if (newPage == _selectedIndexPage) {
        return;
    }
    _selectedIndexPage = newPage;
    if (_infinite && _selectedIndexPage < 1) {
        [self setSelectedIndexPage:[_processedViews count]-2];
    }else if (_infinite && _selectedIndexPage >= [_processedViews count]-1) {
        [self setSelectedIndexPage:1];
    }else{
        [self reloadPageComponent];
        [self sendEvent];
    }
}

- (NSInteger)getVisibleViewNumber
{
    for (UIView *view in _processedViews) {
        if (view.x == _scrollView.contentOffset.x) {
            return view.tag;
        }
    }
    return -1;
}

- (UIView *)getViewWithTag:(NSInteger)tag
{
    for (UIView *view in _processedViews) {
        if (view.tag == tag) {
            return view;
        }
    }
    return nil;
}

- (void)scrollToTag:(NSInteger)tag
{
    [self setSelectedIndexPage:tag];
}

- (void)setInfinite:(BOOL)infinite
{
    _infinite = infinite;
    if (_processedViews) {
        [self loadViews];
        [self reloadPageComponent];
    }
}

- (void)getPageChanged:(SelectPageBlock)page
{
    _selectPageBlock = page;
}

- (void)getPageChangedTarget:(id)target selector:(SEL)selector
{
    _targetSelector = target;
    _selector = selector;
}

- (void)sendEvent
{
    if (_selectPageBlock) {
        _selectPageBlock(_selectedIndexPage);
    }
    if (_targetSelector && _selector) {
        ((void (*)(id, SEL))[_targetSelector methodForSelector:_selector])(_targetSelector, _selector);
    }
}

@end
