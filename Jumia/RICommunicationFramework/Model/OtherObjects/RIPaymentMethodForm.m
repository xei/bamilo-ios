//
//  RIPaymentMethodForm.m
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPaymentMethodForm.h"
#import "RIField.h"

@implementation RIPaymentMethodForm

+ (RIPaymentMethodForm *)parseForm:(NSDictionary *)formJSON
{
    RIPaymentMethodForm *newForm = [[RIPaymentMethodForm alloc] init];
    
    if (VALID_NOTEMPTY(formJSON, NSDictionary)) {
        
        if ([formJSON objectForKey:@"id"]) {
            newForm.uid = [formJSON objectForKey:@"id"];
        }
        if ([formJSON objectForKey:@"action"]) {
            newForm.action = [formJSON objectForKey:@"action"];
        }
        if ([formJSON objectForKey:@"method"]) {
            newForm.method = [formJSON objectForKey:@"method"];
        }
        
        NSArray* fieldsObject = [formJSON objectForKey:@"fields"];
        if (VALID_NOTEMPTY(fieldsObject, NSArray)) {
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            for (NSDictionary *fieldObject in fieldsObject) {
                RIPaymentMethodFormField* newField = [RIPaymentMethodFormField parseField:fieldObject];
                [fields addObject:newField];
            }
            newForm.fields = [fields copy];
        }
    }
    
    return newForm;
}

+ (NSDictionary *) getParametersForForm:(RIPaymentMethodForm *)form
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for(RIPaymentMethodFormField *field in form.fields)
    {
        [parameters setValue:field.value forKey:field.name];
        
        NSArray *extraFields = [RIPaymentMethodForm getExtraFieldsForOption:field.value inForm:form];
        for(RIField *extraField in extraFields)
        {            
            [parameters setValue:extraField.value forKey:extraField.name];
        }
    }
    
    return [parameters copy];
}

+ (NSArray *) getExtraFieldsForOption:(NSString*)option
                               inForm:(RIPaymentMethodForm*)form
{
    NSArray *extraFields = nil;
    for (RIPaymentMethodFormField *field in [form fields])
    {
        if([@"paymentMethodForm[payment_method]" isEqualToString:[field name]])
        {
            for (RIPaymentMethodFormOption *formOption in [field options])
            {
                NSLog(@"%@ - %@", option, [formOption value]);
                if([option isEqualToString:[formOption value]])
                {
                    if(VALID_NOTEMPTY(formOption.form, RIForm) && VALID_NOTEMPTY(formOption.form.fields, NSOrderedSet))
                    {
                        extraFields = [formOption.form.fields array];
                        break;
                    }
                    break;
                }
            }
            break;
        }
    }
    return extraFields;
}

@end
