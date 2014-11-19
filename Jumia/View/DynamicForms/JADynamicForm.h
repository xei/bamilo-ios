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

/**
 * Method that tells if the focus of a view was changed
 */
- (void)changedFocus:(UIView *)view;

/**
 * Method that tells if the focus of a view was lost
 */
- (void)lostFocus;

/**
 * Method that tells if a date picker is needed
 */
- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent;

/**
 * Method that tells if a picker is needed
 */
- (void)openPicker:(JARadioComponent *)radioComponent;

/**
 * Method that tells if we need to download regions and cities
 */
- (void)downloadRegions:(JARadioComponent *)regionComponent cities:(JARadioComponent*) citiesComponent;

@end

@interface JADynamicForm : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) NSMutableArray *formViews;
@property (strong, nonatomic) id<JADynamicFormDelegate> delegate;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;

-(id)initWithForm:(RIForm*)form delegate:(id<JADynamicFormDelegate>)delegate startingPosition:(CGFloat)startingY widthSize:(CGFloat)widthComponent;

-(id)initWithForm:(RIForm*)form delegate:(id<JADynamicFormDelegate>)delegate values:(NSDictionary*)values startingPosition:(CGFloat)startingY ;

-(void)validateFields:(NSDictionary*)errors;

-(BOOL)checkErrors;

-(NSDictionary*)getValues;

-(void)resetValues;

-(void)setRegionValue:(RIRegion*)region;

-(void)setCityValue:(RICity*)city;

-(void)resignResponder;

- (NSString*)getFieldNameForKey:(NSString*)key;

@end
