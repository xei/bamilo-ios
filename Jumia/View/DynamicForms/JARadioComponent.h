//
//  JARadioComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@class RIRegion;
@class RICity;

@interface JARadioComponent : UIView

@property (assign, nonatomic) BOOL hasError;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;
@property (strong, nonatomic) NSArray *dataset;
@property (strong, nonatomic) NSString *apiCall;

+(JARadioComponent *)getNewJARadioComponent;

-(void)setupWithField:(RIField*)field;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(NSString*)value;

-(void)setRegionValue:(RIRegion*)value;

-(void)setCityValue:(RICity*)value;

-(NSDictionary*)getValues;

-(NSString*)getSelectedValue;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getApiCallUrl;

-(NSString*)getFieldName;

@end