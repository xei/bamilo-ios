//
//  BaseDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseDataManager.h"

@implementation BaseDataManager

+ (instancetype)sharedInstance {
    NSAssert(false, @"BaseDataManager sharedInstance called. Override sharedInstance in sub-class");
    return nil;
}

@end
