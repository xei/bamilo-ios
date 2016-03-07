//
//  JARadioGroupComponent.h
//  Jumia
//
//  Created by telmopinto on 10/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@interface JARadioGroupComponent : JADynamicField

- (void)setupWithField:(RIField*)field;

- (NSDictionary*)getValues;

@end
