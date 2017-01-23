//
//  JAPriceFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 10/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceFiltersView.h"
#import "TTRangeSlider.h"

@interface JAPriceFiltersView()

@property (weak, nonatomic) IBOutlet TTRangeSlider *priceRangeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *discountSwitch;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textsInPriceRangeUILabels;

@property (weak, nonatomic) IBOutlet UITextField *lowerSelectedPriceUITextField;
@property (weak, nonatomic) IBOutlet UITextField *upperSelectedPriceUITextField;

@property (nonatomic, strong)RIFilterOption* priceFilterOption;

@end

@implementation JAPriceFiltersView

- (void)initializeWithPriceFilterOption:(RIFilterOption*)priceFilterOption {
    self.priceFilterOption = priceFilterOption;
    
    self.backgroundColor = [UIColor whiteColor];
    self.discountLabel.font = JAListFont;
    self.discountLabel.textColor = JAButtonTextOrange;
    
    self.priceRangeSlider.step = self.priceFilterOption.interval;
    
    self.priceRangeSlider.maxValue = self.priceFilterOption.max;
    self.priceRangeSlider.minValue = self.priceFilterOption.min;
    self.priceRangeSlider.hideLabels = YES;
    
    //found out the hard way that self.priceRangeSlider.upperValue has to be set before self.priceRangeSlider.lowerValue
    self.priceRangeSlider.selectedMaximum = self.priceFilterOption.upperValue;
    self.priceRangeSlider.selectedMinimum = self.priceFilterOption.lowerValue;
    self.priceRangeSlider.delegate = self;
    
    self.priceRangeSlider.hideLabels = YES;
    self.priceRangeSlider.handleBorderWidth = 1;
    self.priceRangeSlider.handleColor = [UIColor whiteColor];
    
    self.discountLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.discountLabel.text = STRING_WITH_DISCOUNT_ONLY;
    [self.discountLabel sizeToFit];
    self.discountSwitch.on = self.priceFilterOption.discountOnly;
    [self.discountSwitch setAccessibilityLabel:STRING_WITH_DISCOUNT_ONLY];
    [self.discountSwitch addTarget:self action:@selector(switchMoved:) forControlEvents:UIControlEventTouchUpInside];
    
    self.discountSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.frame = CGRectMake(16.0f, (self.frame.size.height - self.contentView.frame.size.width)/2, self.contentView.frame.size.width, self.contentView.frame.size.height);
//    if (RI_IS_RTL) {
//        //[self flipAllSubviews];
//    }
    
    for (UILabel *label in self.textsInPriceRangeUILabels) {
        label.font = [UIFont fontWithName:kFontRegularName size: 13];
    }
    
    self.upperSelectedPriceUITextField.text = [NSString stringWithFormat:@"%.0ld", (long)self.priceFilterOption.upperValue];
    
    NSString *lowerValue = [NSString stringWithFormat:@"%.0ld", (long)self.priceFilterOption.lowerValue];
    self.lowerSelectedPriceUITextField.text = lowerValue.length ? lowerValue : @"0";
}

- (void)reload {
    self.contentView.frame = CGRectMake(16.0f, (self.frame.size.height - self.contentView.frame.size.width)/2,
                                        self.contentView.frame.size.width,
                                        self.contentView.frame.size.height);
    if (RI_IS_RTL) {
        [self.contentView flipViewPositionInsideSuperview];
    }
}

- (void)saveOptions {
    //save selection in filter
    self.priceFilterOption.lowerValue = self.priceRangeSlider.selectedMinimum;
    self.priceFilterOption.upperValue = self.priceRangeSlider.selectedMaximum;
    self.priceFilterOption.discountOnly = self.discountSwitch.on;
    
    [super saveOptions];
}

- (IBAction)textFieldEditingChaned:(UITextField *)sender {
    float validateValue = MAX(self.priceFilterOption.min, MIN(self.priceFilterOption.max, sender.text.floatValue));
    if (sender == self.upperSelectedPriceUITextField) {
        float valueToBeSet = MAX(validateValue, self.lowerSelectedPriceUITextField.text.floatValue);
        self.priceRangeSlider.selectedMaximum = valueToBeSet;
        sender.text = [NSString stringWithFormat:@"%.0f", valueToBeSet];
    } else  {
        float valueToBeSet = MIN(validateValue, self.upperSelectedPriceUITextField.text.floatValue);
        self.priceRangeSlider.selectedMinimum = valueToBeSet;
        sender.text = [NSString stringWithFormat:@"%.0f", valueToBeSet];
    }
    
}

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {
    if (sender == self.priceRangeSlider) {
        self.lowerSelectedPriceUITextField.text = [NSString stringWithFormat:@"%.0f", selectedMinimum];
        self.upperSelectedPriceUITextField.text = [NSString stringWithFormat:@"%.0f", selectedMaximum];
    }
    
    [self saveOptions];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.upperSelectedPriceUITextField endEditing:true];
    [self.lowerSelectedPriceUITextField endEditing:true];
}

- (void)switchMoved:(id)sender {
    [self saveOptions];
}

@end
