//
//  EmarsysMobileEngageTracker.m
//  Bamilo
//
//  Created by Ali Saeedifar on 5/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysMobileEngageTracker.h"

@interface EmarsysMobileEngageTracker()
@property (nonatomic, strong) NSArray<NSString *>* eligableEvents;
@end

@implementation EmarsysMobileEngageTracker

static EmarsysMobileEngageTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [EmarsysMobileEngageTracker new];
    });
    
    return instance;
}

- (NSArray *)eligableEvents {
    if (!_eligableEvents) {
        _eligableEvents = @[[LoginEvent name],
                            [LogoutEvent name],
                            [SignUpEvent name],
                            [OpenAppEvent name],
                            [AddToFavoritesEvent name],
                            [AddToCartEvent name],
                            [AbandonCartEvent name],
                            [PurchaseEvent name],
                            [SearchEvent name],
                            [ViewProductEvent name]];
    }
    return _eligableEvents;
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    [[EmarsysMobileEngage sharedInstance] sendCustomEvent:name attributes:attributes completion:nil];
}

-(BOOL)isEventEligable:(NSString *)eventName {
    return [self.eligableEvents indexOfObjectIdenticalTo: eventName] != NSNotFound;;
}

@end
