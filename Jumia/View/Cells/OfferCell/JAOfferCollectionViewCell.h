//
//  JAOfferCollectionViewCell.h
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProductOffer.h"

@interface JAOfferCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;

- (void)loadWithProductOffer:(RIProductOffer*)productOffer;

@end
