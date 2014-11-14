//
//  JACategoryFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAFiltersView.h"
#import "RICategory.h"

@protocol JACategoryFiltersViewDelegate <NSObject>

- (void)selectedCategory:(RICategory*)category;

@end

@interface JACategoryFiltersView : JAFiltersView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)id<JACategoryFiltersViewDelegate>delegate;

- (void)initializeWithCategories:(NSArray*)categories
                selectedCategory:(RICategory*)selectedCategory;
- (void)saveOptions;

@end
