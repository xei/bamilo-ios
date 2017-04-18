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

-(NSString *)toWebDateString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:cWebNormalizedDateTimeFormat];
    return [dateFormatter stringFromDate:self];
}

-(NSDate *)addDays:(int)numberOfDays {
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:numberOfDays toDate:self options:0];
}

-(NSDate *)addWeeks:(int)numberOfWeeks {
    return [self addDays:numberOfWeeks * 7];
}

@end
