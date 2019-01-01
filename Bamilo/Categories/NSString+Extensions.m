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
    return @"^(((\\+|00)98)|0)?9[01239]\\d{8}$";
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

- (NSString *)forceRTL {
    return [NSString stringWithFormat:@"\u200F%@", self];
}

- (NSString *) numbersToPersian {
    return [self changeNumberToLocalId:@"ar"] ?: @"۰";
}

- (NSString *) numbersToEnglish {
    return [self changeNumberToLocalId:@"en_US"] ?: @"0";
}

- (NSString *)changeNumberToLocalId:(NSString *) identifier {
    NSString *result = self;
    for (NSInteger charIdx=0; charIdx<self.length; charIdx++) {
        NSString *str = [NSString stringWithFormat: @"%C", [self characterAtIndex:charIdx]];
        NSString * translatedCharater;
        if ([identifier isEqualToString:@"en_US"]) {
            translatedCharater = [self convertToEnglish:str];
        } else {
            translatedCharater = [self convertEnNumberToFarsi:[self convertToEnglish:str]];
        }
        if ([translatedCharater length]) {
            result = [result stringByReplacingOccurrencesOfString:str withString:translatedCharater];
        }
    }
    return result;
}

- (NSString*)convertEnNumberToFarsi:(NSString*)number {
    NSNumberFormatter *nf = [NSNumberFormatter new];
    NSNumber *someNumber = [nf numberFromString:number];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fa"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}

- (NSString*)convertToEnglish:(NSString*)input {
    NSNumberFormatter *Formatter = [[NSNumberFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"EN"];
    [Formatter setLocale:locale];
    NSNumber *newNum = [Formatter numberFromString:input];
    return [newNum stringValue];
}

- (NSString *)getPriceStringFromFormatedPrice {
    return [self stringByReplacingOccurrencesOfString:@"," withString:@""];
}

- (NSString *)convertRailsToTomans {
    return [self substringToIndex:[self length] - 1];
}

- (NSString *)formatPrice {
    if (self.length <= 3) return self;

    NSMutableString *formatedPrice = [NSMutableString stringWithString: self];
    int cammaIndex = ((int)(formatedPrice.length % 3) ?: 3);

    while (cammaIndex < formatedPrice.length) {
        [formatedPrice insertString: @"," atIndex: cammaIndex];
        cammaIndex += 4;
    }
    return [formatedPrice copy];
}

- (NSString *)formatPriceWithCurrency {
    return [NSString stringWithFormat:@"%@ %@", [[[self convertRailsToTomans] formatPrice] numbersToPersian], STRING_CURRENCY];
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
