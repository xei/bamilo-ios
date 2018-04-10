//
//  Address.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Address.h"

@implementation Address

#pragma mark - JSONModel
+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
      @"uid": @"id",
      @"firstName": @"first_name",
      @"lastName": @"last_name",
      @"address": @"address1",
      @"address1": @"address2",
      @"city": @"city",
      @"region": @"region",
      @"postcode": @"postcode",
      @"phone": @"phone",
      @"isDefaultBilling": @"is_default_billing",
      @"isDefaultShipping": @"is_default_shipping",
      @"isValid": @"is_valid"
    }];
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    BOOL result = [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    if ([[dict objectForKey:@"customer_address_id"] isKindOfClass:[NSString class]] && [[dict objectForKey:@"customer_address_id"] length]) {
        self.uid = [dict objectForKey:@"customer_address_id"];
    }
    return result;
}

@end
