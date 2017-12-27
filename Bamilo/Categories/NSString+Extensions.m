//
//  NSString+Extensions.m
//  Jumia
//
//  Created by Ali Saeedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSNumberFormatter*) numberFormatter {
    static NSNumberFormatter *_numberFormatter;
    [_numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ar"]];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberFormatter = [[NSNumberFormatter alloc] init];
    });
    return _numberFormatter;
}

+ (NSString *)mobileRegxPattern {
    return @"(\\+98|0|0098)?9\\d{9}";
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
    [attributeString addAttribute:NSBaselineOffsetAttributeName value:@0 range:NSMakeRange(0, [attributeString length])];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(0, [attributeString length])];
    return attributeString;
}

- (NSString *) numbersToPersian {
    return [self changeNumberToLocalId:@"ar"] ?: @"۰";
}

- (NSString *) numbersToEnglish {
    return [self changeNumberToLocalId:@"en_US"] ?: @"0";
}

- (NSString *)changeNumberToLocalId:(NSString *) identifier {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSString *result = self;
    for (NSInteger i = 0; i < 10; i++) {
        NSString *occurance = @"";
        if ([identifier isEqualToString:@"en_US"]) {
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"ar"];
            occurance = [formatter stringFromNumber: @(i)];
        } else {
            occurance = @(i).stringValue;
        }
        formatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
        result = [result stringByReplacingOccurrencesOfString:occurance withString:[formatter stringFromNumber:@(i)]];
    }
    return result;
}

- (NSString *)getPriceStringFromFormatedPrice {
    return [self stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (NSString *)formatPrice {
    if (self.length <= 3) return self;

    NSMutableString *formatedPrice = [NSMutableString stringWithString: self];
    int cammaIndex = ((int)(self.length % 3) ?: 3);

    while (cammaIndex < formatedPrice.length) {
        [formatedPrice insertString: @"," atIndex: cammaIndex];
        cammaIndex += 4;
    }
    return [formatedPrice copy];
}

- (NSString *)formatPriceWithCurrency {
    return [NSString stringWithFormat:@"%@ %@", [[self formatPrice] numbersToPersian], STRING_CURRENCY];
}

-(NSString *)toEncodeBase64 {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

-(NSDate *)toWebDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:cWebNormalizedDateTimeFormat];
    return [dateFormatter dateFromString:self];
}

@end
