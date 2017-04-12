//
//  BlueButton.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BlueButton.h"

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
    [self setBackgroundColor:[Theme color:kColorBlue]];
    [self.titleLabel applyStyle:[Theme font:kFontVariationBold size:15] color:[Theme color:kColorBlue]];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
