//
//  JACampaignsViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPickerScrollView.h"
#import "JANoConnectionView.h"
#import "JACampaignSingleView.h"

@interface JACampaignsViewController : JABaseViewController <UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, JAPickerScrollViewDelegate, JANoConnectionViewDelegate, JACampaignSingleViewDelegate>

@property (nonatomic, strong)NSArray* campaignTeasers;
@property (nonatomic, strong)NSString* startingTitle;

@end
