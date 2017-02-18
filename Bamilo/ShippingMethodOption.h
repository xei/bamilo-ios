//
//  ShippingMethodOption.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"

@interface ShippingMethodOption : BaseModel

@property (copy, nonatomic) NSString *deliveryTime;
@property (copy, nonatomic) NSString *label;
@property (copy, nonatomic) NSString *value;

@end
