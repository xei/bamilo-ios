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

#pragma mark - Private Methods
-(void) setupButtonAppearance {
    [self.titleLabel setFont:[UIFont fontWithName:kFontBoldName size:15]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
