//
//  JAMainFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAMainFiltersViewController : JABaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray* filtersArray;

@end
