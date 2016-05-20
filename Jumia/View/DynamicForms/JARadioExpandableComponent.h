//
//  JARadioExpandableComponent.h
//  Jumia
//
//  Created by telmopinto on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@protocol JARadioExpandableComponentDelegate;

@interface JARadioExpandableComponent : JADynamicField

@property (nonatomic, assign)id<JARadioExpandableComponentDelegate> delegate;
@property (nonatomic, assign)id<UITextFieldDelegate>textFieldDelegate;
@property (nonatomic, strong)NSString* currentErrorMessage;

- (void)setupWithField:(RIField*)field;

- (NSString*)getFieldName;

- (void)resetErrorFromTextField:(UITextField*)textField;

@end

@protocol JARadioExpandableComponentDelegate <NSObject>

- (void)radioExpandableComponent:(JARadioExpandableComponent*)radioExpandableComponent
                   changedHeight:(CGFloat)delta;

- (void)radioExpandableComponent:(JARadioExpandableComponent *)radioExpandableComponent
                    openCMSBlock:(NSString*)cmsBlock;

@end
