//
//  JASellerRatingsViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 27/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@class RIProduct;

@interface JASellerRatingsViewController : JABaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) RIProduct* product;
@property (nonatomic, assign) BOOL goToNewRatingButtonPressed;

@end
