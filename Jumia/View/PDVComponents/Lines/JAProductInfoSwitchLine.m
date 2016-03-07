//
//  JAProductInfoSwitchLine.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSwitchLine.h"

@implementation JAProductInfoSwitchLine

- (UISwitch *)lineSwitch
{
    if (!VALID(_lineSwitch, UISwitch)) {
        _lineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.width - 100, 0, 100, self.height)];
        [self addSubview:_lineSwitch];
    }
    return _lineSwitch;
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
    [self.lineSwitch setXRightAligned:16.f];
    [self.lineSwitch setHeight:self.height];
    [self.lineSwitch setYCenterAligned];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setDefaults];
}

@end
