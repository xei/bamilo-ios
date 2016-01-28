//
//  JAProductInfoSubtitleLine.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSubtitleLine.h"
#import "UIImageView+WebCache.h"

#define kTopMargin 16.f
#define kBottomMargin 16.f

@interface JAProductInfoSubtitleLine ()

@property (nonatomic, strong) UILabel *titleLineLabel;
@property (nonatomic, strong) UILabel *subTitleLineLabel;
@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation JAProductInfoSubtitleLine

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
    [self setTopSeparatorVisibility:YES];
    [self setTopSeparatorXOffset:self.label.x];
}

- (UILabel *)titleLineLabel
{
    if (!VALID(_titleLineLabel, UILabel)) {
        _titleLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineContentXOffset, kTopMargin, self.width, 16.f)];
        [_titleLineLabel setFont:JAList2Font];
        [_titleLineLabel setTextColor:JABlackColor];
        [self addSubview:_titleLineLabel];
    }
    return _titleLineLabel;
}

- (UILabel *)subTitleLineLabel
{
    if (!VALID(_subTitleLineLabel, UILabel)) {
        _subTitleLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineContentXOffset, CGRectGetMaxY(self.titleLineLabel.frame), self.width, 16.f)];
        [_subTitleLineLabel setFont:JACaptionFont];
        [_subTitleLineLabel setTextColor:JABlack800Color];
        [self addSubview:_subTitleLineLabel];
    }
    return _subTitleLineLabel;
}

- (UIImageView *)rightImageView
{
    if (!VALID(_rightImageView, UIImageView)) {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-51-16.f-self.lineContentXOffset, 0, 51, 36)];
        [self addSubview:_rightImageView];
    }
    return _rightImageView;
}

- (UILabel *)titleLabel
{
    return self.titleLineLabel;
}

- (void)setImageWithURL:(NSString *)URL
{
    [self.rightImageView setImageWithURL:[NSURL URLWithString:URL]];
    [self.rightImageView setYCenterAligned];
    [self.rightImageView setX:self.width-self.rightImageView.width-16.f-self.lineContentXOffset];
}

- (void)setTitle:(NSString *)title
{
    [self.label setHidden:YES];
    [self.titleLineLabel setText:title];
    [self.titleLineLabel sizeToFit];
}

- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    [self.label setHidden:YES];
    [self.subTitleLineLabel setText:subTitle];
    CGFloat height = self.subTitleLineLabel.height;
    [self.subTitleLineLabel sizeToFit];
    [self.subTitleLineLabel setHeight:height];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.rightImageView setXRightAligned:16.f+self.lineContentXOffset];
    [self.titleLineLabel setX:16.f];
    [self.subTitleLineLabel setX:16.f];
}

@end
