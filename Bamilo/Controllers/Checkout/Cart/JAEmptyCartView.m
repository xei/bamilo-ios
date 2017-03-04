//
//  JAEmptyCartView.m
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAEmptyCartView.h"
#import "JAButton.h"

#define kLateralMargin 16
#define kTopMargin 48
#define kImageTopMargin 28
#define kImageBottomMargin 28
#define kButtonWidth 288

@interface JAEmptyCartView ()

@property (strong, nonatomic) UILabel *emptyCartLabel;
@property (strong, nonatomic) JAButton *continueShoppingButton;
@property (strong, nonatomic) UIImageView *emptyCartImageView;

@end

@implementation JAEmptyCartView

- (UILabel *)emptyCartLabel
{
    if (!VALID_NOTEMPTY(_emptyCartLabel, UILabel)) {
        _emptyCartLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.width - 2*kLateralMargin, 17)];
        [_emptyCartLabel setFont:JADisplay2Font];
        [_emptyCartLabel setTextColor:JABlackColor];
        [_emptyCartLabel setTextAlignment:NSTextAlignmentCenter];
        [_emptyCartLabel setNumberOfLines:2];
        [_emptyCartLabel setText:STRING_NO_ITEMS_IN_CART];
        [self addSubview:_emptyCartLabel];
    }
    return _emptyCartLabel;
}

- (UIImageView *)emptyCartImageView
{
    if (!VALID_NOTEMPTY(_emptyCartImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"img_emptyCart"];
        _emptyCartImageView = [[UIImageView alloc] initWithImage:image];
        [_emptyCartImageView setFrame:CGRectMake((self.width - image.size.width)/2, CGRectGetMaxY(self.emptyCartLabel.frame) + kImageTopMargin, image.size.width, image.size.height)];
        [self addSubview:_emptyCartImageView];
    }
    return _emptyCartImageView;
}

- (JAButton *)continueShoppingButton
{
    if (!VALID_NOTEMPTY(_continueShoppingButton, JAButton)) {
        _continueShoppingButton = [[JAButton alloc] initButtonWithTitle:[STRING_CONTINUE_SHOPPING uppercaseString] target:self action:@selector(goToHomeScreen)];
        
        [_continueShoppingButton setFrame:CGRectMake((self.width - kButtonWidth)/2, CGRectGetMaxY(self.emptyCartImageView.frame) + kImageBottomMargin, kButtonWidth, kBottomDefaultHeight)];
        [self addSubview:_continueShoppingButton];
    }
    return _continueShoppingButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.emptyCartLabel setXCenterAligned];
    [self.emptyCartImageView setXCenterAligned];
    [self.continueShoppingButton setXCenterAligned];
}

- (void)goToHomeScreen
{
}

- (void)addHomeScreenTarget:(id)target action:(SEL)action
{
    [self.continueShoppingButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
