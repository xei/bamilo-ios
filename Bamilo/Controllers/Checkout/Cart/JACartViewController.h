//
//  JACartViewController.h
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICart.h"

@interface JACartViewController : JABaseViewController <UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate>

@property (strong, nonatomic) RICart *cart;

@end
