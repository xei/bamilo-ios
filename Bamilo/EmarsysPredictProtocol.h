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

@optional - (NSArray<EMRecommendationRequest *> *)getRecommendations;

@end

@protocol EmarsysWebExtendProtocol<EmarsysPredictProtocolBase>

- (EMTransaction *)getDataCollection:(EMTransaction *)transaction;

@end


@protocol EmarsysPredictProtocol<EmarsysWebExtendProtocol, EmarsysRecommendationsProtocol>
@end
