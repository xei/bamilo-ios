//
//  JAOtherOffersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JABaseViewController.h"
#import "RIProduct.h"

@interface JAOtherOffersViewController : JABaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong)RIProduct* product;

@end
