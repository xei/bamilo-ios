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
    CGFloat width = self.contentScrollView.width - 32;
    if (!VALID_NOTEMPTY(_descriptionLabel, UILabel)) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.contentScrollView.width - 32, 10)];
        [_descriptionLabel setFont:JACaptionFont];
        [_descriptionLabel setNumberOfLines:0];
        [_descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentScrollView addSubview:_descriptionLabel];
    }else{
        if (width != _descriptionLabel.width) {
            [_descriptionLabel setX:16.f];
            [_descriptionLabel setWidth:width];
            [_descriptionLabel setTextAlignment:NSTextAlignmentLeft];
            [_descriptionLabel sizeToFit];
            [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, CGRectGetMaxY(_descriptionLabel.frame) + 16.f)];
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
        [self.descriptionLabel setText:[NSString stringWithFormat:@"%@\n%@", _product.summary, _product.shortSummary]];
        [self.descriptionLabel sizeToFit];
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.width, CGRectGetMaxY(self.descriptionLabel.frame) + 16.f)];
    }
}

- (UIScrollView *)contentScrollView
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    if (!VALID_NOTEMPTY(_contentScrollView, UIScrollView)) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
    }else if (!CGRectEqualToRect(frame, _contentScrollView.frame)) {
        [_contentScrollView setFrame:frame];
    }
    return _contentScrollView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self contentScrollView];
    [self descriptionLabel];
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
