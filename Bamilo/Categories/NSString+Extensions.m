//
//  NSString+Extensions.m
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSNumberFormatter*) numberFormatter {
    static NSNumberFormatter *_numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberFormatter = [[NSNumberFormatter alloc] init];
    });
    return _numberFormatter;
}

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

- (NSAttributedString *) struckThroughText {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, [attributeString length])];
    return attributeString;
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

- (NSString *)formatTheNumbers {
    if (!self.floatValue) {
        return 0;
    }
    [NSString numberFormatter].numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber * numberFromString = [[NSString numberFormatter] numberFromString:self];
    NSString * formattedNumberString = [[NSString numberFormatter] stringFromNumber:numberFromString];
    return formattedNumberString;
}
@end
