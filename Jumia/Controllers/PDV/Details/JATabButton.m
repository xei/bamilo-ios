//
//  JATabButton.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabButton.h"

@interface JATabButton ()

@property (nonatomic) UIView *selectionView;

@end

@implementation JATabButton

- (UIView *)selectionView
{
    CGRect frame = CGRectMake(0, self.height - 4, self.width, 3);
    if (!VALID_NOTEMPTY(_selectionView, UIView)) {
        _selectionView = [[UIView alloc] initWithFrame:frame];
        [_selectionView setBackgroundColor:JAOrange1Color];
        [_selectionView setHidden:YES];
    }else{
        if (!CGRectEqualToRect(frame, _selectionView.frame)) {
            [_selectionView setFrame:frame];
        }
    }
    return _selectionView;
}

- (UIButton *)titleButton
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    if (!VALID_NOTEMPTY(_titleButton, UIButton)) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton setFrame:frame];
        [_titleButton.titleLabel setFont:JABody3Font];
        [_titleButton setTitleColor:JABlack800Color forState:UIControlStateNormal];
        [_titleButton setTitleColor:JABlackColor forState:UIControlStateHighlighted];
        [_titleButton setTitleColor:JABlackColor forState:UIControlStateSelected];
    }else{
        if (!CGRectEqualToRect(frame, _titleButton.frame)) {
            [_titleButton setFrame:frame];
        }
    }
    return _titleButton;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self.selectionView setHidden:!_selected];
    if (_selected) {
        [self.titleButton setSelected:YES];
    }else{
        [self.titleButton setSelected:NO];
    }
}

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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self titleButton];
    [self selectionView];
}

- (void)setDefaults
{
    [self addSubview:self.titleButton];
    [self addSubview:self.selectionView];
}

@end
