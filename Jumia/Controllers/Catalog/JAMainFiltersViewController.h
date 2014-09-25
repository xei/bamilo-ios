//
//  JAMainFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JACategoryFilterViewController.h"

@protocol JAMainFiltersViewControllerDelegate <NSObject>

//only the category is passed as argument, because the filters array used inside this class is passed by reference,
//so that every change we make, we're saving inside it
- (void)updatedFiltersAndCategory:(RICategory*)category;

@end

@interface JAMainFiltersViewController : JABaseViewController <UITableViewDataSource, UITableViewDelegate, JACategoryFilterViewControllerDelegate>

@property (nonatomic, strong)NSArray* filtersArray;
@property (nonatomic, strong)NSArray* categoriesArray;
@property (nonatomic, strong)RICategory* selectedCategory;
@property (nonatomic, assign)id<JAMainFiltersViewControllerDelegate> delegate;

@end
