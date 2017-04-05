//
//  EmarsysPredictProtocol.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EmarsysPredictProtocolBase <NSObject>

@optional
- (BOOL)isPreventSendTransactionInViewWillAppear;

@end

@protocol EmarsysRecommendationsProtocol<EmarsysPredictProtocolBase>

@required
- (EMRecommendationRequest *)getReccomandtaionRequest:(EMRecommendationRequest *)transaction;
- (NSString *)getRecommandationLogic;
- (void)reccomandationResult:(EMRecommendationResult *)result;

@end

@protocol EmarsysWebExtendProtocol<EmarsysPredictProtocolBase>

@optional
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction;

@end


@protocol EmarsysPredictProtocol<EmarsysWebExtendProtocol, EmarsysRecommendationsProtocol>
@end
