//
//  FormItemModel.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemModel.h"

@implementation FormItemModel

- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)image placeholder:(NSString *)placeholder validation:(FormItemValidation *)validation {
    self = [super init];
    if (self) {
        self.titleString = title;
        self.icon = image;
        self.placeholder = placeholder;
        self.validation = validation;
    }
    return self;
}

@end
