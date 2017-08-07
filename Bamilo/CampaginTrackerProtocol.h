//
//  CampaginTrackerProtocol.h
//  Bamilo
//
//  Created by Ali Saeedifar on 7/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CampaginTrackerProtocol <NSObject>

- (void)trackCampaignData:(NSDictionary *)campaignData;

@end
