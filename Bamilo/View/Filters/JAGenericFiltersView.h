//
//  JAGenericFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAFiltersView.h"
#import "SearchFilterItem.h"

@interface JAGenericFiltersView : JAFiltersView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)SearchFilterItem* filter;

- (void)initializeWithFilter:(SearchFilterItem*)filter isLandscape:(BOOL)isLandscape;
- (void)saveOptions;

@end
