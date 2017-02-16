//
//  BaseViewControl.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewControl.h"

@implementation BaseViewControl

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateWithModel:(id)model {
    return;
}

@end
