//
//  LoginEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "LoginEvent.h"
#import "RICustomer.h"
#import "EmailUtility.h"

@implementation LoginEvent

NSString *const kEventLoginMethod = @"LoginMethod";
NSString *const kEventEmailDomain = @"EmailDomain";

#pragma mark - Overrides
+(NSString *)name {
    return @"Login";
}

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [super attributes];
    
    RICustomer *user = [RICustomer getCurrentCustomer];
    if(user) {
        //Gender
        if(user.gender) {
            [attributes setObject:[user.gender substringToIndex:0] forKey:kEventUserGender]; //m/f
        }
        
        //Email Domain
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:user.email];
        if(userEmailDomainComponents) {
            [attributes setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    
    return attributes;
}

@end
