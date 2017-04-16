//
//  URLUtility.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "URLUtility.h"

@implementation URLUtility

+ (NSDictionary *)parseQueryString:(NSURL *)url {
    NSString *query = [url query];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        if(elements.count >= 2) {
            NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [dict setObject:val forKey:key];
        }
    }
    
    return dict;
}

@end
