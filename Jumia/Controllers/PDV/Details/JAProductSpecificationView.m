//
//  JAProductSpecificationView.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductSpecificationView.h"
#import "RISpecification.h"
#import "RISpecificationAttribute.h"
#import "JAProductInfoHeaderLine.h"

@interface JAProductSpecificationView ()

@property (nonatomic) UIScrollView *contentScrollView;

@end

@implementation JAProductSpecificationView

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
    [self addSubview:self.contentScrollView];
}

- (UIView *)getKeyValueLineWithKey:(NSString *)key andValue:(NSString *)value
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(16, 0, self.contentScrollView.width - 32, 36)];
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, lineView.width/3, lineView.height)];
    [keyLabel setNumberOfLines:0];
    [keyLabel setFont:JACaptionFont];
    [keyLabel setTextColor:JABlack800Color];
    [keyLabel setText:key];
    [keyLabel sizeToFit];
    [lineView addSubview:keyLabel];
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(lineView.width/3, 8, 2*lineView.width/3, lineView.height)];
    [valueLabel setNumberOfLines:0];
    [valueLabel setFont:JACaptionFont];
    [valueLabel setTextColor:JABlackColor];
    [valueLabel setText:value];
    [valueLabel sizeToFit];
    [lineView addSubview:valueLabel];
    
    [lineView setHeight:(keyLabel.height > valueLabel.height? CGRectGetMaxY(keyLabel.frame) : CGRectGetMaxY(valueLabel.frame)) + 8.f];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, lineView.height-1, lineView.width, 1)];
    [separator setBackgroundColor:JABlack300Color];
    [lineView addSubview:separator];
    return lineView;
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
    CGFloat yOffset = 0;
    for (RISpecification *spec in product.specifications) {
        JAProductInfoHeaderLine *spectHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, self.contentScrollView.width, kProductInfoHeaderLineHeight)];
        [spectHeaderLine setTopSeparatorVisibility:NO];
        [spectHeaderLine setTitle:[spec.headLabel uppercaseString]];
        [self.contentScrollView addSubview:spectHeaderLine];
        yOffset = CGRectGetMaxY(spectHeaderLine.frame);
        for (RISpecificationAttribute *attr in spec.specificationAttributes) {
            UIView *line = [self getKeyValueLineWithKey:attr.key andValue:attr.value];
            [line setY:yOffset];
            [self.contentScrollView addSubview:line];
            yOffset = CGRectGetMaxY(line.frame);
        }
    }
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, yOffset + 16.f)];
}

- (UIScrollView *)contentScrollView
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    if (!VALID_NOTEMPTY(_contentScrollView, UIScrollView)) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
    }else if (!CGRectEqualToRect(frame, _contentScrollView.frame))
    {
        [_contentScrollView setFrame:frame];
        for (UIView *subView in _contentScrollView.subviews) {
            [subView removeFromSuperview];
        }
        if (VALID_NOTEMPTY(self.product, RIProduct)) {
            [self setProduct:self.product];
        }
    }
    return _contentScrollView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self contentScrollView];
}

@end
