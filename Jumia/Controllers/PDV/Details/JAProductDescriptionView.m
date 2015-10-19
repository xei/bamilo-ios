//
//  JAProductDescriptionView.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductDescriptionView.h"

@interface JAProductDescriptionView ()

@property (nonatomic) UIScrollView *contentScrollView;
@property (nonatomic) UILabel *descriptionLabel;

@end

@implementation JAProductDescriptionView

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

- (UILabel *)descriptionLabel
{
    CGRect frame = CGRectMake(16, 16, self.contentScrollView.width - 32, 300);
    if (!VALID_NOTEMPTY(_descriptionLabel, UILabel)) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:frame];
        [_descriptionLabel setFont:JACaptionFont];
        [_descriptionLabel setNumberOfLines:0];
        [self.contentScrollView addSubview:_descriptionLabel];
    }else{
        if (!CGRectEqualToRect(frame, _descriptionLabel.frame)) {
            [_descriptionLabel setFrame:frame];
            [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, CGRectGetMaxY(self.descriptionLabel.frame) + 16.f)];
        }
    }
    return _descriptionLabel;
}

- (void)setDefaults
{
    [self addSubview:self.contentScrollView];
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
    if (VALID_NOTEMPTY(_product.shortSummary, NSString)) {
        [self.descriptionLabel setText:_product.summary];
        [self.descriptionLabel sizeToFit];
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, CGRectGetMaxY(self.descriptionLabel.frame) + 16.f)];
    }
}

- (UIScrollView *)contentScrollView
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    if (!VALID_NOTEMPTY(_contentScrollView, UIScrollView)) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
    }else{
        if (!CGRectEqualToRect(frame, _contentScrollView.frame)) {
            [_contentScrollView setFrame:frame];
        }
    }
    return _contentScrollView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self contentScrollView];
    [self descriptionLabel];
}

@end
