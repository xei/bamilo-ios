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
@class RILocale;

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
- (void)downloadLocalesForComponents:(NSDictionary*)componentDictionary;

/**
 * Method used when a done button is added to a numPad keyboard
 */
- (IBAction)doneClicked:(id)sender;

@end

@interface JADynamicForm : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) NSMutableArray *formViews;
@property (strong, nonatomic) id<JADynamicFormDelegate> delegate;
@property (assign, nonatomic) BOOL hasFieldNavigation;
@property (nonatomic, strong) NSString* firstErrorInFields;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY widthSize:(CGFloat)widthComponent hasFieldNavigation:(BOOL)hasFieldNavigation;

-(id)initWithForm:(RIForm*)form values:(NSDictionary*)values startingPosition:(CGFloat)startingY hasFieldNavigation:(BOOL)hasFieldNavigation;

-(void)validateFieldsWithErrorArray:(NSArray*)errorsArray
                        finishBlock:(void (^)(NSString*))finishBlock;
-(void)validateFieldWithErrorDictionary:(NSDictionary*)errorDictionary
                            finishBlock:(void (^)(NSString*))finishBlock;

-(BOOL)checkErrors;

-(NSDictionary*)getValues;

-(void)resetValues;

-(void)setRegionValue:(RILocale*)region;

-(void)setCityValue:(RILocale*)city;

-(void)setPostcodeValue:(RILocale*)postcode;

-(void)resignResponder;

- (NSString*)getFieldNameForKey:(NSString*)key;

@end
