//
//  FormItemModel.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormItemValidation.h"

typedef enum : NSUInteger {
    InputTextFieldControlTypePassword,
    InputTextFieldControlTypeNumerical,
    InputTextFieldControlTypeEmail,
    InputTextFieldControlTypeString,
} InputTextFieldControlType;

@interface FormItemModel : NSObject
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, strong) FormItemValidation *validation;
@property (assign, nonatomic) InputTextFieldControlType type;

- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)image placeholder:(NSString *)placeholder type:(InputTextFieldControlType)type validation:(FormItemValidation *)validation;
@end
