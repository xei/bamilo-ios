//
//  CheckoutProgressViewButtonModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutProgressViewButtonModel.h"

@implementation CheckoutProgressViewButtonModel

+(instancetype) buttonWith:(int)uid state:(CheckoutProgressViewButtonState)state {
    CheckoutProgressViewButtonModel *newModel = [CheckoutProgressViewButtonModel new];
    newModel.uid = uid;
    newModel.state = state;
    
    return newModel;
}

@end
