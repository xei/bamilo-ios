//
//  EmarsysPredictProtocol.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol EmarsysPredictProtocol

@optional - (EMTransaction *)getDataCollection:(EMTransaction *)transaction;
@optional - (EMRecommendationRequest *)getReccomandtaionRequest:(EMRecommendationRequest *)transaction;
@optional - (NSString *)getRecommandationLogic;
@optional - (void)reccomandationResult:(EMRecommendationResult *)result;
@optional - (BOOL)preventSendTransactionInViewWillAppear;

@end
