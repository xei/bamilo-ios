//
//  RIScreenTarget.m
//  Jumia
//
//  Created by Jose Mota on 29/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAScreenTarget.h"

@implementation JAScreenTarget

- (instancetype)initWithTarget:(RITarget *)target {
    self = [super init];
    if (self) {
        self.target = target;
        self.navBarLayout = [JANavigationBarLayout new];
        self.screenInfo = [NSMutableDictionary new];
        [self.navBarLayout setShowBackButton:YES];
    }
    return self;
}

- (instancetype)initWithTarget:(RITarget *)target andTitle:(NSString *)title {
    self = [[JAScreenTarget alloc] initWithTarget:target];
    if (self) {
        [self.navBarLayout setTitle:title];
    }
    return self;
}

@end
