//
//  JASwitchRadioComponent.h
//  Jumia
//
//  Created by telmopinto on 11/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@protocol JASwitchRadioComponentDelegate;

@interface JASwitchRadioComponent : JADynamicField

@property (nonatomic, assign)id<JASwitchRadioComponentDelegate>delegate;

-(void)setupWithField:(RIField*)field;

- (NSDictionary*)getValues;

- (void)forceSelection;

@end

@protocol JASwitchRadioComponentDelegate <NSObject>

- (void)switchRadioComponent:(JASwitchRadioComponent*)switchRadioComponent
               changedHeight:(CGFloat)delta;

@end