//
//  OrangeButton.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrangeButton.h"

#define cEXTRA_DARK_GRAY_COLOR [UIColor withRGBA:80 green:80 blue:80 alpha:1.0f]
#define cORAGNE_COLOR [UIColor withRGBA:255 green:153 blue:0 alpha:1.0f]

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
    
    [self setBackgroundColor:cORAGNE_COLOR];
    [self.titleLabel applyStyle:kFontBoldName fontSize:15 color: cORAGNE_COLOR];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


@end
