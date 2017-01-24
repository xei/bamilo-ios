//
//  NSString+Style.m
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSString+Style.h"

@implementation NSString (Style)

- (NSString *)wrapWithMaxSize:(int)maxSize {
    
    NSString *result = self;
    if (self.length > maxSize) {
        NSRange stringRange = {0, MIN([self length], maxSize)};
        stringRange = [self rangeOfComposedCharacterSequencesForRange:stringRange];
        NSString *shortString = [self substringWithRange:stringRange];
        
         result = [NSString stringWithFormat:@"%@..", shortString];
    }
    return result;
    
}

@end
