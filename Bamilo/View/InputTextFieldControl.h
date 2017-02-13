//
//  InputTextFieldControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextField.h"
#import "FormItemValidation.h"
#import "FormItemModel.h"


@interface InputTextFieldControl : UIView
@property (nonatomic, strong) InputTextField *input;
@property (nonatomic, strong) FormItemValidation *validation;
@property (assign, nonatomic) InputTextFieldControlType type;
@property (nonatomic, strong) FormItemModel *model;

- (NSString *)getStringValue;
- (Boolean)isValid;
- (void)showErrorMsg:(NSString *)msg;

@end
