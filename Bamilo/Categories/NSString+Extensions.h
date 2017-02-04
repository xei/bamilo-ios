//
//  NSString+Extensions.h
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (NSString *) wrapWithMaxSize:(int) maxSize;
- (NSString *) numbersToPersian;
- (NSString *) numbersToEnglish;
- (NSString *) formatTheNumbers;

@end
