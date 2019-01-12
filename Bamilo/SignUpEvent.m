//
//  SignUpEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpEvent.h"
#import "EmailUtility.h"
#import "Bamilo-Swift.h"

@implementation SignUpEvent

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [super attributes];
    
    NSString *userMail = CurrentUserManager.user.email;
    if(VALID_NOTEMPTY(userMail, NSString)) {
        //Email Domain
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:userMail];
        if(userEmailDomainComponents) {
            [attributes setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    
    return attributes;
}

@end
