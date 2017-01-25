//
//  IntUtility.m
//  Jumia
//
//  Created by Narbeh Mirzaei on 1/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "IntUtility.h"

@implementation IntUtility

+(int)randomInt {
    return [IntUtility randomIntBetween:1 maxInt:999999];
}

+(int)randomIntBetween:(int)min maxInt:(int)max {
    return (min + arc4random() % (max - min + 1));
}

@end
