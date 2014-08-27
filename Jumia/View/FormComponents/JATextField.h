//
//  JATextField.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@interface JATextField : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;

- (BOOL)isValid;

+ (JATextField *)getNewJATextField;

- (void)setupWithField:(RIField*)field;

@end