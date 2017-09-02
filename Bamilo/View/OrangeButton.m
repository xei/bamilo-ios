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
    
    [self setBackgroundColor:[Theme color:kColorOrange1]];
    [self.titleLabel applyStyle:[Theme font:kFontVariationBold size:15] color:[Theme color:kColorOrange]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
