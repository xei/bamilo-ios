//
//  RequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestSuccessBlock)(id data);
typedef void(^RequestFailureBlock)(NSError *error);

@interface RequestManager : NSObject

+(void) asyncRequest:(NSURLRequest *)request success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;

@end
