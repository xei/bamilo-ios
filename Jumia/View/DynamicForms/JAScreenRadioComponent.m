//
//  JAScreenRadioComponent.m
//  Jumia
//
//  Created by telmopinto on 12/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAScreenRadioComponent.h"
#import "JAClickableView.h"

@interface JAScreenRadioComponent()

@property (nonatomic, strong) JAClickableView* clickableView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subTitleLabel;
@property (nonatomic, strong) UILabel* optionLabel;
@property (nonatomic, strong) UIImageView* arrowImageView;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation JAScreenRadioComponent

- (JAClickableView*)clickableView
{
    if (!VALID_NOTEMPTY(_clickableView, JAClickableView)){
        _clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 78.0f)];
        [_clickableView addTarget:self action:@selector(componentWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clickableView];
    }
    return _clickableView;
}

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 10.0f, 230.0f, 20.0f)];
        [_titleLabel setTextColor:JABlackColor];
        [_titleLabel setFont:JABody2Font];
        [self.clickableView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!VALID_NOTEMPTY(_subTitleLabel, UILabel)) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 30.0f, 230.0f, 40.0f)];
        [_subTitleLabel setNumberOfLines:2];
        [_subTitleLabel setTextColor:JABlack800Color];
        [_subTitleLabel setFont:JABody3Font];
        [self.clickableView addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}

- (UILabel *)optionLabel
{
    if (!VALID_NOTEMPTY(_optionLabel, UILabel)) {
        _optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 20.0f)];
        [_optionLabel setTextColor:JABlack700Color];
        [_optionLabel setFont:JACaptionFont];
        [self.clickableView addSubview:_optionLabel];
    }
    return _optionLabel;
}

- (UIImageView *)arrowImageView
{
    if (!VALID_NOTEMPTY(_arrowImageView, UIImageView)) {
        UIImage* arrowImage = [UIImage imageNamed:@"sideMenuCell_arrow"];
        _arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        [_arrowImageView setFrame:CGRectMake(self.frame.size.width - self.arrowImageView.frame.size.width - 16.0f,
                                                 (self.frame.size.height - self.arrowImageView.frame.size.height) / 2,
                                                 self.arrowImageView.frame.size.width,
                                                 self.arrowImageView.frame.size.height)];
        [self.clickableView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UIView *)separatorView
{
    if (!VALID_NOTEMPTY(_separatorView, UIView)) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 0.0f, 304.0f, 1.0f)];
        _separatorView.backgroundColor = JABlack400Color;
        [self.clickableView addSubview:_separatorView];
    }
    return _separatorView;
}

- (void)setCurrentlyChecked:(BOOL)currentlyChecked
{
    CGFloat separatorViewY = 0.0f;
    _currentlyChecked = currentlyChecked;
    if (_currentlyChecked) {
        self.optionLabel.text = STRING_ACTIVE;
    } else {
        self.optionLabel.text = STRING_INACTIVE;
        separatorViewY = self.clickableView.frame.size.height - self.separatorView.frame.size.height;
    }
    
    self.separatorView.y = separatorViewY;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.0f, 0.0f, 320.f, 78.0f)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.clickableView setFrame:self.bounds];
    
    self.arrowImageView.frame = CGRectMake(self.frame.size.width - self.arrowImageView.frame.size.width - 16.0f,
                                           (self.frame.size.height - self.arrowImageView.frame.size.height) / 2,
                                           self.arrowImageView.frame.size.width,
                                           self.arrowImageView.frame.size.height);
    
    self.separatorView.frame = CGRectMake(16.0f, self.separatorView.frame.origin.y, self.width-16.0f, 1.0f);
    

    [self.optionLabel setFrame:CGRectMake(self.arrowImageView.frame.origin.x - self.optionLabel.frame.size.width - 5.0f,
                                          (self.frame.size.height - self.optionLabel.frame.size.height) / 2,
                                          self.optionLabel.frame.size.width,
                                          self.optionLabel.frame.size.height)];
    self.optionLabel.textAlignment = NSTextAlignmentLeft;
    
    self.titleLabel.frame = CGRectMake(16.0f, 10.0f, self.optionLabel.frame.origin.x - 16.0f*2, 20.0f);
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.subTitleLabel.frame = CGRectMake(16.0f, 30.0f, self.titleLabel.frame.size.width, 40.0f);
    self.subTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.titleLabel flipViewPositionInsideSuperview];
        [self.titleLabel flipViewAlignment];
        [self.subTitleLabel flipViewPositionInsideSuperview];
        [self.subTitleLabel flipViewAlignment];
        [self.optionLabel flipViewPositionInsideSuperview];
        [self.optionLabel flipViewAlignment];
        [self.arrowImageView flipViewPositionInsideSuperview];
        [self.arrowImageView flipViewImage];
        
        [self.separatorView flipViewPositionInsideSuperview];
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    self.currentlyChecked = [self.field.checked boolValue];
    
    self.titleLabel.text = field.label;
    self.subTitleLabel.text = field.subLabel;
}

- (void)componentWasPressed:(UIControl*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(screenRadioComponentWasPressed:)]) {
        [self.delegate screenRadioComponentWasPressed:self];
    }
}


@end
