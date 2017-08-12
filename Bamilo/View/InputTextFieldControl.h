//
//  InputTextFieldControl.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextField.h"
#import "FormItemValidation.h"
#import "FormItemModel.h"

@protocol InputTextFieldControlDelegate<NSObject>
- (void)inputValueChanged:(id)inputTextFieldControl byNewValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex;
@end

@interface InputTextFieldControl : UIView
@property (nonatomic) NSUInteger fieldIndex;
@property (nonatomic, weak) id<InputTextFieldControlDelegate> delegate;
@property (nonatomic, strong) InputTextField *input;
@property (nonatomic, strong) FormItemValidation *validation;
@property (assign, nonatomic) InputTextFieldControlType type;
@property (nonatomic, strong) FormItemModel *model;

- (NSString *)getStringValue;
- (Boolean)isValid;
- (void)showErrorMsg:(NSString *)msg;
- (void)resetAndClear;
- (void)checkValidation;

@end
