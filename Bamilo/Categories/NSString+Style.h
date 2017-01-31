//
//  NSString+Style.h
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Style)
- (NSString *)wrapWithMaxSize:(int)maxSize;
- (NSString *) numbersToPersian;
- (NSString *) numbersToEnglish;
@end
