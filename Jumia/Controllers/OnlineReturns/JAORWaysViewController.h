//
//  JAORWaysViewController.h
//  Jumia
//
//  Created by telmopinto on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrder.h"

@interface JAORWaysViewController : JABaseViewController

@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSArray *items;

@end
