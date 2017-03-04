//
//  NSMutableString+Extensions.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSMutableString+Extensions.h"

@implementation NSMutableString (Extensions)

-(void)smartAppend:(NSString *)string {
    [self smartAppend:string replacer:nil];
}

-(void)smartAppend:(NSString *)string replacer:(NSString *)replacer {
    NSString *appendString = (string && string.length) ? string : (replacer ?: nil);
    
    if(appendString) {
        if(self.length) {
            [self appendString:@" "];
        }
        
        [self appendString:appendString];
    }
}

@end
