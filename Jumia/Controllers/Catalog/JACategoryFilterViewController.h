//
//  JACategoryFilterViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 18/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubFiltersViewController.h"
#import <UIKit/UIKit.h>
#import "JACategoryFiltersView.h"

@class RICategory;

@interface JACategoryFilterViewController : JASubFiltersViewController

@property (nonatomic, strong)NSArray* categoriesArray;
@property (nonatomic, strong)RICategory* selectedCategory;
@property (nonatomic, assign)id<JACategoryFiltersViewDelegate> categoryFiltersViewDelegate;

@end
