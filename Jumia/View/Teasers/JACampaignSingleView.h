//
//  JACampaignSingleView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICampaign.h"

@interface JACampaignSingleView : UIView

+ (JACampaignSingleView *)getNewJACampaignSingleView;

- (void)loadWithCampaign:(RICampaign*)campaign;

@end
