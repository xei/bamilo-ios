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

@property (nonatomic) JAProductInfoHeaderLine *topLabel;
@property (nonatomic) UIView *horizontalSeparator;
@property (nonatomic) UIView *verticalSeparator;

@end

@implementation JAPDVRelatedItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setDefaults];
    }
    
    return self;
}

- (void)setDefaults
{
}

- (JAProductInfoHeaderLine *)topLabel
{
    if (!VALID_NOTEMPTY(_topLabel, JAProductInfoHeaderLine)) {
        _topLabel = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight)];
        [_topLabel.label setText:[@"You may also like" uppercaseString]];
        [_topLabel.label sizeToFit];
        [self addSubview:_topLabel];
    }
    return _topLabel;
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerText = headerText;
    [self.topLabel.label setText:_headerText];
}

- (void)addRelatedItemView:(JAPDVSingleRelatedItem *)itemView
{
    CGFloat headerOffset = CGRectGetMaxY(self.topLabel.frame);
    itemView.y += headerOffset;
    [self addSubview:itemView];
    [self setHeight:CGRectGetMaxY(itemView.frame)];
    [self reloadSeparators];
}

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

- (void)reloadSeparators
{
    [self.horizontalSeparator setFrame:CGRectMake(0, self.topLabel.height + (self.height - self.topLabel.height)/2, self.width, 1)];
    [self.verticalSeparator setFrame:CGRectMake(self.width/2, self.topLabel.height, 1, self.height - self.topLabel.height)];
}

@end
