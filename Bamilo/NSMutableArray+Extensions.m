//
//  NSMutableArray+Extensions.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSMutableArray+Extensions.h"

@implementation NSMutableArray (Extensions)

+ (NSMutableArray *) indexPathArrayOfLength:(int)length forSection:(int)section {
    return [NSMutableArray indexPathArrayFromRange:NSMakeRange(0, length) forSection:section];
}

+ (NSMutableArray *) indexPathArrayFromRange:(NSRange)range forSection:(int)section {
    NSMutableArray *_array = [NSMutableArray new];
    for(NSUInteger i = range.location; i < NSMaxRange(range); i++ ){
        [_array addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    return _array;
}

- (NSMutableArray *)map:(id(^)(id))block {
    NSEnumerator * enumerator = ((NSArray *)self.copy).objectEnumerator;
    NSMutableArray *mappedResult = [NSMutableArray arrayWithCapacity:[self count]];
    id obj; NSUInteger idx = 0;
    while ((obj = enumerator.nextObject)) {
        mappedResult[idx] = block(obj) ?: [NSNull null];
        idx++;
    }
    return mappedResult;
}
@end
