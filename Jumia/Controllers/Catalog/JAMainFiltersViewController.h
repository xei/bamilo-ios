//
//  JAMainFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JASubFiltersViewController.h"
#import "JAFiltersView.h"

@protocol JAMainFiltersViewControllerDelegate <NSObject>

//the filters array used inside this class is passed by reference,
//so that every change we make, we're saving inside it
- (void)updatedFilters;

@end

@interface JAMainFiltersViewController : JABaseViewController <UITableViewDataSource, UITableViewDelegate, JASubFiltersViewControllerDelegate, JAFiltersViewDelegate>

@property (nonatomic, strong)NSArray* filtersArray;
@property (nonatomic, assign)id<JAMainFiltersViewControllerDelegate> delegate;

@end
