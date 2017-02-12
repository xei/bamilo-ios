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

@end
