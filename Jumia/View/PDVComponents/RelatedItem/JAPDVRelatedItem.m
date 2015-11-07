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
@property (nonatomic) UIView *horizontalSeparator;
@property (nonatomic) UIView *verticalSeparator;
@property (nonatomic) NSMutableArray *viewsArray;
@property (nonatomic) NSMutableArray *verticalSeparators;

@end

@implementation JAPDVRelatedItem

- (UIView *)horizontalSeparator
{
    if (!VALID_NOTEMPTY(_horizontalSeparator, UIView)) {
        _horizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.height/2, self.width, 1)];
        [_horizontalSeparator setBackgroundColor:JABlack700Color];
        [self addSubview:_horizontalSeparator];
    }
    return _horizontalSeparator;
}

- (UIView *)verticalSeparator
{
    if (!VALID_NOTEMPTY(_verticalSeparator, UIView)) {
        _verticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.width/2, self.topLabel.height, 1, self.height - self.topLabel.height)];
        [_verticalSeparator setBackgroundColor:JABlack700Color];
        [self addSubview:_verticalSeparator];
    }
    return _verticalSeparator;
}

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

- (void)reloadCrossSeparators
{
    [self.horizontalSeparator setHidden:NO];
    [self.verticalSeparator setHidden:NO];
    for (UIView *separator in self.verticalSeparators) {
        [separator removeFromSuperview];
    }
    [self.verticalSeparators removeAllObjects];
    
    [self.horizontalSeparator setFrame:CGRectMake(0, self.topLabel.height + (self.height - self.topLabel.height)/2, self.width, 1)];
    [self.verticalSeparator setFrame:CGRectMake(self.width/2, self.topLabel.height, 1, CGRectGetMaxY([(UIView *)[self.viewsArray lastObject] frame]) - CGRectGetMaxY(self.topLabel.frame))];
}

- (void)reloadVerticalSeparators
{
    [self.horizontalSeparator setHidden:YES];
    [self.verticalSeparator setHidden:YES];
    UIView *lastView;
    for (int i = 0; i < self.viewsArray.count; i++) {
        UIView *view = [self.viewsArray objectAtIndex:i];
        if (lastView) {
            CGFloat middlePoint = [self getMiddlePointFrom:CGRectGetMaxX(lastView.frame) andSecondPoint:view.x];
            if (i < self.verticalSeparators.count) {
                UIView *separator = [self.verticalSeparators objectAtIndex:i];
                [separator setFrame:CGRectMake(middlePoint, self.topLabel.height, 1, self.height - self.topLabel.height)];
            }else{
                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(middlePoint, self.topLabel.height, 1, self.height - self.topLabel.height)];
                [separator setBackgroundColor:JABlack700Color];
                [self addSubview:separator];
                [self.verticalSeparators addObject:separator];
            }
        }
        lastView = view;
    }
}

- (CGFloat)getMiddlePointFrom:(CGFloat)firstPoint andSecondPoint:(CGFloat)secondPoint
{
    return firstPoint + (firstPoint - secondPoint)/2;
}

@end
