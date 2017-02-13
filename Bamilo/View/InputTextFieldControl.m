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
    if (!self.validation) {
        return YES;
    }
    self.errorMsg = nil;
    
    NSUInteger lengthOfInputText = self.input.textField.text.length;
    
    if (self.validation.isRequired && !lengthOfInputText) {
        self.errorMsg = [self.validation getErrorMsgOfType:FormItemValidationErrorIsRequired];
        return NO;
    }
    
    if (self.validation.max && lengthOfInputText > self.validation.max) {
        self.errorMsg = [self.validation getErrorMsgOfType:FormItemValidationErrorMax];
        return NO;
    }
    
    if (self.validation.min && lengthOfInputText < self.validation.min) {
        self.errorMsg = [self.validation getErrorMsgOfType:FormItemValidationErrorMin];
        return NO;
    }
    
    
    if (self.validation.regxPattern) {
        NSError *error = NULL;
        NSString *inputTextValue = [self getStringValue];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.validation.regxPattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:inputTextValue options:0 range:NSMakeRange(0, [inputTextValue length])];
        
        if (!match) {
            self.errorMsg = [self.validation getErrorMsgOfType:FormItemValidationErrorRegx];
            return NO;
        }
    }
    
    return YES;
}

@end
