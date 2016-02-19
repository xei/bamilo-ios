//
//  JASuccessPageViewController.h
//  Jumia
//
//  Created by Jose Mota on 17/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICart.h"

@interface JASuccessPageViewController : JABaseViewController

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) NSString *rrTargetString;

@end