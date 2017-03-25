//
//  ThreadManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ThreadManagerMainRunBlock)(void);

@interface ThreadManager : NSObject

+ (void)executeOnMainThread:(ThreadManagerMainRunBlock)executionBlock;

@end
