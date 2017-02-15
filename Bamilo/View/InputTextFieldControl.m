//
//  InputTextFieldControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextFieldControl.h"

@interface InputTextFieldControl()
@property (nonatomic, copy) NSString *errorMsg;
@end

@implementation InputTextFieldControl

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
        default:
            break;
    }
    _type = type;
}

- (void)textFieldEditingDidEndOnExit:(UITextField *)textField {
    [self checkValidation];
    [self updateModel];
}

- (void)textFieldEditingDidEnditingBegan:(UITextField *)textField {
    [self.input clearError];
}


- (void)updateModel {
    self.model.titleString = [self getStringValue];
    [self.delegate inputValueHasBeenChanged:self byNewValue:[self getStringValue] inFieldName: self.fieldName];
}

- (void)setModel:(FormItemModel *)model {
    self.input.icon.image = model.icon;
    self.input.textField.placeholder = model.placeholder;
    self.validation = model.validation;
    [self setType: model.type];
    
    if (model.icon) {
        self.input.hasIcon = YES;
    } else {
        self.input.hasIcon = NO;
    }
    
    if (model.titleString) {
        self.input.textField.text = model.titleString;
        [self checkValidation];
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
    FormValidationType *validationResult = [self.validation checkValiditionOfString:[self getStringValue]];
    self.errorMsg = validationResult.errorMsg;
    return validationResult.boolValue;
}

@end
