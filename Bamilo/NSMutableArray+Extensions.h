//
//  NSMutableArray+Extensions.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Extensions)

+(NSMutableArray *) indexPathArrayOfLength:(int)length forSection:(int)section;
+(NSMutableArray *) indexPathArrayFromRange:(NSRange)range forSection:(int)section;

- (NSMutableArray *)map:(id(^)(id))block;

@end
