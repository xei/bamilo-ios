//
//  JACampaignsViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPickerScrollView.h"
#import "JAPicker.h"
#import "JACampaignPageView.h"
#import "RITeaserGrouping.h"
#import "JATopTabsView.h"
#import "Bamilo-Swift.h"

@interface JACampaignsViewController : JABaseViewController <UIScrollViewDelegate, JAPickerDelegate, JACampaignPageViewDelegate, JATopTabsViewDelegate, DataServiceProtocol>

@property (nonatomic, strong)RITeaserGrouping* teaserGrouping;
@property (nonatomic, strong)NSString* startingTitle;
@property (nonatomic, strong)NSString* campaignId;

@property (nonatomic, strong) NSString* purchaseTrackingInfo;

@end
