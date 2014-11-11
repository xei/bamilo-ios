//
//  JACategoryFilterViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 18/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACategoryFiltersView.h"

@class RICategory;

@protocol JACategoryFilterViewControllerDelegate <NSObject>

- (void)categoriesFilterSelectedCategory:(RICategory*)category;

@end

@interface JACategoryFilterViewController : JABaseViewController <JACategoryFiltersViewDelegate>

@property (nonatomic, strong)NSArray* categoriesArray;
@property (nonatomic, strong)RICategory* selectedCategory;
@property (nonatomic, assign)id<JACategoryFilterViewControllerDelegate> delegate;

@end
