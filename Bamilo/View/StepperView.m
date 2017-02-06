//
//  StepperView.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "StepperView.h"
#import "NSString+Extensions.h"

@interface StepperView()
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation StepperView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.label.text = @"۰";
}

- (IBAction)IncrementBtnTapped:(id)sender {
    float result = [self.label.text floatValue] + 1;
    result = self.maxQuantity ? (result <= self.maxQuantity ? result : self.maxQuantity ) : result;
    [self updateUIWithValue: result];
}

- (IBAction)decrementBtnTapped:(id)sender {
    float result = [self.label.text floatValue] - 1;
    result = result > self.minQuantity ? result : 0;
    [self updateUIWithValue: result];
}

- (void)updateUIWithValue:(int) newValue {
    self.label.text = [[NSString stringWithFormat:@"%d", newValue] numbersToPersian];
    self.quantity = newValue;
    [self.controller.delegate valueHasBeenChanged:self withNewValue: newValue];
}

- (void)setQuantity:(int)quantity {
    _quantity = quantity;
    self.label.text = [[NSString stringWithFormat:@"%d", quantity] numbersToPersian];
}

- (void)setMaxQuantity:(int)maxQuantity {
    _maxQuantity = maxQuantity;
    self.label.text = self.label.text.floatValue <= maxQuantity ? self.label.text : [NSString stringWithFormat:@"%d", maxQuantity];
}

- (void)setMinQuantity:(int)minQuantity {
    _minQuantity = minQuantity ?: 1;
    self.label.text = self.label.text.floatValue >= _minQuantity ? self.label.text : [NSString stringWithFormat:@"%d", _minQuantity];
}

@end
