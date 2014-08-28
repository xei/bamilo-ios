//
//  JAGenderComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGenderComponent.h"

@implementation JAGenderComponent

- (void)initSegmentedControl:(NSArray *)itens
{
    NSInteger i = 0;
    for (NSString *temp in itens) {
        [self.segmentedControl setTitle:temp
                      forSegmentAtIndex:i];
        
        i++;
    }
}

+ (JAGenderComponent *)getNewJAGenderComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAGenderComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAGenderComponent class]]) {
            return (JAGenderComponent *)obj;
        }
    }
    
    return nil;
}

@end
