//
//  RIOpenURLHandler.m
//  RITracking
//
//  Created by Martin Biermann on 15/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import "RIOpenURLHandler.h"

typedef void(^RIOpenURLHandlerBlock)(NSDictionary *);

@interface RIOpenURLHandler ()

@property (copy) RIOpenURLHandlerBlock handlerBlock;
@property NSArray *macros;
@property NSRegularExpression *regex;

@end

@implementation RIOpenURLHandler

- (instancetype)initWithHandlerBlock:(void (^)(NSDictionary *))handlerBlock
                               regex:(NSRegularExpression *)regex
                              macros:(NSArray *)macros
{
    if ((self = [super init])) {
        self.handlerBlock = handlerBlock;
        self.regex = regex;
        self.macros = macros;
    }
    return self;
}

- (void)handleOpenURL:(NSURL *)url
{
    NSArray *matches = [self.regex matchesInString:url.absoluteString
                                           options:0
                                             range:NSMakeRange(0, url.absoluteString.length)];
    if (0 == matches.count) return;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSTextCheckingResult *match = matches[0];
    // Loop through groups captured in match. Skip first, this is the whole tested string.
    for (NSUInteger idx = 0; idx < match.numberOfRanges-1; idx++) {
        NSRange range = [match rangeAtIndex:idx+1];
        params[self.macros[idx]] = [url.absoluteString substringWithRange:range];
    }
    
    for (NSString *param in [url.query componentsSeparatedByString:@"&"]) {
        NSArray *pair = [param componentsSeparatedByString:@"="];
        if ([pair count] < 2) continue;
        [params setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    
    self.handlerBlock(params);
}

@end
