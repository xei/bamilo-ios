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
        
         result = [NSString stringWithFormat:@"%@...", shortString];
    }
    return result;
    
}

- (NSString *) numbersToPersian {
    return [self changeNumberToLocalId:@"ar"];
}

- (NSString *) numbersToEnglish {
    return [self changeNumberToLocalId:@"en"];
}

- (NSString *)changeNumberToLocalId:(NSString *) identifier {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
    NSString *result = self;
    for (NSInteger i = 0; i < 10; i++) {
        NSNumber *num = @(i);
        result = [result stringByReplacingOccurrencesOfString:num.stringValue withString:[formatter stringFromNumber:num]];
    }
    return result;
}
@end
