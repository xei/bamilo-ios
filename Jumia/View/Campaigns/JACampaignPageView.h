//
//  JACampaignPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACampaignProductCell.h"

@interface JACampaignPageView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign)UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign)id<JACampaignProductCellDelegate>singleViewDelegate;
@property (nonatomic, assign)BOOL isLoaded;

- (void)loadWithCampaign:(RICampaign*)campaign;

@end
