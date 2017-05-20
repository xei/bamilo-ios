//
//  JAPriceFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 10/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceFiltersView.h"
#import "TTRangeSlider.h"
#import "NSString+Extensions.h"

@interface JAPriceFiltersView()

@property (weak, nonatomic) IBOutlet TTRangeSlider *priceRangeSlider;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textsInPriceRangeUILabels;
@property (weak, nonatomic) IBOutlet UITextField *lowerSelectedPriceUITextField;
@property (weak, nonatomic) IBOutlet UITextField *upperSelectedPriceUITextField;
@property (nonatomic, strong) SearchPriceFilter* priceFilter;

@end

@implementation JAPriceFiltersView

- (void)initializeWithPriceFilterOption:(SearchPriceFilter*)priceFilter {
    self.priceFilter = priceFilter;
    self.backgroundColor = [UIColor whiteColor];
    
    self.priceRangeSlider.step = self.priceFilter.interval;
    
    self.priceRangeSlider.maxValue = self.priceFilter.maxPrice;
    self.priceRangeSlider.minValue = self.priceFilter.minPrice;
    self.priceRangeSlider.hideLabels = YES;
    self.priceRangeSlider.handleDiameter = 28.0;
    
    //found out the hard way that self.priceRangeSlider.upperValue has to be set before self.priceRangeSlider.lowerValue
    self.priceRangeSlider.selectedMaximum = self.priceFilter.upperValue;
    self.priceRangeSlider.selectedMinimum = self.priceFilter.lowerValue;
    self.priceRangeSlider.delegate = self;
    
    self.priceRangeSlider.hideLabels = YES;
    self.priceRangeSlider.handleBorderWidth = 1;
    self.priceRangeSlider.handleColor = [UIColor whiteColor];
    
    
    for (UILabel *label in self.textsInPriceRangeUILabels) {
        label.font = [UIFont fontWithName:kFontRegularName size: 12];
    }
    
    self.upperSelectedPriceUITextField.text = [[[NSString stringWithFormat:@"%.0ld", (long)self.priceFilter.upperValue] formatPrice] numbersToPersian];
    
    NSString *lowerValue = [[[NSString stringWithFormat:@"%.0ld", (long)self.priceFilter.lowerValue] formatPrice] numbersToPersian];
    self.lowerSelectedPriceUITextField.text = lowerValue.length ? lowerValue : @"۰";
    
    self.upperSelectedPriceUITextField.delegate = self;
    self.lowerSelectedPriceUITextField.delegate = self;
}

- (void)saveOptions {
    //Save selection in filter
    self.priceFilter.lowerValue = self.priceRangeSlider.selectedMinimum;
    self.priceFilter.upperValue = self.priceRangeSlider.selectedMaximum;
    
    [super saveOptions];
}

- (IBAction)textFieldEditingDidEnd:(UITextField *)sender {
    NSString *senderValueString = [sender.text getPriceStringFromFormatedPrice];
    NSString *lowerTextFieldValue = [self.lowerSelectedPriceUITextField.text getPriceStringFromFormatedPrice];
    NSString *upperTextFieldValue = [self.upperSelectedPriceUITextField.text getPriceStringFromFormatedPrice];
    
    float validateValue = MAX(self.priceFilter.minPrice, MIN(self.priceFilter.maxPrice, senderValueString.intValue));
    float valueToBeSet;
    if (sender == self.upperSelectedPriceUITextField) {
        valueToBeSet = MAX(validateValue, lowerTextFieldValue.intValue);
        self.priceRangeSlider.selectedMaximum = valueToBeSet;
    } else  {
        valueToBeSet = MIN(validateValue, upperTextFieldValue.intValue);
        self.priceRangeSlider.selectedMinimum = valueToBeSet;
    }
    
    sender.text = [[[NSString stringWithFormat:@"%.0f", valueToBeSet] formatPrice] numbersToPersian];
    [self saveOptions];
}

- (IBAction)textFieldEditingDidChanged:(UITextField *)sender {
    NSString *pureNumbers = [sender.text getPriceStringFromFormatedPrice];
    sender.text = [[pureNumbers formatPrice] numbersToPersian];
}

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {
    if (sender == self.priceRangeSlider) {
        self.lowerSelectedPriceUITextField.text = [[[NSString stringWithFormat:@"%.0f", selectedMinimum] formatPrice] numbersToPersian];
        self.upperSelectedPriceUITextField.text = [[[NSString stringWithFormat:@"%.0f", selectedMaximum] formatPrice] numbersToPersian];
    }
    [self saveOptions];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSRange illegalCharacterEntered = [string rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if ( illegalCharacterEntered.location != NSNotFound ) {
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.upperSelectedPriceUITextField endEditing:true];
    [self.lowerSelectedPriceUITextField endEditing:true];
}

@end
