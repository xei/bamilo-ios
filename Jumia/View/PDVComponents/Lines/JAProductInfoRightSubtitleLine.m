//
//  JAProductInfoRightSubtitleLine.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoRightSubtitleLine.h"

#define kTopMargin 16.f

@interface JAProductInfoRightSubtitleLine ()

@property (nonatomic, strong) UILabel *rightTitleLabel;
@property (nonatomic, strong) UILabel *rightSubTitleLabel;

@end

@implementation JAProductInfoRightSubtitleLine

- (UILabel *)rightTitleLabel
{
    if (!VALID(_rightTitleLabel, UILabel)) {
        _rightTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTopMargin, self.width, 16)];
        [_rightTitleLabel setFont:JACaptionFont];
        [_rightTitleLabel setTextColor:JABlackColor];
        [self addSubview:_rightTitleLabel];
    }
    return _rightTitleLabel;
}

- (UILabel *)rightSubTitleLabel
{
    if (!VALID(_rightSubTitleLabel, UILabel)) {
        _rightSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.rightTitleLabel.frame), self.width, 16)];
        [_rightSubTitleLabel setFont:JACaptionFont];
        [_rightSubTitleLabel setTextColor:JABlack800Color];
        [self addSubview:_rightSubTitleLabel];
    }
    return _rightSubTitleLabel;
}

- (void)setRightTitle:(NSString *)rightTitle
{
    _rightTitle = rightTitle;
    [self.rightTitleLabel setWidth:self.width];
    [self.rightTitleLabel setText:rightTitle];
    [self.rightTitleLabel sizeToFit];
    [self.rightTitleLabel setHeight:16.f];
    [self.rightTitleLabel setXRightAligned:16.f];
    if (self.rightSubTitle) {
        [self.rightTitleLabel setY:kTopMargin];
    }else{
        [self.rightTitleLabel setYCenterAligned];
    }
}

- (void)setRightSubTitle:(NSString *)rightSubTitle
{
    _rightSubTitle = rightSubTitle;
    [self.rightSubTitleLabel setWidth:self.width];
    [self.rightSubTitleLabel setText:rightSubTitle];
    [self.rightSubTitleLabel sizeToFit];
    [self.rightSubTitleLabel setHeight:16.f];
    [self.rightSubTitleLabel setXRightAligned:16.f];
    
    [self.rightTitleLabel setY:kTopMargin];

}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.rightTitleLabel setXRightAligned:self.lineContentXOffset + (self.enabled?16.f:0.0f)];
    [self.rightSubTitleLabel setXRightAligned:self.lineContentXOffset + (self.enabled?16.f:0.0f)];
}

@end
