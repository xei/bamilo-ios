//
//  RIPaymentMethodFormOption.m
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPaymentMethodFormOption.h"

@implementation RIPaymentMethodFormOption

+ (RIPaymentMethodFormOption *)parseField:(NSDictionary *)fieldJSON
{
    RIPaymentMethodFormOption* newOption = [[RIPaymentMethodFormOption alloc] init];
    
    NSDictionary *descriptionObject = [fieldJSON objectForKey:@"description"];
    if(VALID_NOTEMPTY(descriptionObject, NSDictionary))
    {
        if (VALID_NOTEMPTY([descriptionObject objectForKey:@"text"], NSString)) {
            newOption.text = [descriptionObject objectForKey:@"text"];
        }
        
        if (VALID_NOTEMPTY([descriptionObject objectForKey:@"tooltip_text"], NSString)) {
            newOption.tooltipText = [descriptionObject objectForKey:@"tooltip_text"];
        }
        
        if (VALID_NOTEMPTY([descriptionObject objectForKey:@"cvc_text"], NSString)) {
            newOption.cvcText = [descriptionObject objectForKey:@"cvc_text"];
        }
        
        if (VALID_NOTEMPTY([descriptionObject objectForKey:@"images"], NSArray)) {
            NSArray *images = [descriptionObject objectForKey:@"images"];
            newOption.images = [images copy];
        }
    }
    
    if(VALID_NOTEMPTY([fieldJSON objectForKey:@"fields"], NSArray))
    {
        newOption.form = [RIForm parseForm:fieldJSON];
    }
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"value"], NSString)) {
        newOption.value = [fieldJSON objectForKey:@"value"];
    }
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"label"], NSString)) {
        newOption.label = [fieldJSON objectForKey:@"label"];
    }
    
    return newOption;
}

@end
