//
//  FormItemValidation.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormItemValidation.h"

@implementation FormItemValidation

- (instancetype)initWithRequired:(Boolean)isRequired max:(NSUInteger)maxValue min:(NSUInteger)minValue withRegxPatter:(NSString *)regxPattern {
    self = [super init];
    if (self) {
        self.isRequired = isRequired;
        self.max = maxValue;
        self.min = minValue;
        self.regxPattern = regxPattern;
    }
    return self;
}

@end
