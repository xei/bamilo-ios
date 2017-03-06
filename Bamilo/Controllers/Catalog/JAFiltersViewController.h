//
//  JAFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseSearchFilterItem.h"
#import "BaseViewController.h"
#import "SearchCategoryFilter.h"

@protocol JAFiltersViewControllerDelegate <NSObject>

- (void)updatedFilters:(NSArray<BaseSearchFilterItem *>*)updatedFiltersArray;
- (void)subCategorySelected:(NSString *)subCategoryUrlKey;

@end

@interface JAFiltersViewController :BaseViewController

@property (nonatomic, strong)  NSArray<BaseSearchFilterItem *>* filtersArray;
@property (nonatomic , assign) int priceFilterIndex;
@property (nonatomic, assign) id<JAFiltersViewControllerDelegate> delegate;
@property (nonatomic, strong) SearchCategoryFilter *subCatsFilter;

@end
