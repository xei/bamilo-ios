//
//  ThemeColor.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeColor : NSObject

@property (strong, nonatomic) NSDictionary *palette;

+(instancetype) colorWithPalette:(NSDictionary *)palette;

@end
