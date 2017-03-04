//
//  FormEntity.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormEntity.h"
//#import "RIShippingMethodForm.h"
#import "RIPaymentMethodForm.h"

@implementation FormEntity

#pragma mark - JSONVerboseModel
+(instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    
    FormEntity *formEntity = [[FormEntity alloc] init];
    
    if ([dict objectForKey:@"type"]) {
        NSString* type = [dict objectForKey:@"type"];
        if (VALID_NOTEMPTY(type, NSString)) {
            if ([type isEqualToString:@"multistep_payment_method"]) {
                formEntity.paymentMethodForm = [RIPaymentMethodForm parseForm:dict];
            } else if ([type isEqualToString:@"multistep_shipping_method"]) {
                formEntity.shippingMethodForm = [ShippingMethodForm new];
                [formEntity.shippingMethodForm mergeFromDictionary:dict useKeyMapping:YES error:nil];
            }
        }
    }
    
    return formEntity;
}

@end
