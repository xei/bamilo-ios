//
//  ShippingMethod.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "ShippingMethodOption.h"

@protocol ShippingMethodOption;

@interface ShippingMethod : BaseModel

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *label;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray<ShippingMethodOption> *options;
@property (strong, nonatomic) NSDictionary *rules;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *value;

@end
