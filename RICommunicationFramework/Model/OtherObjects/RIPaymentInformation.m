//
//  RIPaymentInformation.m
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPaymentInformation.h"

@implementation RIPaymentInformation

+ (RIPaymentInformation*) parsePaymentInfo:(NSDictionary*)jsonObject {
    return [self parseToDataModelWithObjects:@[ jsonObject ]];
}

+(instancetype) parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    
    RIPaymentInformation *paymentInfo = [[RIPaymentInformation alloc] init];
    
    if(VALID_NOTEMPTY(dict, NSDictionary)) {
        if (VALID_NOTEMPTY([dict objectForKey:@"type"], NSString)) {
            NSString *type = [dict objectForKey:@"type"];
            if([@"submit-external" isEqualToString:type] || [@"auto-submit-external" isEqualToString:type] || [@"render-internal" isEqualToString:type]) {
                paymentInfo.type = RIPaymentInformationCheckoutShowWebviewWithForm;
            } else if([@"auto-redirect-external" isEqualToString:type]) {
                paymentInfo.type = RIPaymentInformationCheckoutShowWebviewWithUrl;
            }
        }
        
        if (VALID_NOTEMPTY([dict objectForKey:@"method"], NSString)) {
            paymentInfo.method = [dict objectForKey:@"method"];
        }
        
        if (VALID_NOTEMPTY([dict objectForKey:@"url"], NSString)) {
            paymentInfo.url = [dict objectForKey:@"url"];
        }
        
        if (VALID_NOTEMPTY([dict objectForKey:@"form"], NSDictionary)) {
            paymentInfo.form = [RIForm parseForm:[dict objectForKey:@"form"]];
        }
    } else {
        paymentInfo.type = RIPaymentInformationCheckoutEnded;
    }
    
    return paymentInfo;
}

@end
