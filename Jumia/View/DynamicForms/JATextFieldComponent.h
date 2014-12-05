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
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;

-(BOOL)isValid;

+(JATextFieldComponent *)getNewJATextFieldComponent;

-(void)setupWithField:(RIField*)field;

-(void)setupWithLabel:(NSString*)label value:(NSString*)value mandatory:(BOOL)mandatory;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(NSString*)value;

-(NSDictionary*)getValues;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getFieldName;

@end