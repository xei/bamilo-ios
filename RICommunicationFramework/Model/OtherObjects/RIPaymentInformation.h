//
//  RIPaymentInformation.h
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIForm.h"

typedef NS_ENUM(NSUInteger, RIPaymentInformationType) {
    //!< This means that the checkout has ended with some method that does not need extra payment information like cash on delivery.
    RIPaymentInformationCheckoutEnded = 0,
    
    //!< This means that we have to show a web view to the user and the address is in url field
    RIPaymentInformationCheckoutShowWebviewWithUrl = 1,
    
    //!< This means that we have to show a web view to the user and the address is in the form action field.
    // VERY IMPORTANT: Do not forget to send the form key/values in the request
    RIPaymentInformationCheckoutShowWebviewWithForm = 2
};

@interface RIPaymentInformation : NSObject

@property (nonatomic, assign) RIPaymentInformationType type;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) RIForm *form;
@property (nonatomic, strong) NSString *url;

+ (RIPaymentInformation*) parsePaymentInfo:(NSDictionary*)jsonObject;

@end
