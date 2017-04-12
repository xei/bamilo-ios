//
//  EventUtilities.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICart.h"

@interface EventUtilities : NSObject

+(NSString *) getEventCategories:(RICart *)cart;
+(NSString *) getSearchKeywords:(NSString *)query;

@end
