//
//  BaseButton.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseButton.h"

@implementation BaseButton

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

#pragma mark - Public Methods
-(void) setupButtonAppearance {
    return;
}

@end
