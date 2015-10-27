//
//  JAScrolledImageGallery.m
//  Jumia
//
//  Created by josemota on 9/22/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAScrolledImageGalleryView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JAScrolledImageGalleryView () <UIScrollViewDelegate> {
    UIScrollView *_pageComponentView;
    BOOL _first, _tap;
    NSMutableArray *_processedViews;
    SelectPageBlock _selectPageBlock;
    id _target;
    SEL _selector;
    id _imageClickedTarget;
    SEL _imageClickedSelector;
    NSArray *_urlImages;
    CGFloat _scrollAnimation;
    CGFloat _imageWidth;
    CGFloat _imageHeight;
}

@property (nonatomic) UIScrollView *scrollView;

@end

@implementation JAScrolledImageGalleryView

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
    if (_infinite)
        _selectedIndexPage = 1;
    else
        _selectedIndexPage = 0;
    
    _infinite = NO;
    _first = NO;
    _navigationCursorBottomPercentage = .05;
    
    [self setDimensions];
}

- (void)setDimensions
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _imageWidth = 322;
        _imageHeight = 402;
    }else{
        _imageWidth = 272;
        _imageHeight = 340;
    }
}

- (UIScrollView *)scrollView
{
    if (!VALID_NOTEMPTY(_scrollView, UIScrollView)) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, _imageHeight + 25)];
        _scrollView.delegate = self;
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setViews:(NSArray *)views
{
    _urlImages = views;
    NSMutableArray *validViews = [NSMutableArray new];
    if (VALID_NOTEMPTY(views, NSArray)) {
        for (NSString *urlImage in views) {
            [validViews addObject:[self getImageViewForImageUrl:urlImage]];
        }
    }else{
        JAClickableView* imageView = [[JAClickableView alloc] init];
        [imageView setFrame:CGRectMake(0, 0, _imageWidth, _imageHeight)];
        [imageView setImage:[UIImage imageNamed:@"placeholder_pdv"] forState:UIControlStateNormal];
        [validViews addObject:imageView];
    }
    
    if (_infinite && validViews.count > 1) {
        [validViews addObject:[self getImageViewForImageUrl:[_urlImages firstObject]]];
        [validViews insertObject:[self getImageViewForImageUrl:[_urlImages lastObject]] atIndex:0];
    }
    _views = [validViews copy];
    [self loadViews];
}

- (JAClickableView *)getImageViewForImageUrl:(NSString *)imageURL
{
    JAClickableView* imageView = [[JAClickableView alloc] init];
    [imageView setFrame:CGRectMake(0, 0, _imageWidth, _imageHeight)];
    [imageView setImage:[UIImage imageNamed:@"placeholder_pdv"] forState:UIControlStateNormal];
    [imageView setX:self.width/2-imageView.width/2];
    [imageView addTarget:self action:@selector(sendImageClickEvent) forControlEvents:UIControlEventTouchUpInside];

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error || ((NSHTTPURLResponse *) response).statusCode != 200) {
            return;
        }
        [imageView setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }];
    return imageView;
}

