//
//  JAGenericFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAFiltersView.h"

@interface JAGenericFiltersView : JAFiltersView <UITableViewDelegate, UITableViewDataSource>


- (void)initializeWithFilter:(id)filter isLandscape:(BOOL)isLandscape;
- (id)getFilter;
- (void)saveOptions;

@end
