//
//  ThreadManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ThreadManager.h"

@implementation ThreadManager

+ (void)executeOnMainThread:(ThreadManagerMainRunBlock)executionBlock {
    if(executionBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            executionBlock();
        });
    }
}

@end
