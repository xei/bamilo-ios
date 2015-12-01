//
//  JATextField.h
//  Jumia
//
//  Created by Jose Mota on 30/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@interface JATextFieldComponentV2 : JADynamicField

@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *requiredSymbol;
@property (nonatomic, strong) NSString* currentErrorMessage;

@property (nonatomic, strong) JARadioRelatedComponent* relatedComponent;

-(BOOL)isValid;

-(void)setupWithField:(RIField*)field;

-(void)setupWithTitle:(NSString *)title label:(NSString*)label value:(NSString*)value mandatory:(BOOL)mandatory;

-(void)setupWithLabel:(NSString*)label value:(NSString*)value mandatory:(BOOL)mandatory;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(NSString*)value;

-(NSDictionary*)getValues;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getFieldName;

@end
