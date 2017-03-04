//
//  MultistepEntity.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "MultistepEntity.h"

@implementation MultistepEntity

#pragma mark - JSONModel
+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"nextStep": @"multistep_entity.next_step"
    }];
}

@end
