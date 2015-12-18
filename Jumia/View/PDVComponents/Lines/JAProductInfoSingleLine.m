//
//  JAProductInfoSingleLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSingleLine.h"

@interface JAProductInfoSingleLine ()

@end

@implementation JAProductInfoSingleLine

-(UILabel *)lineLabel {
    if(!VALID_NOTEMPTY(_lineLabel, UILabel)) {
        _lineLabel = [UILabel new];
        [_lineLabel setFont:JAList2Font];
        [_lineLabel setTextColor:JABlackColor];
        [_lineLabel setFrame:CGRectMake(self.lineContentXOffset, 0.f,
                                        self.width - self.lineContentXOffset, self.height)];
        [_lineLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_lineLabel];
    }
    return _lineLabel;
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

- (void)setDefaults
{
    [self setTopSeparatorVisibility:YES];
    [self setTopSeparatorXOffset:self.label.x];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)sizeToFit
{
    [self setWidth:CGRectGetMaxX(self.label.frame)];
    [self setHeight:self.label.height];
    [self.lineLabel setYCenterAligned];
}

-(void)setText:(NSString *)txt {
    [self.lineLabel setText:txt];
}

@end
