//
//  URLUtility.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "URLUtility.h"

@implementation URLUtility

+ (NSDictionary<NSString *, NSString *> *)parseQueryString:(NSURL *)url {
    NSString *query = [url query];
    NSMutableDictionary<NSString *, NSString *> *dict = [NSMutableDictionary new];
    NSArray<NSString *> *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray<NSString *> *elements = [pair componentsSeparatedByString:@"="];
        
        if(elements.count >= 2) {
            NSString *key = [[elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString];
            NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [dict setObject:val forKey:key];
        }
    }
    return [dict copy];
}

@end
