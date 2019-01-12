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
#import "Bamilo-Swift.h"

@interface JAPriceFiltersView()

@property (weak, nonatomic) IBOutlet TTRangeSlider *priceRangeSlider;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textsInPriceRangeUILabels;
@property (weak, nonatomic) IBOutlet UITextField *lowerSelectedPriceUITextField;
@property (weak, nonatomic) IBOutlet UITextField *upperSelectedPriceUITextField;
@property (nonatomic, strong) CatalogPriceFilterItem* priceFilter;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *currencyLabels;

@end

@implementation JAPriceFiltersView

- (void)initializeWithPriceFilterOption:(CatalogPriceFilterItem *)priceFilter {
    self.priceFilter = priceFilter;
    self.backgroundColor = [UIColor whiteColor];
    
    self.priceRangeSlider.step = self.priceFilter.interval;
    
    self.priceRangeSlider.maxValue = self.priceFilter.maxPrice / 10;
    self.priceRangeSlider.minValue = self.priceFilter.minPrice / 10;
    self.priceRangeSlider.hideLabels = YES;
    self.priceRangeSlider.handleDiameter = 28.0;
    
    //found out the hard way that self.priceRangeSlider.upperValue has to be set before self.priceRangeSlider.lowerValue
    self.priceRangeSlider.selectedMaximum = self.priceFilter.upperValue / 10; //convert to Tomans
    self.priceRangeSlider.selectedMinimum = self.priceFilter.lowerValue / 10; //convert to Tomans
    self.priceRangeSlider.delegate = self;
    
    self.priceRangeSlider.hideLabels = YES;
    self.priceRangeSlider.handleBorderWidth = 1;
    self.priceRangeSlider.handleColor = [UIColor whiteColor];
    
    
    for (UILabel *label in self.textsInPriceRangeUILabels) {
        label.font = [UIFont fontWithName:kFontRegularName size: 12];
    }
    
    self.upperSelectedPriceUITextField.text = [[[NSString stringWithFormat:@"%.0ld", (long)self.priceRangeSlider.selectedMaximum] formatPrice] numbersToPersian];
    
    NSString *lowerValue = [[[NSString stringWithFormat:@"%.0ld", (long)self.priceRangeSlider.selectedMinimum] formatPrice] numbersToPersian];
    self.lowerSelectedPriceUITextField.text = lowerValue.length ? lowerValue : @"۰";
    
    self.upperSelectedPriceUITextField.delegate = self;
    self.lowerSelectedPriceUITextField.delegate = self;
    
    [self.currencyLabels enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.text = STRING_CURRENCY;
    }];
}

- (void)saveOptions {
    //Save selection in filter
    self.priceFilter.lowerValue = self.priceRangeSlider.selectedMinimum * 10; //conversion to Rials
    self.priceFilter.upperValue = self.priceRangeSlider.selectedMaximum * 10; //conversion to Rials
    
    [super saveOptions];
}

- (IBAction)textFieldEditingDidEnd:(UITextField *)sender {
    NSString *senderValueString = [sender.text getPriceStringFromFormatedPrice];
    NSString *lowerTextFieldValue = [self.lowerSelectedPriceUITextField.text getPriceStringFromFormatedPrice];
    NSString *upperTextFieldValue = [self.upperSelectedPriceUITextField.text getPriceStringFromFormatedPrice];
    
    float validateValue = MAX(self.priceRangeSlider.minValue, MIN(self.priceRangeSlider.maxValue, senderValueString.intValue));
    float valueToBeSet;
    if (sender == self.upperSelectedPriceUITextField) {
        valueToBeSet = MAX(validateValue, lowerTextFieldValue.intValue);
        self.priceRangeSlider.selectedMaximum = valueToBeSet;
    } else  {
        valueToBeSet = MIN(validateValue, upperTextFieldValue.intValue);
        self.priceRangeSlider.selectedMinimum = valueToBeSet;
    }
    
    sender.text =  [[[NSString stringWithFormat:@"%.0f", valueToBeSet] formatPrice] numbersToPersian];
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
