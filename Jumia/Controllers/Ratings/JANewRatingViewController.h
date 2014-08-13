//
//  JANewRatingViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewRatingViewController : JABaseViewController

@property (strong, nonatomic) NSString *ratingProductSku;
@property (strong, nonatomic) NSString *ratingProductBrand;
@property (strong, nonatomic) NSString *ratingProductNameForLabel;
@property (strong, nonatomic) NSNumber *ratingProductNewPriceForLabel;
@property (strong, nonatomic) NSNumber *ratingProductOldPriceForLabel;

@end
