//
//  JAGenericFilterViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubFiltersViewController.h"
#import "RIFilter.h"

@interface JAGenericFilterViewController : JASubFiltersViewController

@property (nonatomic, strong)RIFilter* filter;

@end
