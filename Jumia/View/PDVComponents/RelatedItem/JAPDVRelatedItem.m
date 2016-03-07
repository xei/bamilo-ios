//
//  JAPDVRelatedItem.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVRelatedItem.h"
#import "JAProductInfoHeaderLine.h"

@interface JAPDVRelatedItem ()
{
    CGSize _lastItemSize;
}

@property (nonatomic) JAProductInfoHeaderLine *topLabel;
@property (nonatomic) NSMutableArray *viewsArray;
@property (nonatomic) NSMutableArray *verticalSeparators;
@property (nonatomic) NSMutableArray *horizontalSeparators;

@end

@implementation JAPDVRelatedItem

- (NSMutableArray *)verticalSeparators
{
    if (!VALID_NOTEMPTY(_verticalSeparators, NSMutableArray)) {
        _verticalSeparators = [NSMutableArray new];
    }
    return _verticalSeparators;
}

- (JAProductInfoHeaderLine *)topLabel
{
    if (!VALID_NOTEMPTY(_topLabel, JAProductInfoHeaderLine)) {
        _topLabel = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight)];
        [_topLabel setTitle:[STRING_YOU_MAY_ALSO_LIKE uppercaseString]];
        [self addSubview:_topLabel];
    }
    return _topLabel;
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerText = headerText;
    [self.topLabel setMultilineTitle:YES];
    [self.topLabel setTitle:_headerText];
}

- (NSMutableArray *)viewsArray
{
    if (!VALID_NOTEMPTY(_viewsArray, NSMutableArray)) {
        _viewsArray = [NSMutableArray new];
    }
    return _viewsArray;
}

- (void)addRelatedItemView:(JAPDVSingleRelatedItem *)itemView
{
    CGFloat headerOffset = CGRectGetMaxY(self.topLabel.frame);
    itemView.y += headerOffset;
    _lastItemSize = itemView.frame.size;
    [self addSubview:itemView];
    [self.viewsArray addObject:itemView];
    [self setHeight:CGRectGetMaxY(itemView.frame)];
    [self reloadHorizontalSeparators];
    [self reloadVerticalSeparators];
}

// separators for a table with 2 columns
- (void)reloadHorizontalSeparators
{
    [self removeHorizontalSeperators];
    
    //horizontal separators
    for (int i = 0; i < self.viewsArray.count ; i++) {
        UIView *view = [self.viewsArray objectAtIndex:i];
        if (CGRectGetMaxY(view.frame) != self.height) {
            UIView* hseparator = [self newHorizontalSeparator];
            [hseparator setFrame:CGRectMake(view.x, CGRectGetMaxY(view.frame),
                                            view.width, 1.f)];
        }
    }
}

//separators for single column
- (void)reloadVerticalSeparators
{
    [self removeVerticalSeperators];

    for (int i = 0; i < self.viewsArray.count ; i++) {
        UIView *view = [self.viewsArray objectAtIndex:i];
        
        if (CGRectGetMaxX(view.frame) != self.height) {
            UIView* seperator = [self newVerticalSeparator];
            CGFloat x = CGRectGetMaxX(view.frame);
            [seperator setFrame:CGRectMake(x, view.y,
                                           1, view.height)];
        }
    }
}

- (UIView *)newHorizontalSeparator
{
    UIView* horizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                           self.height/2,
                                                                           self.width,
                                                                           1)];
    [horizontalSeparator setBackgroundColor:JABlack700Color];
    [self addSubview:horizontalSeparator];
    [self.horizontalSeparators addObject:horizontalSeparator];
    
    return horizontalSeparator;
}

- (UIView *)newVerticalSeparator
{
    UIView* verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.width/2,
                                                                         self.topLabel.height,
                                                                         1,
                                                                         self.height - self.topLabel.height)];
    [verticalSeparator setBackgroundColor:JABlack700Color];
    [self addSubview:verticalSeparator];
    [self.verticalSeparators addObject:verticalSeparator];
    
    return verticalSeparator;
}

- (void)removeVerticalSeperators {
    for (UIView *separator in self.verticalSeparators) {
        [separator removeFromSuperview];
    }
    [self.verticalSeparators removeAllObjects];
}

- (void)removeHorizontalSeperators {
    for (UIView *separator in self.horizontalSeparators) {
        [separator removeFromSuperview];
    }
    [self.horizontalSeparators removeAllObjects];
}

@end
