//
//  FormItemModel.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormItemValidation.h"
#import "FormElementProtocol.h"

typedef enum : NSUInteger {
    InputTextFieldControlTypePassword,
    InputTextFieldControlTypeNumerical,
    InputTextFieldControlTypeEmail,
    InputTextFieldControlTypeString,
    InputTextFieldControlTypeOptions
} InputTextFieldControlType;

@interface FormItemModel : NSObject <FormElementProtocol>
@property (nonatomic, copy) NSString *inputTextValue;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *fieldName;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSDictionary *selectOption;
@property (nonatomic, strong) FormItemValidation *validation;
@property (assign, nonatomic) InputTextFieldControlType type;

- (instancetype)initWithTextValue:(NSString *)title
                            fieldName: (NSString *)fieldName
                            andIcon:(UIImage *)image
                            placeholder:(NSString *)placeholder
                            type:(InputTextFieldControlType)type
                            validation:(FormItemValidation *)validation
                            selectOptions:(NSDictionary *)options;

+ (FormItemModel *)firstNameFieldWithFiedName:(NSString *)fieldName;
+ (FormItemModel *)lastNameWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)phoneWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)addressWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)postalCodeWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)emailWithFieldName: (NSString *)fieldName;
+ (FormItemModel *)passWordWithFieldName: (NSString *)fieldName;
+ (FormItemModel *)genderWithFieldName: (NSString *)fieldName;

- (NSString *)getValue;
@end
