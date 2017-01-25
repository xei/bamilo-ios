//
//  JAProductInfoSISLine.m
//  Jumia
//
//  Created by lucianoduarte on 25/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSISLine.h"

#define kImageHeight 22

@interface JAProductInfoSISLine ()

@end

@implementation JAProductInfoSISLine

-(UIImageView *)sisImageView {
    if(!VALID_NOTEMPTY(_sisImageView, UIImageView)) {
        _sisImageView = [UIImageView new];
        [_sisImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_sisImageView setFrame:CGRectMake(self.lineContentXOffset,
                                           (kProductInfoSISLineHeight/2) - (kImageHeight/2),
                                           0.f,
                                           kImageHeight)];
        [self addSubview:_sisImageView];
    }
    return _sisImageView;
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
    [self.label setFont:JABodyFont];
    [self.label setTextColor:JABlue1Color];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

@end
