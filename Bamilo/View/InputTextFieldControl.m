//
//  InputTextFieldControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextFieldControl.h"

@interface InputTextFieldControl() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, copy) NSString *errorMsg;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *doneBtn;
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
    
    self.input = [[[NSBundle mainBundle] loadNibNamed:@"InputTextField" owner:self options:nil] lastObject];
    [self addSubview:self.input];
    self.input.frame = self.bounds;
    
    [self.input.textField addTarget:self action:@selector(textFieldEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEnd];
    [self.input.textField addTarget:self action:@selector(textFieldEditingDidEnditingBegan:) forControlEvents:UIControlEventEditingDidBegin];
}

- (void)setType:(InputTextFieldControlType) type {
    self.input.textField.secureTextEntry = NO;
    [self.input hideDropDownIcon];
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
            [self.input showDropDownIcon];
            break;
        default:
            self.input.textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
    _type = type;
}


- (void)updateModel {
    if (![self.model.titleString isEqualToString:[self getStringValue]]) {
        self.model.titleString = [self getStringValue];
        [self.delegate inputValueHasBeenChanged:self byNewValue:[self getStringValue] inFieldIndex:self.fieldIndex];
    }
}

- (void)setModel:(FormItemModel *)model {
    _model = model;
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
    
    if (model.titleString) {
        self.input.textField.text = model.titleString;
        [self checkValidation];
    }
    
    if (model.selectOption) {
        self.type = InputTextFieldControlTypeOptions;
    } else if (self.type == InputTextFieldControlTypeOptions) {
        //When we have no selectOption model but it's `Option` type
        self.input.textField.enabled = NO;
    }
}
    
- (void)checkValidation {
    if ([self isValid]) {
        [self.input clearError];
    } else {
        [self.input showErrorMsg:self.errorMsg];
    }
}


- (NSString *)getStringValue {
        return self.input.textField.text;
}

- (void)showErrorMsg:(NSString *)msg {
    [self.input showErrorMsg:msg];
}

- (Boolean)isValid {
    FormValidationType *validationResult = [self.validation checkValiditionOfString:[[self getStringValue] numbersToEnglish]];
    self.errorMsg = validationResult.errorMsg;
    return validationResult.boolValue;
}


- (void)donePicker {
    if ((self.input.textField.text == nil || [self.input.textField.text isEqualToString:@""]) && self.model.selectOption.allKeys.count) {
        self.input.textField.text = self.model.selectOption.allKeys[0];
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
    if (self.type == InputTextFieldControlTypeOptions) {
        textField.inputView = self.pickerView;
        textField.inputAccessoryView = self.toolBar;
        if (self.model.titleString && [self.model.selectOption.allKeys containsObject:self.model.titleString]) {
            [self.pickerView selectRow:[self.model.selectOption.allKeys indexOfObject:self.model.titleString] inComponent:0 animated:NO];
        }
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
    titleView.text = self.model.selectOption.allKeys[row];
    return titleView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.model.selectOption.allKeys.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
