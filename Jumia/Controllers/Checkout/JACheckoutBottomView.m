//
//  JACheckoutBottom.m
//  Jumia
//
//  Created by josemota on 7/27/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACheckoutBottomView.h"
#import "UIImage+WithColor.h"
#import "JAButton.h"

@interface JACheckoutBottomView () {
    UILabel *_totalLabel;
    UILabel *_totalLabelValue;
    JAButton *_submitButton;
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
    [_delimiter setBackgroundColor:JABlack400Color];
    [self addSubview:_delimiter];
    _totalBackgoundColor = JAWhiteColor;
    [self setBackgroundColor:_totalBackgoundColor];
    
    _totalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/2, self.height)];
    [self addSubview:_totalView];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_totalLabel setFont:JADisplay1Font];
    [_totalLabel setTextColor:JABlackColor];
    [_totalLabel setFrame:CGRectMake(23, _totalView.height/2 - _totalLabel.height/2, _totalLabel.width, _totalLabel.height)];
    [_totalLabel setFont:[UIFont fontWithName:kFontRegularName size:_totalLabel.font.pointSize]];
    [_totalView addSubview:_totalLabel];
    
    _totalLabelValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [_totalLabelValue setFont:JADisplay1Font];
    [_totalLabelValue setTextColor:JABlack800Color];
    [self setTotalValue:@""];
    [_totalView addSubview:_totalLabelValue];
    
    _submitButton = [[JAButton alloc] initButtonWithTitle:STRING_NEXT];
    [_submitButton setFrame:CGRectMake(self.width/3*2, 0, self.width/3, self.height)];
    [self addSubview:_submitButton];
    
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        [self setNoTotal:YES];
    }else{
        [self setNoTotal:NO];
    }
}

- (void)reloadViews
{
    [self setBackgroundColor:_totalBackgoundColor];
    [_delimiter setHidden:NO];
    [_totalView setHidden:NO];
    [_submitButton setFrame:CGRectMake(self.width/3*2, 0, self.width/3, self.height)];
    [_totalView setX:0];
    [_totalLabel setTextAlignment:NSTextAlignmentLeft];
    [_totalLabelValue setTextAlignment:NSTextAlignmentLeft];
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
    [_submitButton setTitle:text forState:UIControlStateNormal];
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

- (void)disableButton{
    [_submitButton setEnabled:NO];
}

@end
