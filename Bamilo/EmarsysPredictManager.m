//
//  EmarsysPredictManager.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/29/17.
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
    __block EMTransaction *transaction = [[EMTransaction alloc] init];
    [transaction setCart:[[RICart sharedInstance] convertItems]];
    
    if ([viewController conformsToProtocol:@protocol(EmarsysWebExtendProtocol)] && [viewController respondsToSelector:@selector(getDataCollection:)]) {
        transaction = [((id<EmarsysWebExtendProtocol>)viewController) getDataCollection:transaction];
    }
    
    if ([viewController conformsToProtocol:@protocol(EmarsysRecommendationsProtocol)]) {
        NSArray<EMRecommendationRequest *> * recommendations = [((id<EmarsysRecommendationsProtocol>)viewController) getRecommendations];
        [recommendations enumerateObjectsUsingBlock:^(EMRecommendationRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [transaction recommend:obj];
        }];
    }
    
    [emarsysSession sendTransaction:transaction errorHandler:^(NSError *_Nonnull error) {
        if ([viewController respondsToSelector:@selector(recievedErrorSendingTransition:)]) {
            [viewController performSelector:@selector(recievedErrorSendingTransition:) withObject:error];
        }
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
