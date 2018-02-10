//
//  FormItemModel.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormItemValidation.h"
#import "FormElementProtocol.h"


typedef NS_ENUM(NSUInteger, InputTextFieldControlType) {
    InputTextFieldControlTypePassword = 0,
    InputTextFieldControlTypeNumerical = 1,
    InputTextFieldControlTypePhone = 2,
    InputTextFieldControlTypeEmail,
    InputTextFieldControlTypeString,
    InputTextFieldControlTypeOptions,
    InputTextFieldControlTypeDatePicker
};

@interface FormItemModel : NSObject <FormElementProtocol>
@property (nonatomic, copy) NSString *inputTextValue;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *fieldName;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSDictionary *selectOption;
@property (nonatomic, strong) FormItemValidation *validation;
@property (assign, nonatomic) InputTextFieldControlType type;
@property (nonatomic, copy) NSString *lastErrorMessage;
@property (nonatomic, strong) NSDateFormatter *visibleDateFormat;
@property (nonatomic, strong) NSDateFormatter *outputDateFormat;
@property (nonatomic) BOOL disabled;

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
+ (FormItemModel *)bankAccountFieldName: (NSString *)fieldName;
+ (FormItemModel *)addressWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)postalCodeWithFieldName:(NSString *)fieldName;
+ (FormItemModel *)emailWithFieldName: (NSString *)fieldName;
+ (FormItemModel *)passWordWithFieldName: (NSString *)fieldName;
+ (FormItemModel *)genderWithFieldName: (NSString *)fieldName;
+ (FormItemModel *)birthdayFieldName: (NSString *)fieldName;
+ (FormItemModel *)nationalID: (NSString *)fieldName;

- (NSString *)getValue;
- (void)setValue:(NSString *)value;

@end
