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

@protocol JATeaserPageViewDelegate <NSObject>

- (void)teaserPageIsReady:(id)teaserPage;

@end

@interface JATeaserPageView : UIView
@property (nonatomic, strong) UIScrollView* mainScrollView;
@property (nonatomic, strong) NSDictionary* teaserGroupings;
@property (nonatomic, weak) id<JATeaserPageViewDelegate> delegate;

// Newsletter
@property (nonatomic, strong) RIForm *newsletterForm;
@property (nonatomic, strong) id genderPickerDelegate;

- (void)loadTeasersForFrame:(CGRect)frame;
- (void)addTeaserGrouping:(NSString*)type;
- (void)addCustomViewToScrollView:(UIView *)view;

@end
