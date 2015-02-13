//
//  JASortingView.h
//  Jumia
//
//  Created by Telmo Pinto on 12/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

#define kJASORTINGVIEW_OPTIONS_ARRAY @[STRING_BEST_RATING, STRING_POPULARITY, STRING_NEW_IN, STRING_PRICE_UP, STRING_PRICE_DOWN, STRING_NAME, STRING_BRAND]

@protocol JASortingViewDelegate <NSObject>

- (void)selectedSortingMethod:(RICatalogSorting)catalogSorting;

@end

@interface JASortingView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign)id<JASortingViewDelegate>delegate;
- (void)setupWithFrame:(CGRect)frame
       selectedSorting:(RICatalogSorting)selectedSorting;
- (void)reloadForFrame:(CGRect)frame;
- (void)animateIn;

@end
