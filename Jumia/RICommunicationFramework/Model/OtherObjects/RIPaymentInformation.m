//
//  RIPaymentInformation.m
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPaymentInformation.h"

@implementation RIPaymentInformation

+ (RIPaymentInformation*) parsePaymentInfo:(NSDictionary*)jsonObject
{
    RIPaymentInformation *paymentInfo = [[RIPaymentInformation alloc] init];
    
    if(VALID_NOTEMPTY(jsonObject, NSDictionary))
    {
        if (VALID_NOTEMPTY([jsonObject objectForKey:@"type"], NSString)) {
            
            NSString *type = [jsonObject objectForKey:@"type"];
            if([@"submit-external" isEqualToString:type] || [@"auto-submit-external" isEqualToString:type] || [@"render-internal" isEqualToString:type])
            {
                paymentInfo.type = RIPaymentInformationCheckoutShowWebviewWithForm;
            }
            else if([@"auto-redirect-external" isEqualToString:type])
            {
                paymentInfo.type = RIPaymentInformationCheckoutShowWebviewWithUrl;
            }
        }
        
        if (VALID_NOTEMPTY([jsonObject objectForKey:@"method"], NSString)) {
            paymentInfo.method = [jsonObject objectForKey:@"method"];
        }
        
        if (VALID_NOTEMPTY([jsonObject objectForKey:@"url"], NSString)) {
            paymentInfo.url = [jsonObject objectForKey:@"url"];
        }
        
        if (VALID_NOTEMPTY([jsonObject objectForKey:@"form"], NSDictionary)) {
            paymentInfo.form = [RIForm parseForm:[jsonObject objectForKey:@"form"]];
        }
    }
    else
    {
        paymentInfo.type = RIPaymentInformationCheckoutEnded;
    }
    
    return paymentInfo;
}

@end