- (void)loadViews
{
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!_views || [_views count] == 0) {
        return;
    }
    _processedViews = [_views mutableCopy];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.width*[_processedViews count], self.scrollView.height)];
    int j = 0;
    NSMutableArray* modifiedArray = [NSMutableArray new];
    for (int i = RI_IS_RTL?(int)[_processedViews count]-1:0;RI_IS_RTL?i>=0:i<=([_processedViews count]-1);RI_IS_RTL?i--:i++) {
        UIView *view = [_processedViews objectAtIndex:i];
        [view setX:(self.scrollView.width - view.width)/2];
        [view setWidth:_imageWidth];
        [view setHeight:_imageHeight];
        UIView *baseView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        [baseView setBackgroundColor:[UIColor whiteColor]];
        [baseView addSubview:view];
        [baseView setX:j*self.scrollView.width];
        [baseView setY:0];
        [baseView setTag:i];
        [modifiedArray addObject:baseView];
        [self.scrollView addSubview:baseView];
        j++;
        
    }
    _processedViews = [modifiedArray copy];
    if (_processedViews.count > 1) {
        [self loadPageComponent];
    }
    if (!_first) {
        [self scrollToTag:_infinite?1:0];
    }else{
        _scrollAnimation = 0;
        [self scrollToTag:_selectedIndexPage];
    }
    _first = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.scrollView setWidth:self.width];
    [self.scrollView setHeight:_imageHeight];
    if (_first) {
        [self setDimensions];
        for (UIView *subview in self.scrollView.subviews) {
            [subview removeFromSuperview];
        }
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
    
    _pageComponentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (_infinite?numberOfViews-1:numberOfViews)*48 + (numberOfViews-1)*6, 48)];
    [_pageComponentView setShowsHorizontalScrollIndicator:NO];
    
    if (_pageComponentView.width > self.width) {
        _pageComponentView.x = 0;
        [_pageComponentView setContentSize:CGSizeMake(_pageComponentView.width, _pageComponentView.contentSize.height)];
        [_pageComponentView setWidth:self.width];
        
    }else{
        [_pageComponentView setX:self.width/2-_pageComponentView.width/2];
    }
    [self addSubview:_pageComponentView];
    [_pageComponentView setYBottomAligned:10];
    
    int j= _infinite?1:0;
    for (; RI_IS_RTL?i>=_infinite?1:0:i<=numberOfViews-1; RI_IS_RTL?i--:i++) {
        
        JAClickableView *clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        UIImageView *smallImage = [[UIImageView alloc] init];
        [smallImage setFrame:CGRectMake(0, 0, 48, 48)];
        [smallImage setImageWithURL:[NSURL URLWithString:[_urlImages objectAtIndex:_infinite?i-1:i]] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [smallImage setX:3+(_infinite?j-1:j)*54];
        smallImage.tag = i;
        clickView.tag = i;
        [smallImage.layer setBorderWidth:.5];
        [smallImage.layer setBorderColor:UIColorFromRGB(0x202020).CGColor];
        [smallImage setUserInteractionEnabled:YES];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSmallImage:)];
        [smallImage addGestureRecognizer:recognizer];
        [_pageComponentView addSubview:smallImage];
        
        j++;
    }
    [self reloadPageComponent];
}

- (void)tapSmallImage:(UIGestureRecognizer *)gesture
{
    _tap = YES;
    [self scrollToTag:gesture.view.tag];
}

- (void)reloadPageComponent
{
    for (UIImageView *view in _pageComponentView.subviews)
    {
        if (_selectedIndexPage == view.tag) {
            CGFloat scrollOffset = view.x + view.width/2 - self.width/2;
            if (scrollOffset < 0 || self.width > _pageComponentView.contentSize.width) {
                scrollOffset = 0;
            }else if (_pageComponentView.contentSize.width - scrollOffset < self.width)
            {
                scrollOffset = _pageComponentView.contentSize.width - self.width;
            }
            [UIView animateWithDuration:.2 animations:^{
                [_pageComponentView setContentOffset:CGPointMake(scrollOffset, _pageComponentView.contentOffset.y)];
            }];
            [view.layer setBorderColor:UIColorFromRGB(0xf68b1e).CGColor];
        }else
            [view.layer setBorderColor:UIColorFromRGB(0x202020).CGColor];
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
    if (!_tap) {
        [self.scrollView setContentOffset:CGPointMake([self getViewWithTag:_selectedIndexPage].x, 0)];
        [self reloadPageComponent];
    }else{
        [UIView animateWithDuration:_scrollAnimation animations:^{
            [self.scrollView setContentOffset:CGPointMake([self getViewWithTag:_selectedIndexPage].x, 0)];
            [self reloadPageComponent];
        }];
    }
    _scrollAnimation = .3f;
    _tap = NO;
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
        _scrollAnimation = 0;
        [self setSelectedIndexPage:[_processedViews count]-2];
    }else if (_infinite && _selectedIndexPage >= [_processedViews count]-1) {
        _scrollAnimation = 0;
        [self setSelectedIndexPage:1];
    }else{
        [self reloadPageComponent];
        [self sendEvent];
    }
}

- (NSInteger)getVisibleViewNumber
{
    for (UIView *view in _processedViews) {
        if (view.x == self.scrollView.contentOffset.x) {
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
    _target = target;
    _selector = selector;
}

- (void)addImageClickedTarget:(id)target selector:(SEL)selector
{
    _imageClickedTarget = target;
    _imageClickedSelector = selector;
}

- (void)sendEvent
{
    if (_selectPageBlock) {
        _selectPageBlock(_selectedIndexPage);
    }
    if (_target && _selector) {
        ((void (*)(id, SEL))[_target methodForSelector:_selector])(_target, _selector);
    }
}

- (void)sendImageClickEvent
{
    if (_imageClickedTarget && _imageClickedSelector) {
        ((void (*)(id, SEL))[_imageClickedTarget methodForSelector:_imageClickedSelector])(_imageClickedTarget, _imageClickedSelector);
    }
}

@end
