//
//  JAScreenRadioComponent.h
//  Jumia
//
//  Created by telmopinto on 12/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@protocol JAScreenRadioComponentDelegate;

@interface JAScreenRadioComponent : JADynamicField

@property (nonatomic, strong)id<JAScreenRadioComponentDelegate> delegate;
@property (nonatomic, assign) BOOL currentlyChecked;

- (void)setupWithField:(RIField*)field;

@end

@protocol JAScreenRadioComponentDelegate <NSObject>

- (void)screenRadioComponentWasPressed:(JAScreenRadioComponent*)screenRadioComponent;

@end