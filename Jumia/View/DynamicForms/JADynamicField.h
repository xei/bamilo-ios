//
//  JADynamicField.h
//  Jumia
//
//  Created by Telmo Pinto on 08/06/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@interface JADynamicField : UIView

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) UIImageView *iconImageView;

- (BOOL)isComponentWithKey:(NSString*)key;
- (BOOL)isComponentWithName:(NSString*)name;
- (void)setValue:(id)value;
- (NSDictionary*)getValues;
- (NSDictionary *)getLabels;

@end
