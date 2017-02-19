//
//  CartForm.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartForm.h"

@implementation CartForm

#pragma mark - JSONVerboseModel
+(instancetype) parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    RICountryConfiguration *country = objects[1];
    
    CartForm *cartForm = [CartForm new];
    
    cartForm.cartEntity = [CartEntity parseToDataModelWithObjects:@[ [dict objectForKey:@"cart_entity"], country ]];
    cartForm.formEntity = [FormEntity parseToDataModelWithObjects:@[ [dict objectForKey:@"form_entity"] ]];
    
    return cartForm;
}

@end
