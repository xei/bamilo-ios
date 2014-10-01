//
//  JACampaignSingleView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICampaign.h"

@class JACampaignSingleView;

@protocol JACampaignSingleViewDelegate <NSObject>

- (void)addToCartForProduct:(RICampaign*)campaign
          withProductSimple:(NSString*)simpleSku;
- (void)sizePressedOnView:(JACampaignSingleView*)campaignSingleView;
- (void)pressedCampaignWithSku:(NSString*)sku;

@end

@interface JACampaignSingleView : UIView

@property (nonatomic, assign)id<JACampaignSingleViewDelegate>delegate;

+ (JACampaignSingleView *)getNewJACampaignSingleView;

- (void)loadWithCampaign:(RICampaign*)campaign;

@property (nonatomic, readonly)RICampaign* campaign;
@property (nonatomic, strong)NSString* chosenSize;

@end
