//
//  DataServiceProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RetryHandler)(BOOL success);

@protocol DataServiceProtocol <NSObject>

- (void)bind:(id)data forRequestId:(int)rid;

@optional
- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid;
- (void)errorHandler:(NSError *)error forRequestID:(int)rid;

@end
