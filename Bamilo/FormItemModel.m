//
//  FormItemModel.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemModel.h"

@implementation FormItemModel

- (instancetype)initWithTitle:(NSString *)title fieldName:(NSString *)fieldName andIcon:(UIImage *)image placeholder:(NSString *)placeholder type:(InputTextFieldControlType)type validation:(FormItemValidation *)validation selectOptions:(NSDictionary *)options {
    self = [super init];
    if (self) {
        self.titleString = title;
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
        return [self.titleString numbersToEnglish];
    } else if (self.type == InputTextFieldControlTypeOptions){
        return self.selectOption[self.titleString];
    } else {
        return self.titleString;
    }
}

+ (FormItemModel *)nameFieldWithFiedName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTitle:nil
                           fieldName: fieldName
                           andIcon:nil
                           placeholder:@"نام"
                           type:InputTextFieldControlTypeString
                           validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                           selectOptions:nil];
}

+ (FormItemModel *)lastNameWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTitle:nil
            fieldName: fieldName
            andIcon:nil
            placeholder:@"نام خانوادگی"
            type:InputTextFieldControlTypeString
            validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
            selectOptions:nil];
}

+ (FormItemModel *)phoneWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc]
     initWithTitle:nil
     fieldName: fieldName
     andIcon:nil
     placeholder:@"تلفن همراه"
     type:InputTextFieldControlTypeNumerical
     validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString mobileRegxPattern]]
     selectOptions:nil];
}

+ (FormItemModel *)addressWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc]
            initWithTitle:nil
            fieldName: fieldName
            andIcon:nil
            placeholder:@"نشانی به فارسی"
            type:InputTextFieldControlTypeString
            validation: [[FormItemValidation alloc] initWithRequired:YES max:255 min:2 withRegxPatter:nil]
            selectOptions:nil];
}

+ (FormItemModel *)postalCodeWithFieldName:(NSString *)fieldName {
    return [[FormItemModel alloc] initWithTitle:nil
            fieldName: fieldName
            andIcon:nil
            placeholder:@"کد پستی"
            type:InputTextFieldControlTypeNumerical
            validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]
            selectOptions:nil];
}

+ (FormItemModel *)emailWithFieldName: (NSString *)fieldName {
    return [[FormItemModel alloc]
     initWithTitle:nil
     fieldName: fieldName
     andIcon:nil
     placeholder:@"ایمیل"
     type:InputTextFieldControlTypeEmail
     validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString emailRegxPattern]]
     selectOptions:nil];
}

+ (FormItemModel *)passWordWithFieldName: (NSString *)fieldName {
    return [[FormItemModel alloc]
     initWithTitle:nil
     fieldName: fieldName
     andIcon: nil
     placeholder:@"کلمه عبور"
     type:InputTextFieldControlTypePassword
     validation:[[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil]
     selectOptions:nil];
}
@end
