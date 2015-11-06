//
//  JAFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 14/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JAFiltersViewDelegate <NSObject>

- (void)updatedValues;

@end

@interface JAFiltersView : UIView

@property (nonatomic, assign)id<JAFiltersViewDelegate> filtersViewDelegate;

- (void)saveOptions;

- (void)reaload;

@end
