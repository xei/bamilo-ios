//
//  JAPickerScrollView.m
//  Jumia
//
//  Created by Telmo Pinto on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPickerScrollView.h"

#define JAPickerScrollViewCenterWidth 100.0f
#define JAPickerScrollViewBackgroundColor UIColorFromRGB(0xe3e3e3);
#define JAPickerScrollViewTextColor UIColorFromRGB(0x4e4e4e);
#define JAPickerScrollViewTextSize 13.0f
#define JAPickerScrollViewIndicatorImageName @"PickerScrollIndicator"


@interface JAPickerScrollView ()

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIImageView* arrowImageView;
@property (nonatomic, strong)NSArray* optionStrings;
@property (nonatomic, strong)NSArray* optionLabels;
@property (nonatomic, assign)NSInteger selectedIndex;

@end

@implementation JAPickerScrollView

- (void)setOptions:(NSArray*)options;
{
    self.optionStrings = options;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self.scrollView removeFromSuperview];
    [self.arrowImageView removeFromSuperview];
    
    self.backgroundColor = JAPickerScrollViewBackgroundColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.bounds.size.width - JAPickerScrollViewCenterWidth) / 2,
                                                                     self.bounds.origin.y,
                                                                     JAPickerScrollViewCenterWidth,
                                                                     self.bounds.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    NSMutableArray* tempArray = [NSMutableArray new];
    
    CGFloat currentWidth = 0;
    for (int i = 0; i < self.optionStrings.count; i++) {
        NSString* category = [self.optionStrings objectAtIndex:i];
        
        UILabel* newLabel = [[UILabel alloc] initWithFrame:CGRectMake(currentWidth,
                                                                      self.scrollView.frame.origin.y,
                                                                      self.scrollView.frame.size.width,
                                                                      self.scrollView.frame.size.height)];
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:JAPickerScrollViewTextSize];
        newLabel.textColor = JAPickerScrollViewTextColor;
        newLabel.text = category;
        newLabel.tag = i;
        [self.scrollView addSubview:newLabel];
        
        [tempArray addObject:newLabel];
        
        currentWidth += newLabel.frame.size.width;
    }
    
    self.optionLabels = [tempArray copy];
    
    [self.scrollView setContentSize:CGSizeMake(currentWidth,
                                               self.scrollView.frame.size.height)];
    
    [self selectLabelAtIndex:0];
    
    
    UIImage* indicatorImage = [UIImage imageNamed:JAPickerScrollViewIndicatorImageName];
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
    for (int i = 0; i < self.optionLabels.count; i++) {
        UILabel* label = [self.optionLabels objectAtIndex:i];
        
        if (i == index) {
            //select
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:JAPickerScrollViewTextSize];
        } else {
            //de-select
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:JAPickerScrollViewTextSize];
        }
    }
    
    self.selectedIndex = index;
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        [self.delegate selectedIndex:index];
    }
}

- (void)scrollLeft
{
    CGFloat newIndex = self.selectedIndex + 1;
    
    if (newIndex < self.optionLabels.count) {
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
    
    [self selectLabelAtIndex:(point.x/JAPickerScrollViewCenterWidth)];
}


@end
