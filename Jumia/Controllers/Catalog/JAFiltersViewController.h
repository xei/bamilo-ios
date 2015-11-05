//
//  JAFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JAFiltersViewControllerDelegate <NSObject>

- (void)updatedFilters:(NSArray*)updatedFiltersArray;

@end

@interface JAFiltersViewController : JABaseViewController

@property (nonatomic, strong)NSArray* filtersArray;
@property (nonatomic, assign)id<JAFiltersViewControllerDelegate> delegate;

@end
