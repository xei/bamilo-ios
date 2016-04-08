//
//  NSURL+Extensions.m
//  Jumia
//
//  Created by Jose Mota on 08/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "NSURL+Extensions.h"

@implementation NSURL (Extensions)

+ (NSURL *)URLWithString:(NSString *)URLString
{
    if (VALID_NOTEMPTY(URLString, NSString)) {
        return [[NSURL alloc] initWithString:[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    return nil;
}

@end
