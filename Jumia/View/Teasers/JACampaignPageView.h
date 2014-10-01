//
//  JACampaignPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACampaignSingleView.h"

@interface JACampaignPageView : UIView

@property (nonatomic, assign)id<JACampaignSingleViewDelegate>delegate;

- (void)loadWithCampaignUrl:(NSString*)campaignUrl;

@end
