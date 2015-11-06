//
//  JAFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 14/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFiltersView.h"

@implementation JAFiltersView

- (void)saveOptions
{
    if (self.filtersViewDelegate && [self.filtersViewDelegate respondsToSelector:@selector(updatedValues)]) {
        [self.filtersViewDelegate updatedValues];
    }
}

- (void)reload
{
    //virtual, implement on subclasses
}

@end
