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
@property (nonatomic, strong)NSString* currentErrorMessage;

- (void)setupWithField:(RIField*)field;

- (NSString*)getFieldName;

@end

@protocol JARadioExpandableComponentDelegate <NSObject>

- (void)radioExpandableComponent:(JARadioExpandableComponent*)radioExpandableComponent
                   changedHeight:(CGFloat)delta;

@end
