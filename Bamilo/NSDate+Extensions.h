//
//  NSDate+Extensions.h
//  Bamilo
//
//  Created by Ali Saeedifar on 3/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

-(NSString *) convertToJalali;
-(NSString *) toWebDateString;
-(NSDate *) addDays:(int)numberOfDays;
-(NSDate *) addWeeks:(int)numberOfWeeks;

@end
