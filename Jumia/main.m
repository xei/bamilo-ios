//
//  main.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
#if defined(FORCE_RTL) && FORCE_RTL
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSArray arrayWithObject:@"fa-IR"] forKey:@"AppleLanguages"];
        [defaults synchronize];
#endif
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([JAAppDelegate class]));
    }
}
