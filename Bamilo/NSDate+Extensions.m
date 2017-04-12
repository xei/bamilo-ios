//
//  NSDate+Extensions.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

- (NSString *)convertToJalali {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.dateFormat = @"yyyy/MM/dd";
    return [df stringFromDate:self];
}

-(NSString *)webFormalized {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

@end
