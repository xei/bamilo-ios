//
//  EmarsysMobileEngageTracker.m
//  Bamilo
//
//  Created by Ali Saeedifar on 5/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysMobileEngageTracker.h"
#import "RICustomer.h"

@implementation EmarsysMobileEngageTracker

static EmarsysMobileEngageTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [EmarsysMobileEngageTracker new];
    });
    return instance;
}


//Override
- (void)postEventByName:(NSString *)eventName attributes:(NSDictionary *)attributes {
    [super postEventByName:eventName attributes:attributes];
    [[EmarsysMobileEngage sharedInstance] sendCustomEvent:eventName attributes:attributes completion:nil];
}

@end
