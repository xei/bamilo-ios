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

@end

@implementation JAMainTeaserView

- (void)load;
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.width * 47/128)]; //this 47/128 was defined by the design guidelines
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    CGFloat currentX = 0;
    
    for (RITeaserComponent* component in self.teaserGrouping.teaserComponents) {
        
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
    self.pageControl.numberOfPages = self.teaserGrouping.teaserComponents.count;
    [self addSubview:self.pageControl];
    self.pageControl.currentPage = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    self.pageControl.currentPage = (scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f;
    
}


@end
