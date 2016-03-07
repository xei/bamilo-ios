//
//  JABirthDateComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"
#import "JADynamicField.h"

@interface JABirthDateComponent : JADynamicField

@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *requiredSymbol;
@property (nonatomic, strong) NSString* currentErrorMessage;

-(void)setupWithField:(RIField*)field;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(NSDate*)date;

-(NSDate*)getDate;

-(NSMutableDictionary*)getValues;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

@end