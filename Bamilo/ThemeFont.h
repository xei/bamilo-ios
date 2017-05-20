//
//  ThemeFont.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeFont : NSObject

@property (strong, nonatomic) NSDictionary *variations;

+(instancetype) fontWithVariations:(NSDictionary *)variations;

@end
