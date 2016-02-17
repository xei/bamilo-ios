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

    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.titleLabel flipViewAlignment];
        [self.subTitleLabel flipViewAlignment];
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
                              CGRectGetMaxY(self.subTitleLabel.frame))];
}



@end
