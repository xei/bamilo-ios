//
//  JACampaignProductCell.h
//  Jumia
//
//  Created by Telmo Pinto on 23/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICampaign.h"

@class JACampaignProductCell;

@protocol JACampaignProductCellDelegate <NSObject>

- (void)pressedAddToCartForProduct:(RICampaignProduct*)campaignProduct
                 withProductSimple:(NSString*)simpleSku;
- (void)pressedSizeOnView:(JACampaignProductCell*)campaignProductCell;
- (void)pressedCampaignWithSku:(NSString*)sku;

@end

@interface JACampaignProductCell : UICollectionViewCell

@property (nonatomic, assign)id<JACampaignProductCellDelegate>delegate;

@property (nonatomic, readonly)RICampaignProduct* campaignProduct;
@property (nonatomic, strong)NSString* chosenSize;

typedef void(^OnSelected)(void);

@property (nonatomic, copy) OnSelected onSelected;

- (void)loadWithCampaignProduct:(RICampaignProduct*)campaignProduct
           elapsedTimeInSeconds:(NSInteger)elapsedTimeInSeconds
                     chosenSize:(NSString*)chosenSize
               capaignHasBanner:(BOOL)hasBanner;

@end
