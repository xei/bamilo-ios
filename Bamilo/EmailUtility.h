//
//  EmailUtility.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailUtility : NSObject

+(NSString *) emailRegexPattern;
+(NSArray *) getEmailDomain:(NSString *)email; // narbeh@gmail.com => [@"gmail", @"com"]
+(BOOL) isValidEmail:(NSString *)email;

@end
