//
//  JAOptionResumeView.m
//  Jumia
//
//  Created by Jose Mota on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAOptionResumeView.h"

#define kLateralMargin 10.f

@interface JAOptionResumeView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *optionLabel;

@end

@implementation JAOptionResumeView

- (UILabel *)titleLabel
{
    if (!VALID(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, 10.f, self.width - 2*kLateralMargin, 12)];
        [_titleLabel setFont:JABodyFont];
        [_titleLabel setTextColor:JABlack800Color];
    }
    return _titleLabel;
}

- (UILabel *)optionLabel
{
    if (!VALID(_optionLabel, UILabel)) {
        _optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleLabel.frame) + 2.f, self.width - 2*kLateralMargin, 12)];
        [_optionLabel setFont:JABodyFont];
        [_optionLabel setTextColor:JABlackColor];
    }
    return _optionLabel;
}

- (UIButton *)editButton
{
    if (!VALID(_editButton, UIButton)) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"editAddress"];
        [_editButton setImage:image forState:UIControlStateNormal];
        [_editButton setSize:image.size];
    }
    return _editButton;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleLabel setText:title];
    [self.titleLabel setSizeForcingMaxSize:CGSizeMake(self.editButton.x - 2*kLateralMargin, CGFLOAT_MAX)];
    [self reload];
    
    [self setHeight:CGRectGetMaxY(self.optionLabel.frame) + 10.f];
}

- (void)setOption:(NSString *)option
{
    _option = option;
    [self.optionLabel setText:option];
    [self.titleLabel setSizeForcingMaxSize:CGSizeMake(self.editButton.x - 2*kLateralMargin, CGFLOAT_MAX)];
    [self reload];
    
    [self setHeight:CGRectGetMaxY(self.optionLabel.frame) + 10.f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:JABlack300Color.CGColor];
    
    if (!VALID(self.titleLabel.superview, UIView)) {
        [self addSubview:self.titleLabel];
    }
    
    if (!VALID(self.optionLabel.superview, UIView)) {
        [self addSubview:self.optionLabel];
    }
    
    if (!VALID(self.editButton.superview, UIView)) {
        [self addSubview:self.editButton];
    }
    
    [self reload];
}

- (void)reload
{
    [self.editButton setXRightAligned:kLateralMargin];
    [self.editButton setYCenterAligned];
    
    [self.titleLabel setX:kLateralMargin];
    [self.titleLabel setWidth:self.editButton.x - 2*kLateralMargin];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.optionLabel setX:kLateralMargin];
    [self.optionLabel setWidth:self.editButton.x - 2*kLateralMargin];
    [self.optionLabel setTextAlignment:NSTextAlignmentLeft];
    [self.optionLabel setYBottomOf:self.titleLabel at:2.f];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
