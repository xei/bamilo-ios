//
//  CartForm.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "JSONVerboseModel.h"
#import "CartEntity.h"
#import "FormEntity.h"

@interface CartForm : BaseModel <JSONVerboseModel>

@property (strong, nonatomic) CartEntity *cartEntity;
@property (strong, nonatomic) FormEntity *formEntity;

@end
