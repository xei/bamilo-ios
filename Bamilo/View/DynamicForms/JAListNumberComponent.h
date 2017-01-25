//
//  JAListNumberComponent.h
//  Jumia
//
//  Created by telmopinto on 11/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@interface JAListNumberComponent : JADynamicField

@property (assign, nonatomic) NSInteger componentIdentifier;
@property (assign, nonatomic) BOOL hasError;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *requiredSymbol;
@property (nonatomic, strong) NSString* currentErrorMessage;
@property (strong, nonatomic) UIImageView *dropdownImageView;

@property (nonatomic) CGFloat fixedWidth;

-(void)setupWithField:(RIField*)field;

-(NSString*)getSelectedValue;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

-(NSString*)getFieldName;

@end
