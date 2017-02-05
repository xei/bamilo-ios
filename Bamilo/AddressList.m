//
//  AddressList.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressList.h"

@implementation AddressList

#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"billing": @"billing",
        @"shipping": @"shipping"
    };
}

@end
