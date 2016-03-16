//
//  JATopTabsView.m
//  Jumia
//
//  Created by telmopinto on 15/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JATopTabsView.h"
#import "JATabButton.h"

@interface JATopTabsView ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* tabButtonsArray;

@end


@implementation JATopTabsView

- (BOOL)isLoaded
{
    return VALID_NOTEMPTY(self.tabButtonsArray, NSArray);
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    for (int i = 0; i < self.tabButtonsArray.count; i++) {
        JATabButton* tabButton = [self.tabButtonsArray objectAtIndex:i];
        if (_selectedIndex == i) {
            [tabButton setSelected:YES];
            [self.scrollView scrollRectToVisible:tabButton.frame animated:YES];
        } else {
            [tabButton setSelected:NO];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        [self.delegate selectedIndex:_selectedIndex];
    }
}

- (void)setSelectedIndexWithStartingIndex
{
    _selectedIndex = self.startingIndex;
    for (int i = 0; i < self.tabButtonsArray.count; i++) {
        JATabButton* tabButton = [self.tabButtonsArray objectAtIndex:i];
        if (_selectedIndex == i) {
            [tabButton setSelected:YES];
            [self.scrollView scrollRectToVisible:tabButton.frame animated:NO]; //DON'T ANIMATE
        } else {
            [tabButton setSelected:NO];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        [self.delegate selectedIndex:_selectedIndex];
    }
}

- (UIScrollView*)scrollView
{
    if (!VALID_NOTEMPTY(_scrollView, UIScrollView)) {
        _scrollView = [UIScrollView new];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setBackgroundColor:JAWhiteColor];
        [_scrollView setFrame:self.bounds];
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (void)setupWithTabNames:(NSArray*)tabNamesArray
{
    CGFloat currentX = 0.0f;
    
    NSMutableArray* tabButtonsMutableArray = [NSMutableArray new];
    for (int i = 0; i < tabNamesArray.count; i++) {
        NSString* tabName = [tabNamesArray objectAtIndex:i];
        
        JATabButton* tabButton = [[JATabButton alloc] init];
        [tabButton.titleButton setTitle:tabName forState:UIControlStateNormal];
        UILabel* label = [UILabel new];
        [label setFont:tabButton.titleButton.titleLabel.font];
        [label setText:tabName];
        [label sizeToFit];
        CGFloat minLabel = MAX(label.frame.size.width + 10.0f, 106.0f);
        [tabButton setFrame:CGRectMake(currentX, 0.0f, minLabel, self.frame.size.height)];
        
        tabButton.titleButton.tag = i;
        [tabButton.titleButton addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [tabButtonsMutableArray addObject:tabButton];
        [self.scrollView addSubview:tabButton];
        
        currentX += tabButton.frame.size.width;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
    
    self.tabButtonsArray = [tabButtonsMutableArray copy];
    
    [self setSelectedIndexWithStartingIndex];
}


- (void)scrollLeft;
{
    if (self.selectedIndex < self.tabButtonsArray.count - 1) {
        self.selectedIndex++;
    }
}

- (void)scrollRight;
{
    if (self.selectedIndex > 0) {
        self.selectedIndex--;
    }
}

- (void)tabPressed:(UIControl*)sender
{
    self.selectedIndex = sender.tag;
}

@end
