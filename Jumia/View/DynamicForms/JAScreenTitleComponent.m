//
//  JAScreenTitleComponent.m
//  Jumia
//
//  Created by telmopinto on 15/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAScreenTitleComponent.h"

@interface JAScreenTitleComponent()

@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *separatorView;

@end


@implementation JAScreenTitleComponent

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 10.0f, self.width - 16.f*2, 20)];
        [_titleLabel setTextColor:JABlackColor];
        [_titleLabel setFont:JACaptionFont];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!VALID_NOTEMPTY(_subTitleLabel, UILabel)) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 30.0f, self.width - 16.f*2, 60)];
        _subTitleLabel.numberOfLines = 3;
        [_subTitleLabel setTextColor:JABlackColor];
        [_subTitleLabel setFont:JACaptionFont];
        [self addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}

- (UIView *)separatorView
{
    if (!VALID_NOTEMPTY(_separatorView, UIView)) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0, self.height - 1.0f, self.width, 1.0f)];
        _separatorView.backgroundColor = JABlack400Color;
        [self addSubview:_separatorView];
    }
    return _separatorView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.f, 0.f, 320.f, 100.f)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.titleLabel setFrame:CGRectMake(16.0f, 10.0f, self.width - 16.0f*2, 20)];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.subTitleLabel setFrame:CGRectMake(16.0f, 30.0f, self.width - 16.f*2, 60)];
    [self.subTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.separatorView setFrame:CGRectMake(16.0f, self.height - 1.0f, self.width, 1.0f)];
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.titleLabel flipViewAlignment];
        [self.subTitleLabel flipViewAlignment];
        [self.separatorView flipViewPositionInsideSuperview];
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    [self.titleLabel setText:field.label];
    [self.subTitleLabel setText:field.subLabel];
    [self.subTitleLabel sizeToFit];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              CGRectGetMaxY(self.subTitleLabel.frame) + 30.0f)];
}



@end
