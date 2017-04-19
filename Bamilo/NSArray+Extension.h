//
//  NSArray+Extension.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (Extension)

- (NSArray *)map:(id(^)(ObjectType item))block;
- (NSString *)reduceString:(NSString *)initial combine:(NSString *(^)(NSString * acum, ObjectType element))block;

@end
