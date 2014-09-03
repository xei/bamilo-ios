//
//  JADynamicForm.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JATextFieldComponent.h"
#import "JABirthDateComponent.h"
#import "JACheckBoxComponent.h"
#import "JARadioComponent.h"
#import "JACheckBoxWithOptionsComponent.h"

@class RIForm;
@class RIRegion;
@class RICity;

@protocol JADynamicFormDelegate <NSObject>

@optional

- (void)changedFocus:(UIView *)view;

- (void)lostFocus;

- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent;

- (void)openPicker:(JARadioComponent *)radioComponent;

- (void)downloadRegions:(JARadioComponent *)regionComponent cities:(JARadioComponent*) citiesComponent;

@end

@interface JADynamicForm : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) NSMutableArray *formViews;
@property (strong, nonatomic) id<JADynamicFormDelegate> delegate;

-(id)initWithForm:(RIForm*)form delegate:(id<JADynamicFormDelegate>)delegate startingPosition:(CGFloat)startingY;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;

-(void)validateFields:(NSDictionary*)errors;

-(BOOL)checkErrors;

-(NSDictionary*)getValues;

-(void)resetValues;

-(void)resignResponder;

-(void)setRegionValue:(RIRegion*)region;

-(void)setCityValue:(RICity*)city;

@end
