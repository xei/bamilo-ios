//
//  JANewRatingViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIProduct;
@class RIProductRatings;

@interface JANewRatingViewController : JABaseViewController

@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) RIProductRatings *productRatings;
@property (assign, nonatomic) BOOL goToNewRatingButtonPressed;

@end
