//
//  SignUpEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpEvent.h"
#import "EmailUtility.h"
#import "RICustomer.h"

@implementation SignUpEvent

#pragma mark - Overrides
+(NSString *)name {
    return @"SignUp";
}

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [super attributes];
    
    RICustomer *user = [RICustomer getCurrentCustomer];
    if(user) {
        //Email Domain
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:user.email];
        if(userEmailDomainComponents) {
            [attributes setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    
    return attributes;
}

@end
