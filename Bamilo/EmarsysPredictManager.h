//
//  EmarsysPredictManager.h
//  Bamilo
//
//  Created by Ali Saeedifar on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>
#import "EmarsysPredictProtocol.h"
#import "RICustomer.h"


@interface EmarsysPredictManager : NSObject

+ (void)setConfigs;
+ (void)sendTransactionsOf:(UIViewController *)viewController;
+ (void)setCustomer:(RICustomer *)customer;
+ (void)userLoggedOut;

@end
