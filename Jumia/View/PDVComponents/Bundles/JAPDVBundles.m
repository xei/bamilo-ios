//
//  JAPDVBundles.m
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVBundles.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSingleLine.h"

@interface JAPDVBundles() {
    BOOL _withSize;
    NSMutableArray *_bundlesArray;
}

@property (nonatomic) UIScrollView *bundlesScrollView;
@property (nonatomic) JAProductInfoHeaderLine *headerLine;
@property (nonatomic) JAProductInfoSingleLine *buyBundleLine;

@end

@implementation JAPDVBundles

- (instancetype)initWithFrame:(CGRect)frame withSize:(BOOL)withSize
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _withSize = withSize;
        _bundlesArray = [NSMutableArray new];
    }
    
    return self;
}

- (UIScrollView *)bundlesScrollView
{
    if (!VALID_NOTEMPTY(_bundlesScrollView, UIScrollView)) {
        _bundlesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.headerLine.height, self.width, 100)];
        [self addSubview:_bundlesScrollView];
    }
    return _bundlesScrollView;
}

- (JAProductInfoHeaderLine *)headerLine
{
    if (!VALID(_headerLine, JAProductInfoHeaderLine)) {
        _headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight)];
#warning TODO String
        [_headerLine setTitle:[@"Buy the look" uppercaseString]];
        [self addSubview:_headerLine];
    }
    return _headerLine;
}

- (JAProductInfoSingleLine *)buyBundleLine
{
    if (!VALID_NOTEMPTY(_buyBundleLine, JAProductInfoSingleLine)) {
        _buyBundleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoSingleLineHeight)];
        [_buyBundleLine setTopSeparatorVisibility:YES];
        [_buyBundleLine setBottomSeparatorVisibility:NO];
        [_buyBundleLine.label setTextColor:JAOrange1Color];
        [self addSubview:_buyBundleLine];
    }
    return _buyBundleLine;
}

- (UIView *)plusViewWithFrame:(CGRect)frame
{
    UIView *_plusView = [[UIView alloc] initWithFrame:frame];
//        _plusView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2 - 5, self.productImageView.height/2, 10, 10)];
    UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, _plusView.height/2-1, _plusView.width, 2)];
    [horizontalLine setBackgroundColor:JABlack400Color];
    [_plusView addSubview:horizontalLine];
    UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(_plusView.width/2-1, 0, 2, _plusView.height)];
    [verticalLine setBackgroundColor:JABlack400Color];
    [_plusView addSubview:verticalLine];
    [self addSubview:_plusView];
    return _plusView;
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerText = headerText;
    [self.headerLine.label setText:_headerText];
}

- (void)addBundleItemView:(JAPDVBundleSingleItem *)itemView
{
    [self.bundlesScrollView addSubview:itemView];
    if (CGRectGetMaxX(itemView.frame) < self.width) {
        [self.bundlesScrollView setWidth:CGRectGetMaxX(itemView.frame)];
        [self.bundlesScrollView setX:(self.width - CGRectGetMaxX(itemView.frame))/2];
    }else if (self.bundlesScrollView.x != 0 || self.bundlesScrollView.width != self.width){
        [self.bundlesScrollView setX:0];
        [self.bundlesScrollView setWidth:self.width];
    }
    [itemView addSelectTarget:self action:@selector(refreshTotal)];
    [self.bundlesScrollView setContentSize:CGSizeMake(CGRectGetMaxX(itemView.frame), itemView.height)];
    if (_bundlesArray.count != 0) {
        CGFloat plusSize = 15;
        [self.bundlesScrollView addSubview:[self plusViewWithFrame:CGRectMake(itemView.x - plusSize/2 - 2.5, itemView.height/2, plusSize, plusSize)]];
    }
    if (self.bundlesScrollView.height < itemView.height) {
        self.bundlesScrollView.height = itemView.height;
    }
    if (self.height < itemView.height) {
        [self setHeight:itemView.height];
    }
    [_bundlesArray addObject:itemView];
    [self refreshTotal];
}

- (void)refreshTotal
{
    CGFloat total = .0f;
    for (JAPDVBundleSingleItem *bundleItem in _bundlesArray) {
        if (bundleItem.selected) {
            if (VALID_NOTEMPTY(bundleItem.product, RIProduct)) {
                
                if (VALID_NOTEMPTY(bundleItem.product.specialPrice, NSNumber) && 0.0f == [self.product.specialPrice floatValue]) {
                    total += bundleItem.product.price.floatValue;
                } else {
                    total += bundleItem.product.specialPrice.floatValue;
                }
            }
        }
    }
    NSString* totalText = [NSString stringWithFormat:@"%@", [RICountryConfiguration formatPrice:[NSNumber numberWithFloat:total] country:[RICountryConfiguration getCurrentConfiguration]]];
    [self.buyBundleLine.label setText:totalText];
    [self.buyBundleLine addTarget:self action:@selector(buyBundleCombo) forControlEvents:UIControlEventTouchUpInside];
    [self.buyBundleLine setY:CGRectGetMaxY(self.bundlesScrollView.frame)];
    [self setHeight:CGRectGetMaxY(self.buyBundleLine.frame)];
}
#warning TODO buy Bundle combo
- (void)buyBundleCombo
{
    NSLog(@"buyBundleCombo");
}

@end