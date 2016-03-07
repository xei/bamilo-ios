//
//  JATitleComponent.m
//  Jumia
//
//  Created by telmopinto on 09/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JATitleComponent.h"

@interface JATitleComponent ()

@property (strong, nonatomic) UILabel *titleLabel;

@end


@implementation JATitleComponent

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, self.width - 16.0*2, 20.0f)];
        [_titleLabel setTextColor:JABlackColor];
        [_titleLabel setFont:JACaption2Font];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.f, 0, 320.f, 48.f)];
        self.backgroundColor = JABlack200Color;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self.titleLabel setFrame:CGRectMake(16.0f,
                                         (self.height - 20.0f) / 2,
                                         self.width - 16.0f*2,
                                         20.0f)];
    if (self.iconImageView) {
        [self.iconImageView setY:self.y + self.titleLabel.y + (self.titleLabel.height - self.iconImageView.height)/2];
    }
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.titleLabel flipViewAlignment];
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    [self.titleLabel setText:field.label];
}

@end
