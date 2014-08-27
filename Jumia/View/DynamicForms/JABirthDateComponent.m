//
//  JABirthDateComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABirthDateComponent.h"

@implementation JABirthDateComponent

+ (JABirthDateComponent *)getNewJABirthDateComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JABirthDateComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JABirthDateComponent class]]) {
            return (JABirthDateComponent *)obj;
        }
    }
    
    return nil;
}

@end