//
//  FormItemModel.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemModel.h"
#import "EmailUtility.h"

@implementation FormItemModel

- (instancetype)initWithTextValue:(NSString *)title fieldName:(NSString *)fieldName andIcon:(UIImage *)image placeholder:(NSString *)placeholder type:(InputTextFieldControlType)type validation:(FormItemValidation *)validation selectOptions:(NSDictionary *)options {
    self = [super init];
    if (self) {
        self.inputTextValue = title;
        self.icon = image;
        self.placeholder = placeholder;
        self.validation = validation;
        self.type = type;
        self.selectOption = options;
        self.fieldName = fieldName;
    }
    return self;
}

- (NSString *)getValue {
    if (self.type == InputTextFieldControlTypeNumerical) {
        return [self.inputTextValue numbersToEnglish];
    } else if (self.type == InputTextFieldControlTypeOptions) {
        return self.selectOption[self.inputTextValue];
    } else if (self.type == InputTextFieldControlTypeDatePicker && self.visibleDateFormat && self.outpuutDateFormat ) {
        NSDate *date = [self.visibleDateFormat dateFromString:[self.inputTextValue numbersToEnglish]];
        return [self.outpuutDateFormat stringFromDate:date];
    } else {
        return self.inputTextValue;
    }
}

+ (FormItemModel *)firstNameFieldWithFiedName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_NAME
                                           type: InputTextFieldControlTypeString
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                                  selectOptions: nil];
}

+ (FormItemModel *)lastNameWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_LASTNAME
                                           type: InputTextFieldControlTypeString
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                                  selectOptions:nil];
}

+ (FormItemModel *)phoneWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_CELLPHONE
                                           type: InputTextFieldControlTypeNumerical
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString mobileRegxPattern]]
                                  selectOptions: nil];
}

+ (FormItemModel *)addressWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: [NSString stringWithFormat:@"%@ %@", STRING_ADDRESS, STRING_IN_PERSIAN]
                                           type: InputTextFieldControlTypeString
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:255 min:2 withRegxPatter:nil]
                                  selectOptions:nil];
}

+ (FormItemModel *)postalCodeWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: [NSString stringWithFormat:@"%@ (%@)", STRING_POSTALCODE, STRING_OPTIONAL]
                                           type: InputTextFieldControlTypeNumerical
                                     validation: [[FormItemValidation alloc] initWithRequired:NO max:10 min:10 withRegxPatter:nil]
                                  selectOptions:nil];
}

+ (FormItemModel *)emailWithFieldName: (NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_EMAIL
                                           type: InputTextFieldControlTypeEmail
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[EmailUtility emailRegexPattern]]
                                  selectOptions: nil];
}

+ (FormItemModel *)passWordWithFieldName: (NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_PASSWORD
                                           type: InputTextFieldControlTypePassword
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil]
                                  selectOptions: nil];
}

+ (FormItemModel *)genderWithFieldName: (NSString *)fieldName {
    return [[FormItemModel alloc] initWithTextValue:nil
                                      fieldName: fieldName
                                        andIcon: nil
                                    placeholder: STRING_GENDER
                                           type: InputTextFieldControlTypeOptions
                                     validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                  selectOptions: @{STRING_MALE: @"male", STRING_FEMALE:@"female"}];
}

+ (FormItemModel *)birthdayFieldName: (NSString *)fieldName {
    FormItemModel *model = [[FormItemModel alloc] initWithTextValue: nil
                                          fieldName: fieldName
                                            andIcon: nil
                                        placeholder: [NSString stringWithFormat:@"%@ (%@)", STRING_BIRTHDAY, STRING_OPTIONAL]
                                               type: InputTextFieldControlTypeDatePicker
                                         validation: nil
                                      selectOptions: nil];
    
    NSDateFormatter *visibleFormatter = [NSDateFormatter new];
    visibleFormatter.dateFormat = @"yyyy/MM/dd";
    visibleFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    visibleFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fa_IR"];
    model.visibleDateFormat = visibleFormatter;
    
    NSDateFormatter *outputFormatter = [NSDateFormatter new];
    outputFormatter.dateFormat = @"yyyy-MM-dd";
    outputFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    outputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    model.outpuutDateFormat = outputFormatter;
    
    return model;
}

@end
