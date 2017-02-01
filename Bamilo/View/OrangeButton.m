//
//  OrangeButton.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrangeButton.h"

@implementation OrangeButton

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setupButtonAppearance];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupButtonAppearance];
}

-(void)setupButtonAppearance {
    [super setupButtonAppearance];
    
    [self setBackgroundColor:[UIColor withRGBA:247 green:151 blue:32 alpha:1.0f]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
