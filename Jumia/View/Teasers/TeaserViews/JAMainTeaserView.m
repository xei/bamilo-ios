//
//  JAMainTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainTeaserView.h"
#import "JAClickableView.h"
#import "JAPageControl.h"

@interface JAMainTeaserView()
{
    NSMutableArray *_teasersArray;
}

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)JAPageControl* pageControl;
@property (nonatomic, assign)BOOL isInfinite;

@end

@implementation JAMainTeaserView

- (NSInteger)currentPage
{
    return self.pageControl.currentPage;
}

- (void)load;
{
    [super load];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.isInfinite = YES;
    }
    CGFloat ratio = 261.0f/640.0f; //this 261.0f/640.0f was defined by the design guidelines
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.width * ratio)];
    
    CGFloat scrollViewWidth = self.bounds.size.width;
    CGFloat scrollViewHeight = self.bounds.size.height;
    CGFloat scrollViewX = self.bounds.origin.x;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        scrollViewWidth = 640.0f; //value by design
        scrollViewHeight = scrollViewWidth * ratio;
        scrollViewX = (self.bounds.size.width - scrollViewWidth) / 2;
        
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewX,
                                                                     self.bounds.origin.y,
                                                                     scrollViewWidth,
                                                                     scrollViewHeight)];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              scrollViewHeight)];
    
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchedInScrollView:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
    CGFloat currentX = 0;
    
    _teasersArray = [NSMutableArray new];
    
    for (int i = 0; i < self.teaserGrouping.teaserComponents.count; i++) {
        RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
        
        NSString* imageUrl;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            imageUrl = component.imageLandscapeUrl;
        } else {
            imageUrl = component.imagePortraitUrl;
        }
        
        if (VALID_NOTEMPTY(imageUrl, NSString)) {
            [_teasersArray addObject:component];
        }
    }
    
    self.validTeaserComponents = [_teasersArray copy];
    
    if (self.isInfinite && 2 < _teasersArray.count) {
        [_teasersArray addObject:[_teasersArray firstObject]];
        [_teasersArray insertObject:[_teasersArray objectAtIndex:_teasersArray.count-2] atIndex:0];
    }
    
    for (int i = RI_IS_RTL?(int)_teasersArray.count-1:0;
         RI_IS_RTL?i >=0 :i < _teasersArray.count;
         RI_IS_RTL? i-- : i++) {
        RITeaserComponent* component = [_teasersArray objectAtIndex:i];
        
        NSString* imageUrl;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            imageUrl = component.imageLandscapeUrl;
        } else {
            imageUrl = component.imagePortraitUrl;
        }
        
        if (VALID_NOTEMPTY(imageUrl, NSString)) {
            
            JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                               self.scrollView.bounds.origin.y,
                                                                                               self.scrollView.bounds.size.width,
                                                                                               self.scrollView.bounds.size.height)];
            NSInteger realIndex = i;
            if (self.isInfinite && 1 < self.teaserGrouping.teaserComponents.count) {
                if (0 == i) {
                    //notice we are using self.teaserGrouping.teaserComponents.count-1 and not componentsArray.count-1
                    //looking at the REAL array count, not the fake one's.
                    realIndex = self.teaserGrouping.teaserComponents.count-1;
                } else if (_teasersArray.count-1 == i){
                    realIndex = 0;
                } else {
                    realIndex = i-1;
                }
            }
            clickableView.tag = realIndex;
            [clickableView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:clickableView];
            
            currentX += clickableView.frame.size.width;
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];

    CGFloat pageControlBottomMargin = 3.0f; //value by design
    CGFloat pageControlHeight = 10.0f;
    [self.pageControl removeFromSuperview];
    self.pageControl = [[JAPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                       self.bounds.size.height - pageControlBottomMargin - pageControlHeight,
                                                                       self.bounds.size.width,
                                                                       pageControlHeight)];
    self.pageControl.hasSmallDots = YES;
    self.pageControl.numberOfPages = (self.isInfinite && 2 < _teasersArray.count)?_teasersArray.count-2:_teasersArray.count;
    [self addSubview:self.pageControl];
    
    [self scrollToIndex:RI_IS_RTL?((self.isInfinite && 2 < _teasersArray.count)?_teasersArray.count-2:_teasersArray.count):0];
}


#pragma mark - Scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.isInfinite && 2 < _teasersArray.count) {
        
        if (scrollView.contentOffset.x == self.scrollView.contentSize.width - self.scrollView.frame.size.width) {
            
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.bounds.size.width,
                                                            self.scrollView.bounds.origin.y,
                                                            self.scrollView.bounds.size.width,
                                                            self.scrollView.bounds.size.height)
                                              animated:NO];
            
        }
        else if (scrollView.contentOffset.x == 0)
        {
            [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentSize.width - (2*self.scrollView.frame.size.width),
                                                            self.scrollView.bounds.origin.y,
                                                            self.scrollView.bounds.size.width,
                                                            self.scrollView.bounds.size.height)
                                        animated:NO];
        }
    }
    self.pageControl.currentPage = [self getCurrentPage:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = [self getCurrentPage:scrollView];
}

- (NSInteger)getCurrentPage:(UIScrollView *)scrollView
{
    CGFloat infinityOffset = 0.0f;
    if (self.isInfinite && 2 < _teasersArray.count) {
        //subtract 1 to make up for the fake image offset (fake images that are used for infinite scrolling)
        infinityOffset = 1.0f;
    }
    
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    NSInteger page = (scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f - infinityOffset;
    return page;
}

- (CGRect)getVisibleRectToPage:(NSInteger)page
{
    return CGRectMake(self.scrollView.contentSize.width - (self.scrollView.frame.size.width * 2),
               self.scrollView.bounds.origin.y,
               self.scrollView.bounds.size.width,
               self.scrollView.bounds.size.height);
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event])
    {
        return self.scrollView;
    }
    return nil;
}

- (void)touchedInScrollView:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    if (point.x > self.scrollView.frame.origin.x && point.x < (self.scrollView.frame.origin.x + self.scrollView.frame.size.width))
    {
        NSInteger page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
        if (self.isInfinite && 2 < _teasersArray.count) {
            page--;
        }
        if (RI_IS_RTL) {
            page = _teasersArray.count-1 - ((self.isInfinite && 2 < _teasersArray.count)?2:0) - page;
        }
        [self teaserPressedForIndex:page];
    }
}

- (void)scrollToIndex:(NSInteger)index
{
    self.pageControl.currentPage = index;
    //adjust index to the infinite scroll
    if (self.isInfinite && 2 < _teasersArray.count) {
        index++;
        if (index > _teasersArray.count-1) {
            index = 0;
        }
    }
    CGRect scrollViewRect = CGRectMake(self.scrollView.frame.size.width*index,
                                       self.scrollView.frame.origin.y,
                                       self.scrollView.frame.size.width,
                                       self.scrollView.frame.size.height);
    [self.scrollView scrollRectToVisible:scrollViewRect animated:NO];
    
}

@end
