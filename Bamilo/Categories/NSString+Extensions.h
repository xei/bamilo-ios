//
//  NSString+Extensions.h
//  Jumia
//
//  Created by Ali Saeedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (NSString *)mobileRegxPattern;

- (NSString *)wrapWithMaxSize:(int) maxSize;
- (NSString *)numbersToPersian;
- (NSString *)numbersToEnglish;
- (NSString *)formatPrice;
- (NSString *)formatPriceWithCurrency;
- (NSString *)getPriceStringFromFormatedPrice;
- (NSString *)struckThroughText;
- (NSString *)toEncodeBase64;

@end
