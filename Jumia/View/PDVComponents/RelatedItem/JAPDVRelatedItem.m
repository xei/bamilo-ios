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
    if (self.height >= _lastItemSize.height*2) {
        [self reloadCrossSeparators];
    }else{
        [self reloadVerticalSeparators];
    }
}

// separators for a table with 2 columns
- (void)reloadCrossSeparators
{
    [self removeAllSeperators];
    
    //horizontal separators
    NSInteger nItems = [self.viewsArray count];
    if (nItems%2 == 0) {
        nItems -= 1;
    }
    for (NSInteger i = 0; 2*i+1 < nItems; i++) {
        UIView* hseparator = [self newHorizontalSeparator];
        UIView* item = [self.viewsArray objectAtIndex:2*i+1];//odd number item
        [hseparator setFrame:CGRectMake(0, CGRectGetMaxY(item.frame),
                                        self.width, 1.f)];
    }

    UIView* verticalSeparator = [self newVerticalSeparator];
    [verticalSeparator setFrame:CGRectMake(self.width/2, self.topLabel.height,
                                           1, CGRectGetMaxY([(UIView *)[self.viewsArray lastObject] frame]) - CGRectGetMaxY(self.topLabel.frame))];
}

//separators for single column
- (void)reloadVerticalSeparators
{
    [self removeAllSeperators];

    for (int i = 1; i < self.viewsArray.count ; i++) {
        UIView *view = [self.viewsArray objectAtIndex:i];
        
        UIView* seperator = [self newVerticalSeparator];
        [seperator setFrame:CGRectMake(view.x, self.topLabel.height,
                                       1, self.height - self.topLabel.height)];
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


- (void)removeAllSeperators {
    for (UIView *separator in self.verticalSeparators) {
        [separator removeFromSuperview];
    }
    for (UIView *separator in self.horizontalSeparators) {
        [separator removeFromSuperview];
    }
    [self.verticalSeparators removeAllObjects];
    [self.horizontalSeparators removeAllObjects];
}

@end
