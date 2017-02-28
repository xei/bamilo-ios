//
//  SettingsManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SettingsManager.h"

@implementation SettingsManager

+(id)loadSettingsForKey:(id)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(BOOL)saveSettings:(id)settings forKey:(id)key {
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
