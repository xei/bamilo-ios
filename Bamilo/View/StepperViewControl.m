//
//  StepperViewControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "StepperViewControl.h"
#import "StepperView.h"

@interface StepperViewControl()
@property (nonatomic, strong) StepperView *stepperView;
@end

@implementation StepperViewControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.stepperView = [[[NSBundle mainBundle] loadNibNamed:@"StepperView" owner:self options:nil] lastObject];
    self.stepperView.controller = self;
    [self addSubview:self.stepperView];
    self.stepperView.frame = self.bounds;
}

- (void)setQuantity:(int)quantity {
    self.stepperView.quantity = quantity;
}

- (void)setMaxQuantity:(int)maxQuantity {
    self.stepperView.maxQuantity = maxQuantity;
}

- (void)setMinQuantity:(int)minQuantity {
    self.stepperView.minQuantity = minQuantity;
}

@end
