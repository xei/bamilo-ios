//
//  JATeaserCategoryScrollView.m
//  Jumia
//
//  Created by Telmo Pinto on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserCategoryScrollView.h"

#define JATeaserCategoryScrollViewCenterWidth 100.0f
#define JATeaserCategoryScrollViewBackgroundColor UIColorFromRGB(0xe3e3e3);
#define JATeaserCategoryScrollViewTextColor UIColorFromRGB(0x4e4e4e);
#define JATeaserCategoryScrollViewTextSize 10.0f
#define JATeaserCategoryScrollViewIndicatorImageName @"TeaserCategoryScrollIndicator"


@interface JATeaserCategoryScrollView ()

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIImageView* arrowImageView;
@property (nonatomic, strong)NSArray* teaserCategoryLabels;
@property (nonatomic, assign)NSInteger selectedIndex;

@end

@implementation JATeaserCategoryScrollView

- (void)setCategories:(NSArray*)teaserCategories
{
    self.backgroundColor = JATeaserCategoryScrollViewBackgroundColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.bounds.size.width - JATeaserCategoryScrollViewCenterWidth) / 2,
                                                                     self.bounds.origin.y,
                                                                     JATeaserCategoryScrollViewCenterWidth,
                                                                     self.bounds.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    NSMutableArray* tempArray = [NSMutableArray new];
    
    CGFloat currentWidth = 0;
    for (int i = 0; i < teaserCategories.count; i++) {
        NSString* category = [teaserCategories objectAtIndex:i];
        
        UILabel* newLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentWidth,
                                                                      self.scrollView.frame.origin.y,
                                                                      self.scrollView.frame.size.width,
                                                                      self.scrollView.frame.size.height)];
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:JATeaserCategoryScrollViewTextSize];
        newLabel.textColor = JATeaserCategoryScrollViewTextColor;
        newLabel.text = category;
        newLabel.tag = i;
        [self.scrollView addSubview:newLabel];
        
        [tempArray addObject:newLabel];
        
        currentWidth += newLabel.frame.size.width;
    }
    
    self.teaserCategoryLabels = [tempArray copy];
    
    [self.scrollView setContentSize:CGSizeMake(currentWidth,
                                               self.scrollView.frame.size.height)];
    
    [self selectLabelAtIndex:0];
    
    
    UIImage* indicatorImage = [UIImage imageNamed:JATeaserCategoryScrollViewIndicatorImageName];
    self.arrowImageView = [[UIImageView alloc] initWithImage:indicatorImage];
    [self.arrowImageView setFrame:CGRectMake((self.bounds.size.width - indicatorImage.size.width) / 2,
                                             self.bounds.origin.y,
                                             indicatorImage.size.width,
                                             indicatorImage.size.height)];
    [self addSubview:self.arrowImageView];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self.scrollView;
    }
    return nil;
}

- (void)selectLabelAtIndex:(NSInteger)index
{
    for (int i = 0; i < self.teaserCategoryLabels.count; i++) {
        UILabel* label = [self.teaserCategoryLabels objectAtIndex:i];
        
        if (i == index) {
            //select
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:JATeaserCategoryScrollViewTextSize];
        } else {
            //de-select
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:JATeaserCategoryScrollViewTextSize];
        }
    }
    
    self.selectedIndex = index;
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(teaserCategorySelectedAtIndex:)]) {
        [self.delegate teaserCategorySelectedAtIndex:index];
    }
}

- (void)scrollLeft
{
    CGFloat newIndex = self.selectedIndex + 1;
    
    if (newIndex < self.teaserCategoryLabels.count) {
        [self.scrollView scrollRectToVisible:CGRectMake(newIndex * self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.origin.y,
                                                        self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.size.height) animated:YES];
        [self selectLabelAtIndex:newIndex];
    }
}

- (void)scrollRight
{
    CGFloat newIndex = self.selectedIndex - 1;
    
    if (newIndex >= 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(newIndex * self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.origin.y,
                                                        self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.size.height) animated:YES];
        [self selectLabelAtIndex:newIndex];
    }
}

#pragma mark - Scrollview delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint point = *targetContentOffset;
    
    [self selectLabelAtIndex:(point.x/JATeaserCategoryScrollViewCenterWidth)];
}


@end
