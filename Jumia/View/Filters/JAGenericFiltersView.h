//
//  JAGenericFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIFilter.h"

@interface JAGenericFiltersView : UIView <UITableViewDelegate, UITableViewDataSource>

- (void)initializeWithFilter:(RIFilter*)filter;
- (void)saveOptions;

@end
