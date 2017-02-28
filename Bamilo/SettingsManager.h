//
//  SettingsManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

+(id) loadSettingsForKey:(id)key;
+(BOOL) saveSettings:(id)settings forKey:(id)key;

@end
