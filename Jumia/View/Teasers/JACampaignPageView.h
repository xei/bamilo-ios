//
//  JACampaignPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACampaignSingleView.h"

@protocol JACampaignPageViewDelegate <NSObject>

- (void)loadFailedWithResponse:(RIApiResponse)apiResponse;

@end

@interface JACampaignPageView : UIView

@property (nonatomic, assign)id<JACampaignPageViewDelegate>delegate;
@property (nonatomic, assign)id<JACampaignSingleViewDelegate>singleViewDelegate;

- (void)loadWithCampaignUrl:(NSString*)campaignUrl;
- (void)updateTimerOnAllCampaigns:(NSInteger)elapsedTimeInSeconds;

@end
