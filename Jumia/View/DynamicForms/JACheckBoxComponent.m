//
//  JACheckBoxComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckBoxComponent.h"

@implementation JACheckBoxComponent

+ (JACheckBoxComponent *)getNewJACheckBoxComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACheckBoxComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACheckBoxComponent class]]) {
            return (JACheckBoxComponent *)obj;
        }
    }
    
    return nil;
}

@end
