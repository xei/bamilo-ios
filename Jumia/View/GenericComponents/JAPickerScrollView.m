//
//  JAPickerScrollView.m
//  Jumia
//
//  Created by Telmo Pinto on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPickerScrollView.h"
#import "JAGradientLayer.h"

#define JAPickerScrollViewBackgroundColor UIColorFromRGB(0xe3e3e3)
#define JAPickerScrollViewTextColor UIColorFromRGB(0x4e4e4e)
#define JAPickerScrollViewTextSize 13.0f
#define JAPickerScrollViewNormalFont [UIFont fontWithName:@"HelveticaNeue-Light" size:JAPickerScrollViewTextSize]
#define JAPickerScrollViewSelectedFont [UIFont fontWithName:@"HelveticaNeue" size:JAPickerScrollViewTextSize]
#define JAPickerScrollViewIndicatorImageName @"PickerScrollIndicator"
#define JAPickerScrollViewFadeWidth 30.0f

@interface JAPickerScrollView ()

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIImageView* arrowImageView;
@property (nonatomic, strong)UIView* leftFadeView;
@property (nonatomic, strong)UIView* rightFadeView;
@property (nonatomic, strong)NSArray* optionStrings;
@property (nonatomic, strong)NSArray* optionLabels;
@property (nonatomic, assign)NSInteger selectedIndex;
@property (nonatomic, assign)CGFloat maxWidth;

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
    [self.leftFadeView removeFromSuperview];
    [self.rightFadeView removeFromSuperview];
    
    self.disableDelagation = NO;
    self.maxWidth = 0.0f;
    
    self.backgroundColor = JAPickerScrollViewBackgroundColor;
    
    for(NSString *option in self.optionStrings)
    {
        CGRect optionRect = [option boundingRectWithSize:CGSizeMake(1000.0f, self.bounds.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:JAPickerScrollViewSelectedFont} context:nil];
        if(ceilf(optionRect.size.width) + 10.0f > self.maxWidth)
        {
            self.maxWidth = ceilf(optionRect.size.width) + 10.0f;
        }
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((self.bounds.size.width - self.maxWidth) / 2,
                                                                     self.bounds.origin.y,
                                                                     self.maxWidth,
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
        newLabel.font = JAPickerScrollViewNormalFont;
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
    
    if(self.startingIndex > 0) {
        self.selectedIndex = self.startingIndex-1;
        [self scrollLeftAnimated:NO];
    } else {
        [self selectLabelAtIndex:0];
    }
    
    UIImage* indicatorImage = [UIImage imageNamed:JAPickerScrollViewIndicatorImageName];
    self.arrowImageView = [[UIImageView alloc] initWithImage:indicatorImage];
    [self.arrowImageView setFrame:CGRectMake((self.bounds.size.width - indicatorImage.size.width) / 2,
                                             self.bounds.origin.y,
                                             indicatorImage.size.width,
                                             indicatorImage.size.height)];
    [self addSubview:self.arrowImageView];
    
    
    self.leftFadeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 JAPickerScrollViewFadeWidth,
                                                                 self.frame.size.height)];
    self.leftFadeView.backgroundColor = [UIColor clearColor];
    [self.leftFadeView.layer insertSublayer:[JAGradientLayer alphaGradient:JAPickerScrollViewBackgroundColor bounds:self.leftFadeView.bounds leftToRight:YES] atIndex:0];
    [self addSubview:self.leftFadeView];
    
    self.rightFadeView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - JAPickerScrollViewFadeWidth,
                                                                  0.0f,
                                                                  JAPickerScrollViewFadeWidth,
                                                                  self.frame.size.height)];
    self.rightFadeView.backgroundColor = [UIColor clearColor];
    [self.rightFadeView.layer insertSublayer:[JAGradientLayer alphaGradient:JAPickerScrollViewBackgroundColor bounds:self.rightFadeView.bounds leftToRight:NO] atIndex:0];
    [self addSubview:self.rightFadeView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(touchedInScrollView:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
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
    
    
    if (point.x < self.scrollView.frame.origin.x)
    {
        CGFloat distanceFromPointToCenterView = self.scrollView.frame.origin.x - point.x;
        NSInteger relativeIndex = (distanceFromPointToCenterView / self.scrollView.frame.size.width) + 1;
        while (relativeIndex > 0) {
            [self scrollRightAnimated:NO];
            relativeIndex--;
        }
    }
    else if (point.x > (self.scrollView.frame.origin.x + self.scrollView.frame.size.width))
    {
        CGFloat distanceFromPointToCenterView = point.x - self.scrollView.frame.origin.x - self.scrollView.frame.size.width;
        NSInteger relativeIndex = (distanceFromPointToCenterView / self.scrollView.frame.size.width) + 1;
        while (relativeIndex > 0) {
            [self scrollLeftAnimated:NO];
            relativeIndex--;
        }
    }
}

- (void)selectLabelAtIndex:(NSInteger)index
{
    for (int i = 0; i < self.optionLabels.count; i++) {
        UILabel* label = [self.optionLabels objectAtIndex:i];
        
        if (i == index) {
            //select
            label.font = JAPickerScrollViewSelectedFont;
        } else {
            //de-select
            label.font = JAPickerScrollViewNormalFont;
        }
    }
    
    self.selectedIndex = index;
    
    [self.leftFadeView setHidden:NO];
    [self.rightFadeView setHidden:NO];
    if(0 == self.selectedIndex)
    {
        [self.leftFadeView setHidden:YES];
    }
    else if(([self.optionLabels count] - 1) == self.selectedIndex)
    {
        [self.rightFadeView setHidden:YES];
    }
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        if (!self.disableDelagation) {
            [self.delegate selectedIndex:index];
        }
    }
}

- (void)scrollLeftAnimated:(BOOL)animated
{
    CGFloat newIndex = self.selectedIndex + 1;
    
    if (newIndex < self.optionLabels.count) {
        [self.scrollView scrollRectToVisible:CGRectMake(newIndex * self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.origin.y,
                                                        self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.size.height) animated:animated];
        [self selectLabelAtIndex:newIndex];
    }
}

- (void)scrollRightAnimated:(BOOL)animated;
{
    CGFloat newIndex = self.selectedIndex - 1;
    
    if (newIndex >= 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(newIndex * self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.origin.y,
                                                        self.scrollView.bounds.size.width,
                                                        self.scrollView.bounds.size.height) animated:animated];
        [self selectLabelAtIndex:newIndex];
    }
}

#pragma mark - Scrollview delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint point = *targetContentOffset;
    
    NSInteger index = (point.x/self.maxWidth);
    
    [self selectLabelAtIndex:index];
}


#pragma mark - Disable scroll

- (void)disableScroll
{
    self.scrollView.userInteractionEnabled = NO;
}

@end
