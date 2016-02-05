//
//  JARadioComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"
#import "JADynamicField.h"

@class RILocale;

@interface JARadioComponent : JADynamicField

@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *requiredSymbol;
@property (strong, nonatomic) NSArray *dataset;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSDictionary *optionsLabels;
@property (strong, nonatomic) NSString *apiCallTarget;
@property (strong, nonatomic) NSDictionary *apiCallParameters;
@property (nonatomic, strong) NSString* currentErrorMessage;

@property (nonatomic) CGFloat fixedWidth;

-(void)setupWithField:(RIField*)field;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(id)value;

-(void)setLocaleValue:(RILocale*)locale;

-(NSDictionary*)getValues;

-(NSString*)getSelectedValue;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getApiCallUrl;

- (NSDictionary*)getApiCallParameters;

-(NSString*)getFieldName;

@end