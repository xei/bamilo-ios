//
//  RIPhonePrefix.m
//  Jumia
//
//  Created by Jose Mota on 03/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "RIPhonePrefix.h"

@implementation RIPhonePrefix

+ (RIPhonePrefix *)parse:(NSDictionary *)jsonDictionary
{
    RIPhonePrefix *phonePrefix = [RIPhonePrefix new];
    if (VALID_NOTEMPTY([jsonDictionary objectForKey:@"disable"], NSNumber)) {
        NSNumber *disable = [jsonDictionary objectForKey:@"disable"];
        [phonePrefix setDisable:[disable boolValue]];
    }
    if (VALID_NOTEMPTY([jsonDictionary objectForKey:@"is_default"], NSNumber)) {
        NSNumber *isDefault = [jsonDictionary objectForKey:@"is_default"];
        [phonePrefix setIsDefault:[isDefault boolValue]];
    }
    if (VALID_NOTEMPTY([jsonDictionary objectForKey:@"label"], NSString)) {
        NSString *label = [jsonDictionary objectForKey:@"label"];
        [phonePrefix setLabel:label];
    }
    if (VALID_NOTEMPTY([jsonDictionary objectForKey:@"value"], NSNumber)) {
        NSNumber *value = [jsonDictionary objectForKey:@"value"];
        [phonePrefix setValue:value];
    }
    return phonePrefix;
}

@end
