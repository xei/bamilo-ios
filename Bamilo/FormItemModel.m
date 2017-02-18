//
//  FormItemModel.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemModel.h"

@implementation FormItemModel

- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)image placeholder:(NSString *)placeholder type:(InputTextFieldControlType)type validation:(FormItemValidation *)validation selectOptions:(NSDictionary *)options {
    self = [super init];
    if (self) {
        self.titleString = title;
        self.icon = image;
        self.placeholder = placeholder;
        self.validation = validation;
        self.type = type;
        self.selectOption = options;
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


@end
