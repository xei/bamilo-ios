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

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)JAPageControl* pageControl;
@property (nonatomic, strong)NSArray* buttonsArray;

@end

@implementation JAMainTeaserView

- (void)load;
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.width * 47/128)]; //this 47/128 was defined by the design guidelines
    
    CGFloat scrollViewWidth = self.bounds.size.width;
    CGFloat scrollViewX = self.bounds.origin.x;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        scrollViewWidth = 640.0f; //value by design
        scrollViewX = (self.bounds.size.width - scrollViewWidth) / 2;
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewX,
                                                                     self.bounds.origin.y,
                                                                     scrollViewWidth,
                                                                     self.bounds.size.height)];
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
    
    NSMutableArray* buttonsMutableArray = [NSMutableArray new];
    for (int i = 0; i < self.teaserGrouping.teaserComponents.count; i++) {
        RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
        
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
            clickableView.tag = i;
            [clickableView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:clickableView];
            
            [buttonsMutableArray addObject:clickableView];
            
            currentX += clickableView.frame.size.width;
        }
    }
    self.buttonsArray = [buttonsMutableArray copy];
    
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
    self.pageControl.numberOfPages = self.teaserGrouping.teaserComponents.count;
    [self addSubview:self.pageControl];
    self.pageControl.currentPage = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    self.pageControl.currentPage = (scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f;
    
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
        [self teaserPressedForIndex:page];
    }
}

@end
