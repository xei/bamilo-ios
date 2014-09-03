//
//  JATextFieldComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@interface JATextFieldComponent : UIView

@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;

- (BOOL)isValid;

+ (JATextFieldComponent *)getNewJATextFieldComponent;

- (void)setupWithField:(RIField*)field;

-(void)setValue:(NSString*)value;

-(NSString*)getValue;

-(void)setError:(NSString*)error;

-(void)cleanError;

@end