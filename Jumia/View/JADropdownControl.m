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

- (UIView *)underLineView
{
    if (!VALID(_underLineView, UIView)) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, self.width, 1)];
        [_underLineView setBackgroundColor:JABlack700Color];
        [self addSubview:_underLineView];
    }
    return _underLineView;
}

- (UIImageView *)dropdownImageView
{
    if (!VALID(_dropdownImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"ic_dropdown"];
        _dropdownImageView = [[UIImageView alloc] initWithImage:image];
        [_dropdownImageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [self addSubview:_dropdownImageView];
    }
    return _dropdownImageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    if (self.titleLabel.width == self.width) {
        self.width = self.titleLabel.width + 15.f;
    }
    if (self.titleLabel.height == self.height) {
        self.height = self.titleLabel.height + 3.f;
    }
    [self.dropdownImageView setYCenterAligned];
    [self.dropdownImageView setXRightAligned:0.f];
    [self.underLineView setWidth:self.width];
    
    if (RI_IS_RTL) {
        [self.dropdownImageView setX:0.f];
    }
    
}

- (void)sizeToFit
{
    [self.titleLabel sizeToFit];
    self.height = self.titleLabel.height + 3.f;
    self.width = self.titleLabel.width + 15.f;
    [self.underLineView setYBottomAligned:0.f];
    [self.dropdownImageView setXRightAligned:0.f];
    [self.underLineView setWidth:self.width];
}

@end
