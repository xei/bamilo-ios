//
//  JAReturnStepByStepModel.h
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAStepByStepModel.h"
#import "RIOrder.h"

@interface JAReturnStepByStepModel : JAStepByStepModel

@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSArray *items;

@end
