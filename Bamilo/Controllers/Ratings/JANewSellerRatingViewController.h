//
//  JANewSellerRatingViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 03/03/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@class RIProduct;

@interface JANewSellerRatingViewController : JABaseViewController

@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) NSNumber* sellerAverageReviews;

@end
