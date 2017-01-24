//
//  JAPriceFiltersView.h
//  Jumia
//
//  Created by Telmo Pinto on 10/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAFiltersView.h"
#import "RIFilter.h"
#import "TTRangeSlider.h"

@interface JAPriceFiltersView : JAFiltersView <TTRangeSliderDelegate>

- (void)initializeWithPriceFilterOption:(RIFilterOption*)priceFilterOption;
- (void)saveOptions;

@end
