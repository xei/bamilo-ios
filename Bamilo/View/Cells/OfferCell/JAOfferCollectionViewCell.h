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
#import "JAClickableView.h"

@protocol JAOfferCollectionViewCellDelegate <NSObject>
- (void)sellerNameTappedByProductOffer:(RIProductOffer *)offer;
@end


@interface JAOfferCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<JAOfferCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) JAClickableView *addToCartClicableView;
@property (nonatomic, strong) JAClickableView *sizeClickableView;

- (void)loadWithProductOffer:(RIProductOffer*)productOffer withProductSimple:(RIProductSimple* )productSimple;
- (void)setProductSimple:(RIProductSimple*)productSimple;
@end
