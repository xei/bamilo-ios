//
//  EmarsysPredictManager.m
//  Bamilo
//
//  Created by Ali saiedifar on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysPredictManager.h"
#import "RICart.h"

@implementation EmarsysPredictManager

+ (void)sendTransactionsOf:(UIViewController *)viewController {
    
    if (![viewController conformsToProtocol:@protocol(EmarsysPredictProtocolBase)]) {
        return;
    }
    
    EMSession *emarsysSession = [EMSession sharedSession];
    EMTransaction *transaction = [[EMTransaction alloc] init];
    [transaction setCart:[[RICart sharedInstance] convertItems]];
    
    if ([viewController conformsToProtocol:@protocol(EmarsysWebExtendProtocol)]) {
        transaction = [((id<EmarsysWebExtendProtocol>)viewController) getDataCollection:transaction];
    }
    
    if ([viewController conformsToProtocol:@protocol(EmarsysRecommendationsProtocol)]) {
        NSString *logic = [((id<EmarsysRecommendationsProtocol>)viewController) getRecommandationLogic];
        EMRecommendationRequest *recommend = [[EMRecommendationRequest alloc] initWithLogic: logic];
        recommend = [((id<EmarsysRecommendationsProtocol>)viewController) getReccomandtaionRequest:recommend];
        recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
            // Process result
            NSLog(@"%@", result.featureID);
            [((id<EmarsysRecommendationsProtocol>)viewController) reccomandationResult:result];
        };
        [transaction recommend:recommend];
    }
    
    [emarsysSession sendTransaction:transaction errorHandler:^(NSError *_Nonnull error) {
       NSLog(@"value: %@", error);
       return;
    }];
}

+ (void)setCustomer:(RICustomer *)customer {
    EMSession *emarsysSession = [EMSession sharedSession];
    if (customer.email) {
        [emarsysSession setCustomerEmail:customer.email];
    }
    if (customer.customerId) {
        [emarsysSession setCustomerID:[customer.customerId stringValue]];
    }
}

+ (void)userLoggedOut {
    EMSession *emarsysSession = [EMSession sharedSession];
    [emarsysSession setCustomerID:nil];
    [emarsysSession setCustomerEmail:nil];
}

@end
