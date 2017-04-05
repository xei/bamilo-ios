//
//  EmarsysPredictProtocol.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol EmarsysPredictProtocol

@optional
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction;
- (EMRecommendationRequest *)getReccomandtaionRequest:(EMRecommendationRequest *)transaction;
- (NSString *)getRecommandationLogic;
- (void)reccomandationResult:(EMRecommendationResult *)result;
- (BOOL)isPreventSendTransactionInViewWillAppear;

@end
