//
//  FormEntity.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "JSONVerboseModel.h"

@class RIShippingMethodForm, RIPaymentMethodForm;

@interface FormEntity : BaseModel <JSONVerboseModel>

@property (nonatomic, strong) RIShippingMethodForm *shippingMethodForm;
@property (nonatomic, strong) RIPaymentMethodForm *paymentMethodForm;

@end
