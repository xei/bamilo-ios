//
//  FormItemModel.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormItemValidation.h"

@interface FormItemModel : NSObject
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) UIImage *icon;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, strong) FormItemValidation *validation;

- (instancetype)initWithTitle:(NSString *)title andIcon:(UIImage *)image placeholder:(NSString *)placeholder validation:(FormItemValidation *)validation;
@end
