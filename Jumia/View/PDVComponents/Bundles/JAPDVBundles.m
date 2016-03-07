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
#import "RIProductSimple.h"

@interface JAPDVBundles() {
    BOOL _withSize;
    NSMutableArray *_bundlesArray;
    id _buyBundleTarget;
    SEL _buyBundleSelector;
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
        [self setBackgroundColor:JABlack300Color];
    }
    
    return self;
}

- (UIScrollView *)bundlesScrollView
{
    if (!VALID_NOTEMPTY(_bundlesScrollView, UIScrollView)) {
        _bundlesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.headerLine.height, self.width, 100)];
        [_bundlesScrollView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_bundlesScrollView];
    }
    return _bundlesScrollView;
}

- (JAProductInfoHeaderLine *)headerLine
{
    if (!VALID(_headerLine, JAProductInfoHeaderLine)) {
        _headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight)];
        [_headerLine setTitle:[STRING_BUY_THE_LOOK uppercaseString]];
        [self addSubview:_headerLine];
    }
    return _headerLine;
}

- (JAProductInfoSingleLine *)buyBundleLine
{
    if (!VALID_NOTEMPTY(_buyBundleLine, JAProductInfoSingleLine)) {
        _buyBundleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, 0, self.width, kProductInfoSingleLineHeight)];
        [_buyBundleLine setTopSeparatorVisibility:YES];
        [_buyBundleLine setTopSeparatorXOffset:0.f];
        [_buyBundleLine setBottomSeparatorVisibility:NO];
        [_buyBundleLine.label setTextColor:JAOrange1Color];
        [_buyBundleLine setBackgroundColor:[UIColor whiteColor]];
        [self.buyBundleLine addTarget:self action:@selector(buyBundleCombo) forControlEvents:UIControlEventTouchUpInside];
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
    [self.headerLine setTitle:_headerText];
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
    
    [self.buyBundleLine setX:self.bundlesScrollView.x];
    [self.buyBundleLine setWidth:self.bundlesScrollView.width];
    [self.buyBundleLine setY:CGRectGetMaxY(self.bundlesScrollView.frame)];
    [self setHeight:CGRectGetMaxY(self.buyBundleLine.frame)];
    
    [self refreshTotal];
}

- (void)refreshTotal
{
    CGFloat total = .0f;
    for (JAPDVBundleSingleItem *bundleItem in _bundlesArray) {
        if (bundleItem.selected && VALID_NOTEMPTY(bundleItem.product, RIProduct)) {
            if (VALID_NOTEMPTY(bundleItem.productSimple, RIProductSimple)) {
                if (NO == VALID_NOTEMPTY(bundleItem.productSimple.specialPrice, NSNumber) ||
                    (VALID_NOTEMPTY(bundleItem.productSimple.specialPrice, NSNumber) && 0.0f == [bundleItem.productSimple.specialPrice floatValue])) {
                    total += bundleItem.productSimple.price.floatValue;
                } else {
                    total += bundleItem.productSimple.specialPrice.floatValue;
                }
            } else {
                if (NO == VALID_NOTEMPTY(bundleItem.product.specialPrice, NSNumber) ||
                    (VALID_NOTEMPTY(bundleItem.product.specialPrice, NSNumber) && 0.0f == [self.product.specialPrice floatValue])) {
                    total += bundleItem.product.price.floatValue;
                } else {
                    total += bundleItem.product.specialPrice.floatValue;
                }
            }
        }
    }
    NSString* totalText = [NSString stringWithFormat:@"%@", [RICountryConfiguration formatPrice:[NSNumber numberWithFloat:total] country:[RICountryConfiguration getCurrentConfiguration]]];
    [self.buyBundleLine setTitle:totalText];
    [self.buyBundleLine.label setTextAlignment:NSTextAlignmentLeft];
    if (RI_IS_RTL) {
        [self.buyBundleLine flipAllSubviews];
    }
}

- (void)addBuyingBundleTarget:(id)target action:(SEL)action
{
    _buyBundleTarget = target;
    _buyBundleSelector = action;
}

- (void)buyBundleCombo
{
    if (_buyBundleTarget && [_buyBundleTarget respondsToSelector:_buyBundleSelector]) {
        ((void (*)(id, SEL))[_buyBundleTarget methodForSelector:_buyBundleSelector])(_buyBundleTarget, _buyBundleSelector);
    }
}

@end