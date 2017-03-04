//
//  AddressList.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressList.h"

@implementation AddressList

#pragma mark - JSONModel
+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
      @"billing": @"billing",
      @"shipping": @"shipping",
      @"other": @"other"
    }];
}

@end
