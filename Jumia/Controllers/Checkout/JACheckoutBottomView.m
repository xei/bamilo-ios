//
//  JACheckoutBottom.m
//  Jumia
//
//  Created by josemota on 7/27/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACheckoutBottomView.h"
#import "UIImage+WithColor.h"

@interface JACheckoutBottomView () {
    UILabel *_totalLabel;
    UILabel *_totalLabelValue;
    UIButton *_submitButton;
//    JAButtonWithBlur *_submitButton;
    UIInterfaceOrientation _orientation;
    UIView *_totalView;
    
    UIColor *_totalBackgoundColor;
    UIView *_delimiter;
}

@end

@implementation JACheckoutBottomView

- (instancetype)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    self = [super initWithFrame:frame];
    if (self) {
        _orientation = orientation;
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    _delimiter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    [_delimiter setBackgroundColor:[UIColor colorWithRed:0.3059 green:0.3059 blue:0.3059 alpha:.5]];
    [self addSubview:_delimiter];
    _totalBackgoundColor = [UIColor clearColor];
    [self setBackgroundColor:_totalBackgoundColor];
    
    _totalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
    [self addSubview:_totalView];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_totalLabel setFont:[UIFont systemFontOfSize:16]];
    [_totalLabel setTextColor:[UIColor colorWithRed:0.3059 green:0.3059 blue:0.3059 alpha:1]];
    [_totalLabel setFrame:CGRectMake(23, _totalView.height/2 - _totalLabel.height/2, _totalLabel.width, _totalLabel.height)];
    [_totalView addSubview:_totalLabel];
    
    _totalLabelValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [_totalLabelValue setFont:[UIFont boldSystemFontOfSize:16]];
    [_totalLabelValue setTextColor:[UIColor colorWithRed:.8f green:0 blue:0 alpha:1]];
    [self setTotalValue:@""];
    [_totalView addSubview:_totalLabelValue];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitButton.layer setCornerRadius:3.5f];
    [_submitButton.layer setMasksToBounds:YES];
    [_submitButton setFrame:CGRectMake(self.width/2 + 5, 5, self.width/2 - 10, self.height-10)];
    [_submitButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [_submitButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [_submitButton setTitle:@"Next" forState:UIControlStateNormal];
    [_submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:.957 green:.67451 blue:.2392 alpha:1]] forState:UIControlStateNormal];
    [_submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:.907 green:.60451 blue:.2092 alpha:1]] forState:UIControlStateHighlighted];
    [_submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:.907 green:.60451 blue:.2092 alpha:1]] forState:UIControlStateSelected];
    [self addSubview:_submitButton];
    
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        [self setNoTotal:YES];
    }else{
        [self setNoTotal:NO];
    }
}

- (void)reloadViews
{
    if (_noTotal) {
        [self setBackgroundColor:[UIColor clearColor]];
        [_delimiter setHidden:YES];
        [_totalView setHidden:YES];
        [_submitButton setFrame:CGRectMake(5, 5, self.width - 10, self.height - 10)];
    }else{
        [self setBackgroundColor:_totalBackgoundColor];
        [_delimiter setHidden:NO];
        [_totalView setHidden:NO];
        [_submitButton setFrame:CGRectMake(self.width/2 + 5, 5, self.width/2 - 10, self.height - 10)];
        [_submitButton setX:self.width/2 + 5];
        [_submitButton setWidth:self.width/2 - 10];
    }
}

- (void)setTotalValue:(NSString *)totalValue
{
    if (!VALID_NOTEMPTY(totalValue, NSString)) {
        return;
    }
    _totalValue = totalValue;
    [_totalLabel setText:[NSString stringWithFormat:@"%@: ", STRING_TOTAL]];
    [_totalLabel sizeToFit];
    [_totalLabelValue setText:_totalValue];
    [_totalLabelValue sizeToFit];
    [_totalLabel setX:23];
    if (_totalLabelValue.width + _totalLabel.width > self.width/2 - 22) {
        [_totalLabel setY:10];
        [_totalLabelValue setY:30];
        [_totalLabelValue setX:_totalLabel.x];
    }else{
        [_totalLabel setY:self.height/2 - _totalLabelValue.height/2];
        [_totalLabelValue setY:self.height/2 - _totalLabelValue.height/2];
        [_totalLabelValue setX:CGRectGetMaxX(_totalLabel.frame)];
    }
    
    [self reloadViews];
}

- (void)setButtonText:(NSString *)text target:(id)target action:(SEL)selector
{
    [_submitButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setNoTotal:(BOOL)noTotal
{
    _noTotal = noTotal;
    [self reloadViews];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reloadViews];
}

@end
