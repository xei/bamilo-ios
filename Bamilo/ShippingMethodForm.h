//
//  ShippingMethodForm.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "ShippingMethod.h"

@protocol ShippingMethod;

@interface ShippingMethodForm : BaseModel

@property (copy, nonatomic) NSString *action;
@property (strong, nonatomic) NSArray<ShippingMethod> *fields;
@property (copy, nonatomic) NSString *method;
@property (copy, nonatomic) NSString *type;

@end
