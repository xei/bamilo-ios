//
//  JARecentSearchesViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIRecentSearch.h"

@protocol JARecentSearchesDelegate <NSObject>

- (void)didSelectedRecentSearch:(RIRecentSearch *)recentSearch;

@end

@interface JARecentSearchesViewController : JABaseViewController

@property (weak, nonatomic) id<JARecentSearchesDelegate>delegate;

@end
