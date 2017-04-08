//
//  EmailUtility.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmailUtility.h"

@implementation EmailUtility

+(NSString *) emailRegexPattern {
    return @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
}

+(NSArray *)getEmailDomain:(NSString *)email {
    NSArray *emailComponents = [email componentsSeparatedByString:@"@"];
    if(emailComponents.count == 2) {
        NSArray *emailDomainComponents = [emailComponents[1] componentsSeparatedByString:@"."];
        if(emailDomainComponents.count == 2) {
            return emailDomainComponents;
        }
    }
    
    return nil;
}

+(BOOL)isValidEmail:(NSString *)email {
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", [EmailUtility emailRegexPattern]] evaluateWithObject:email];
}

@end
