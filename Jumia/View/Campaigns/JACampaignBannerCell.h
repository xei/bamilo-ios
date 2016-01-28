//
//  JACampaignBannerCell.h
//  Jumia
//
//  Created by Telmo Pinto on 23/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@interface JACampaignBannerCell : UICollectionViewCell

@property (nonatomic) JAClickableView *feedbackView;

- (void)loadWithImageView:(UIImageView*)imageView;

@end
