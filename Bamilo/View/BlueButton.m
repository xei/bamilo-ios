//
//  BlueButton.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BlueButton.h"
#define cBLUE_COLOR [UIColor withHexString:@"4A90E2"]


@implementation BlueButton

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
    [self setBackgroundColor:cBLUE_COLOR];
    [self.titleLabel applyStyle:kFontBoldName fontSize:15 color: cBLUE_COLOR];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
