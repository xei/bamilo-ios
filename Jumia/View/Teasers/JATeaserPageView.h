//
//  JATeaserPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITeaserGrouping.h"
#import "JACampaignsTeaserView.h"

@interface JATeaserPageView : UIView

@property (nonatomic, strong) NSDictionary* teaserGroupings;

// Newsletter
@property (nonatomic, strong) RIForm *newsletterForm;
@property (nonatomic, strong) id genderPickerDelegate;

- (void)loadTeasersForFrame:(CGRect)frame;
- (void)addTeaserGrouping:(NSString*)type;

@end
