//
//  JAPriceFilterViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 13/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubFiltersViewController.h"
#import "RIFilter.h"


@interface JAPriceFilterViewController : JASubFiltersViewController

@property (nonatomic, strong)RIFilterOption* priceFilterOption;

@end
