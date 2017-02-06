//
//  Address.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Address.h"

@implementation Address

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"uid": @"id",
        @"firstName": @"first_name",
        @"lastName": @"last_name",
        @"address": @"address1",
        @"address1": @"address2",
        @"city": @"city",
        @"postcode": @"postcode",
        @"phone": @"phone",
        @"isDefaultBilling": @"is_default_billing",
        @"isDefaultShipping": @"is_default_shipping",
        @"isValid": @"is_valid"
    };
}

@end
