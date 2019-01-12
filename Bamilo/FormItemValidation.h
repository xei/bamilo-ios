//
//  FormItemValidation.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormValidationType.h"

typedef enum : NSUInteger {
    FormItemValidationErrorIsRequired,
    FormItemValidationErrorMax,
    FormItemValidationErrorMin,
    FormItemValidationErrorExactLenght,
    FormItemValidationErrorRegx
} FormItemValidationError;

@interface FormItemValidation : NSObject
@property (nonatomic) NSUInteger max;
@property (nonatomic) NSUInteger min;
@property (nonatomic) Boolean isRequired;
@property (nonatomic, strong) NSString *regxPattern;

- (instancetype)initWithRequired:(Boolean)isRequired max:(NSUInteger)maxValue min:(NSUInteger)minValue withRegxPatter:(NSString *)regxPattern;
- (NSString *)getErrorMsgOfType:(FormItemValidationError)errorType;
- (FormValidationType *)checkValiditionOfString:(NSString *)inputString;
@end
