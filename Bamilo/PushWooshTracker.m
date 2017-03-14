//
//  PushWooshTracker.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PushWooshTracker.h"

@implementation PushWooshTracker

static PushWooshTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PushWooshTracker new];
    });
    
    return instance;
}

@end
