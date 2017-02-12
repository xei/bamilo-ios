//
//  DataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"

typedef void(^DataCompletion)(id data, NSError *error);

@interface DataManager : NSObject

+ (instancetype)sharedInstance;
- (void)getUserAddressList:(DataCompletion)completion;
- (void)loginUserViaUsername:(NSString *)username password:(NSString *)password complitionBlock:(RequestCompletion)complitionBlock;

@end
