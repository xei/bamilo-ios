//
//  JAMainFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@protocol JAMainFiltersViewControllerDelegate <NSObject>

- (void)filtersWhereUpdated;

@end

@interface JAMainFiltersViewController : JABaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray* filtersArray;
@property (nonatomic, assign)id<JAMainFiltersViewControllerDelegate> delegate;

@end
