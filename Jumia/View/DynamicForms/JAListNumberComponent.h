//
//  JAListNumberComponent.h
//  Jumia
//
//  Created by telmopinto on 11/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@interface JAListNumberComponent : JADynamicField

@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *requiredSymbol;
@property (nonatomic, strong) NSString* currentErrorMessage;

@property (nonatomic) CGFloat fixedWidth;

-(void)setupWithField:(RIField*)field;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(id)value;

-(NSDictionary*)getValues;

-(NSString*)getSelectedValue;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getFieldName;

@end
