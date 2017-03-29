//
//  NSString+Extensions.h
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (NSString *)emailRegxPattern;
+ (NSString *)mobileRegxPattern;

- (NSString *)wrapWithMaxSize:(int) maxSize;
- (NSString *)numbersToPersian;
- (NSString *)numbersToEnglish;
- (NSString *)formatPrice;
- (NSString *)getPriceStringFromFormatedPrice;
- (NSString *)struckThroughText;
- (BOOL)isValidEmail;
- (NSString *) toEncodeBase64;

@end
