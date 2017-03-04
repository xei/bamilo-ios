//
//  StepperView.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "StepperView.h"
#import "NSString+Extensions.h"

#define cDARK_GRAY_COLOR [UIColor withRepeatingRGBA:115 alpha:1.0f]
#define cBlue_Color [UIColor withHexString:@"4A90E2"]
#define cEXTRA_LIGHT_GRAY_COLOR [UIColor withRepeatingRGBA:186 alpha:1.0f]

@interface StepperView()
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *minusBtn;
@end

@implementation StepperView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.label.text = @"۰";
    [self.label setTextColor:cBlue_Color];
}

- (IBAction)IncrementBtnTapped:(id)sender {
    float result = [self.label.text floatValue] + 1;
    if (result > self.maxQuantity) {
        [self.controller.delegate wantsToBeMoreThanMax:self.controller];
    }
    result = self.maxQuantity ? (result <= self.maxQuantity ? result : self.maxQuantity ) : result;
    [self updateUIWithValue: result];
    [self resetBtnsColor];
}

- (IBAction)decrementBtnTapped:(id)sender {
    float result = [self.label.text floatValue] - 1;
    if (result < self.minQuantity) {
        [self.controller.delegate wantsToBeLessThanMin:self.controller];
    }
    result = result > self.minQuantity ? result : self.minQuantity;
    [self updateUIWithValue: result];
    [self resetBtnsColor];
}

- (void)updateUIWithValue:(int) newValue {
    self.label.text = [[NSString stringWithFormat:@"%d", newValue] numbersToPersian];
    int previousQuanitity = self.quantity;
    self.quantity = newValue;
    if (previousQuanitity != self.quantity)
    [self.controller.delegate valueHasBeenChanged:self.controller withNewValue: newValue];
}

- (void)setQuantity:(int)quantity {
    _quantity = quantity;
    self.label.text = [[NSString stringWithFormat:@"%d", quantity] numbersToPersian];
    [self resetBtnsColor];
}

- (void)setMaxQuantity:(int)maxQuantity {
    _maxQuantity = maxQuantity;
    self.label.text = self.label.text.floatValue <= maxQuantity ? self.label.text : [NSString stringWithFormat:@"%d", maxQuantity];
    [self resetBtnsColor];
}

- (void)setMinQuantity:(int)minQuantity {
    _minQuantity = minQuantity ?: 1;
    self.label.text = self.label.text.floatValue >= _minQuantity ? self.label.text : [NSString stringWithFormat:@"%d", _minQuantity];
    [self resetBtnsColor];
}

- (void)resetBtnsColor {
    [self.minusBtn setTitleColor:cBlue_Color forState:UIControlStateNormal];
    [self.plusBtn setTitleColor:cBlue_Color forState:UIControlStateNormal];
    
    if (self.quantity == self.maxQuantity) {
        [self.plusBtn setTitleColor:cEXTRA_LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    }
    if (self.quantity == self.minQuantity) {
        [self.minusBtn setTitleColor:cEXTRA_LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    }
}

@end
