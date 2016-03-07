//
//  JARadioControl.m
//  Jumia
//
//  Created by Jose Mota on 23/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JADropdownControl.h"

@interface JADropdownControl ()

@property (strong, nonatomic) UIView *underLineView;
@property (strong, nonatomic) UIImageView *dropdownImageView;

@end

@implementation JADropdownControl

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
    [self.titleLabel setFont:JACaptionFont];
    [self setTintColor:JABlack900Color];
    if (!VALID(self.underLineView.superview, UIView)) {
        [self addSubview:self.underLineView];
    }
    if (!VALID(self.dropdownImageView.superview, UIView)) {
        [self addSubview:self.dropdownImageView];
    }
    [self.dropdownImageView setXRightAligned:0.f];
    [self.dropdownImageView setYCenterAligned];
}

- (UIView *)underLineView
{
    if (!VALID(_underLineView, UIView)) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, self.width, 1)];
        [_underLineView setBackgroundColor:JABlack700Color];
    }
    return _underLineView;
}

- (UIImageView *)dropdownImageView
{
    if (!VALID(_dropdownImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"ic_dropdown"];
        _dropdownImageView = [[UIImageView alloc] initWithImage:image];
        [_dropdownImageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    return _dropdownImageView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.dropdownImageView setYCenterAligned];
    [self.underLineView setWidth:frame.size.width];
    [self.underLineView setYBottomAligned:0.f];
    if (RI_IS_RTL) {
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.dropdownImageView setX:0.f];
        [self.underLineView setX:0.f];
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self setDefaults];
    if (RI_IS_RTL) {
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.dropdownImageView setX:0.f];
    }
}

@end
