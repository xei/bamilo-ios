//
//  FormItemValidation.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemValidation.h"


@implementation FormItemValidation


- (instancetype)initWithRequired:(Boolean)isRequired max:(NSUInteger)maxValue min:(NSUInteger)minValue withRegxPatter:(NSString *)regxPattern {
    self = [super init];
    if (self) {
        self.isRequired = isRequired;
        self.max = maxValue;
        self.min = minValue;
        self.regxPattern = regxPattern;
    }
    return self;
}

- (NSString *)getErrorMsgOfType:(FormItemValidationError)errorType {
    if(errorType == FormItemValidationErrorIsRequired)
        return @"این مورد الزامی میباشد";
    else if (errorType == FormItemValidationErrorMax)
        return [NSString stringWithFormat:@"بیش از %lu کاراکتر مجاز نمی باشد.", (unsigned long) self.max];
    else if (errorType == FormItemValidationErrorMin)
        return [NSString stringWithFormat:@"حداقل %lu کاراکتر باید وارد نمایید.", (unsigned long) self.min];
    else if (errorType == FormItemValidationErrorRegx)
        return @"لطفا مقدار معتبر وارد نمایید";
    return nil;
}

- (FormValidationType *)checkValiditionOfString:(NSString *)inputString {
    
    NSUInteger lengthOfInputText = inputString.length;
    FormValidationType *validation = [[FormValidationType alloc] init];
    
    if (self.isRequired && !lengthOfInputText) {
        validation.errorMsg = [self getErrorMsgOfType:FormItemValidationErrorIsRequired];
        validation.boolValue = NO;
        return validation;
    }
    
    if (self.max && lengthOfInputText > self.max) {
        validation.errorMsg = [self getErrorMsgOfType:FormItemValidationErrorMax];
        validation.boolValue = NO;
        return validation;
    }
    
    if (self.min && lengthOfInputText < self.min) {
        validation.errorMsg = [self getErrorMsgOfType:FormItemValidationErrorMin];
        validation.boolValue = NO;
        return validation;
    }
    
    
    if (self.regxPattern) {
        NSError *error = NULL;
        NSString *inputTextValue = inputString;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.regxPattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:inputTextValue options:0 range:NSMakeRange(0, [inputTextValue length])];
        
        if (!match) {
            validation.errorMsg = [self getErrorMsgOfType:FormItemValidationErrorRegx];
            validation.boolValue = NO;
            return validation;
        }
    }
    
    validation.boolValue = YES;
    return validation;
}

@end
