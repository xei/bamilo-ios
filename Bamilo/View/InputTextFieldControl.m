//
//  InputTextFieldControl.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextFieldControl.h"
#import "UILabel+WhiteUIDatePickerLabels.h"
#import "ThreadManager.h"

@interface InputTextFieldControl() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, copy) NSString *errorMsg;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
@property (nonatomic, strong) UIDatePicker *datepicker;
@end

@implementation InputTextFieldControl

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.barStyle = UIBarStyleDefault;
        _toolBar.translucent = YES;
        _toolBar.tintColor = [UIColor colorWithRed:76/255 green:217/255 blue:100/255 alpha:1];
        [_toolBar sizeToFit];
        
        UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        _toolBar.items = [NSArray arrayWithObjects: flexible, self.doneBtn, nil];
        [_toolBar setUserInteractionEnabled:YES];
    }
    return _toolBar;
}

- (UIDatePicker *)datepicker {
    if (!_datepicker) {
        _datepicker = [UIDatePicker new];
        _datepicker.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
        _datepicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fa_IR"];
        _datepicker.datePickerMode = UIDatePickerModeDate;
        _datepicker.backgroundColor = [UIColor whiteColor];
        _datepicker.maximumDate = [NSDate new];
    }
    return _datepicker;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (UIBarButtonItem *)doneBtn {
    if (!_doneBtn){
        _doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"تایید" style:UIBarButtonItemStylePlain target:self action:@selector(donePicker)];
        [_doneBtn setTitleTextAttributes:@{
                             NSFontAttributeName: JAListFont,
                             NSForegroundColorAttributeName: [UIColor blackColor]
                             } forState:UIControlStateNormal];
    }
    return _doneBtn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.input = [InputTextField nibInstance];
    [self addSubview:self.input];
    self.input.frame = self.bounds;
    
    [self.input.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.input.textField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEnd];
    [self.input.textField addTarget:self action:@selector(textFieldEditingDidEnditingBegan:) forControlEvents:UIControlEventEditingDidBegin];
}

- (void)setType:(InputTextFieldControlType) type {
    self.input.textField.secureTextEntry = NO;
    [self.input updateDropDownAppearance:YES];
    switch (type) {
        case InputTextFieldControlTypePassword:
            self.input.textField.keyboardType = UIKeyboardTypeDefault;
            self.input.textField.secureTextEntry = YES;
            break;
        case InputTextFieldControlTypeNumerical:
            self.input.textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case InputTextFieldControlTypeEmail:
            self.input.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case InputTextFieldControlTypeOptions:
            [self.input updateDropDownAppearance:NO];
            break;
        default:
            self.input.textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
    _type = type;
}


- (void)updateModel {
    if (![self.model.inputTextValue isEqualToString:[self getStringValue]]) {
        self.model.inputTextValue = [self getStringValue];
        [self.delegate inputValueChanged:self byNewValue:[self getStringValue] inFieldIndex:self.fieldIndex];
    }
}

- (void)setModel:(FormItemModel *)model {
    _model = model;
    [self.input resetSeperator];
    
    //update UI
    self.input.icon.image = model.icon;
    self.input.textField.placeholder = model.placeholder;
    self.validation = model.validation;
    [self setType: model.type];
    self.input.textField.enabled = YES;
    
    if (model.icon) {
        self.input.hasIcon = YES;
    } else {
        self.input.hasIcon = NO;
    }
    
    if (model.inputTextValue.length) {
        self.input.textField.text = (model.type == InputTextFieldControlTypeNumerical) ? [model.inputTextValue numbersToPersian] : model.inputTextValue;
        [self checkValidation];
    } else {
        self.input.textField.text = nil;
    }

    if (model.selectOption) {
        self.type = InputTextFieldControlTypeOptions;
        //when we have only one option!
        if (model.selectOption.count == 1) {
            model.inputTextValue = model.selectOption.allKeys.firstObject;
            self.input.textField.enabled = NO;
            [self.input showDisabledMode];
        }
        //if we have no options for selection 
        if (model.selectOption.count == 0) {
            self.input.textField.enabled = NO;
            [self.input showDisabledMode];
        }
    } else if (self.type == InputTextFieldControlTypeOptions) {
        //When we have no selectOption model but it's `Option` type
        self.input.textField.enabled = NO;
        [self.input showDisabledMode];
    }
    
    if (model.lastErrorMessage.length) {
        [self showErrorMsg:model.lastErrorMessage];
    }
}

- (void)updateModel:(FormItemModel *(^)(FormItemModel *))updateBlock {
    FormItemModel *model = self.model;
    [self setModel:updateBlock(model)];
}
    
- (void)checkValidation {
    if ([self isValid]) {
        [self.input clearError];
    } else {
        [self showErrorMsg:self.errorMsg];
    }
}


- (NSString *)getStringValue {
        return self.input.textField.text;
}

- (void)showErrorMsg:(NSString *)msg {
    self.model.lastErrorMessage = msg;
    [self.input showErrorMsg:msg];
}

- (Boolean)isValid {
    FormValidationType *validationResult = [self.validation checkValiditionOfString:[[self getStringValue] numbersToEnglish]];
    self.errorMsg = validationResult.errorMsg;
    return self.validation ? validationResult.boolValue : YES; 
}


- (void)donePicker {
    if (self.type == InputTextFieldControlTypeOptions) {
        if ((self.input.textField.text == nil || [self.input.textField.text isEqualToString:@""]) && self.model.selectOption.allKeys.count) {
            self.input.textField.text = self.model.selectOption.allKeys[0];
        }
    } else if (self.type == InputTextFieldControlTypeDatePicker) {
        self.input.textField.text = [self.model.visibleDateFormat stringFromDate:self.datepicker.date];
    }
    
    [self.input.textField resignFirstResponder];
}

- (void)resetAndClear {
    self.input.textField.text = nil;
    self.input.textField.inputView = nil;
    [self.input.textField reloadInputViews];
    [self.input clearError];
}

#pragma mark - textFieldTargetActions
- (void)textFieldEditingDidEndOnExit:(UITextField *)textField {
    [self updateModel];
    [self checkValidation];
}

- (void)textFieldEditingDidEnditingBegan:(UITextField *)textField {
    [self.input clearError];
    self.model.lastErrorMessage = nil;
    if (self.type == InputTextFieldControlTypeOptions) {
        textField.inputView = self.pickerView;
        textField.inputAccessoryView = self.toolBar;
        if (self.model.inputTextValue && [self.model.selectOption.allKeys containsObject:self.model.inputTextValue]) {
            [self.pickerView selectRow:[self.model.selectOption.allKeys indexOfObject:self.model.inputTextValue] inComponent:0 animated:NO];
        }
    } else if (self.type == InputTextFieldControlTypeDatePicker) {
        textField.inputView = self.datepicker;
        textField.inputAccessoryView = self.toolBar;
        textField.text = self.model.inputTextValue;
    }
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    if (self.type == InputTextFieldControlTypeNumerical) {
        textField.text = [textField.text numbersToPersian];
    }
}


#pragma mark - UIPickerViewDataSource and Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.input.textField.text = self.model.selectOption.allKeys[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* titleView = (UILabel*)view;
    if (!titleView) {
        titleView = [[UILabel alloc] init];
        [titleView setFont: JAListFont];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.numberOfLines = 3;
    }
    if (row < self.model.selectOption.allKeys.count) {
        titleView.text = self.model.selectOption.allKeys[row];
    }
    return titleView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.model.selectOption.allKeys.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
