//
//  NSArray+Extension.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (NSArray *)map:(id(^)(id item))block {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id newObject = block(obj) ?: [NSNull null];
        [array addObject:newObject];
    }];
    return array.copy;
}

- (NSString *)reduceString:(NSString *)initial combine:(NSString *(^)(NSString * acum, id element))block {
    if (!self) {
        return initial;
    }
    NSString *acum = initial;
    for (id element in self) {
        acum = block(acum, element);
    }
    
    return acum;
}

@end
