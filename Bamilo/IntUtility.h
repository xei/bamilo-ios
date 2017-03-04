//
//  IntUtility.h
//  Jumia
//
//  Created by Narbeh Mirzaei on 1/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntUtility : NSObject

+(int) randomInt;
+(int) randomIntBetween:(int)min maxInt:(int)max;

@end
