//
//  JACampaignPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACampaignProductCell.h"

@class JACampaignPageView;

@protocol JACampaignPageViewDelegate <NSObject>

- (void)addToCartForProduct:(RICampaignProduct*)campaignProduct
          withProductSimple:(NSString*)simpleSku;
- (void)openCampaignProductWithTarget:(NSString*)targetString;
- (void)openPickerForCampaignPage:(JACampaignPageView*)campaignPage
                       dataSource:(NSArray*)dataSource
                     previousText:(NSString*)previousText;

@end

@interface JACampaignPageView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, JACampaignProductCellDelegate>

@property (nonatomic, assign)UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign)BOOL isLoaded;
@property (nonatomic, assign)id<JACampaignPageViewDelegate>delegate;

- (void)loadWithCampaign:(RICampaign*)campaign;

- (void)selectedSizeIndex:(NSInteger)index;

@end
