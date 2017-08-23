//
//  StepperView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "StepperView.h"
#import "NSString+Extensions.h"

@interface StepperView()
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *minusBtn;
@end

@implementation StepperView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.label.text = @"۰";
    [self.label setFont:[Theme font:kFontVariationRegular size:11]];
    [self.label setTextColor:[Theme color:kColorPrimaryGray1]];
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
    [self.minusBtn setTitleColor:[Theme color:kColorPrimaryGray1] forState:UIControlStateNormal];
    [self.plusBtn setTitleColor:[Theme color:kColorPrimaryGray1] forState:UIControlStateNormal];
    
    if (self.quantity == self.maxQuantity) {
        [self.plusBtn setTitleColor:[Theme color:kColorExtraLightGray] forState:UIControlStateNormal];
    }
    if (self.quantity == self.minQuantity) {
        [self.minusBtn setTitleColor:[Theme color:kColorExtraLightGray] forState:UIControlStateNormal];
    }
}

@end
