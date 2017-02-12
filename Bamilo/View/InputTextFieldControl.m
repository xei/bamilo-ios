//
//  InputTextFieldControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextFieldControl.h"

@implementation InputTextFieldControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.input = [[[NSBundle mainBundle] loadNibNamed:@"InputTextField" owner:self options:nil] lastObject];
    
    [self addSubview:self.input];
    self.input.frame = self.bounds;
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

- (void)setModel:(FormItemModel *)model {
    self.input.textField.text = model.titleString;
    self.input.icon.image = model.icon;
    self.input.textField.placeholder = model.placeholder;
    self.validation = model.validation;
    
    if (model.icon) {
        self.input.hasIcon = YES;
    } else {
        self.input.hasIcon = NO;
    }
}

- (NSString *)getStringValue {
    return self.input.textField.text;
}

- (Boolean)isValid {
    
    if (!self.validation) {
        return YES;
    }
    
    NSUInteger lengthOfInputText = self.input.textField.text.length;
    
    if (self.validation.isRequired && !lengthOfInputText) {
        return NO;
    }
    
    if (self.validation.max && lengthOfInputText > self.validation.max) {
        return NO;
    }
    
    if (self.validation.min && lengthOfInputText < self.validation.min) {
        return NO;
    }
    
    
    if (self.validation.regxPattern) {
        NSError *error = NULL;
        NSString *inputTextValue = self.input.textField.text;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.validation.regxPattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:inputTextValue options:0 range:NSMakeRange(0, [inputTextValue length])];
        
        if (match) {
            return NO;
        }
    }
    
    return YES;
}

@end
