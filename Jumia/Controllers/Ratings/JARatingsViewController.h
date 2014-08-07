//
//  JARatingsViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProductRatings.h"

@interface JARatingsViewController : JABaseViewController

@property (strong, nonatomic) RIProductRatings *productRatings;
@property (strong, nonatomic) NSString *productBrand;
@property (strong, nonatomic) NSNumber *productNewPrice;
@property (strong, nonatomic) NSNumber *productOldPrice;

@end
