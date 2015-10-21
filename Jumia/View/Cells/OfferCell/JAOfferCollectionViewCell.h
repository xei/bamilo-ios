//
//  JAOfferCollectionViewCell.h
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProductOffer.h"
#import "RIProductSimple.h"

@interface JAOfferCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;

- (void)loadWithProductOffer:(RIProductOffer*)productOffer withProductSimple:(RIProductSimple* )productSimple;
- (void)setProductSimple:(RIProductSimple*)productSimple;
@end
