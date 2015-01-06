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

@interface JACampaignsViewController : JABaseViewController <UIScrollViewDelegate, JAPickerScrollViewDelegate, JAPickerDelegate, JACampaignPageViewDelegate>

@property (nonatomic, strong)NSArray* campaignTeasers;
@property (nonatomic, strong)NSString* startingTitle;
@property (nonatomic, strong)NSString* campaignId;

@end
