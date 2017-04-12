//
//  EventUtilities.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EventUtilities.h"

@implementation EventUtilities

+(NSString *)getEventCategories:(RICart *)cart {
    NSMutableArray *categories = [NSMutableArray array];
    
    return [categories componentsJoinedByString:@","];
}

@end
