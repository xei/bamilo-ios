//
//  FormHeaderModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormHeaderModel.h"

@implementation FormHeaderModel

-(instancetype)initWithHeaderTitle:(NSString *)headerString {
    if (self = [super init]) {
        self.headerString = headerString;
    }
    
    return self;
}

@end
