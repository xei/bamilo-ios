//
//  NSArray+Extension.m
//  Bamilo
//
//  Created by Ali saiedifar on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (NSArray *)map:(id(^)(id))block {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id newObject = block(obj) ?: [NSNull null];
        [array addObject:newObject];
    }];
    return array.copy;
}

@end
