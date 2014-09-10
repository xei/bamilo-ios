//
//  JAUndefinedSearchView.h
//  Jumia
//
//  Created by Miguel Chaves on 10/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISearchSuggestion.h"

@interface JAUndefinedSearchView : UIView

+ (JAUndefinedSearchView *)getNewJAUndefinedSearchView;

- (void)setupWithUndefinedSearchResult:(RIUndefinedSearchTerm *)searchTerm;

@end
