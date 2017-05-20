//
//  TagTrackerProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TagTrackerCompletion)(NSError *error);

@protocol TagTrackerProtocol <NSObject>

-(void) sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion;

@end
