//
//  JASearchView.h
//  Jumia
//
//  Created by Telmo Pinto on 15/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBarListener <NSObject>

- (void)searchBarSearched:(UISearchBar *)searchBar;

@end

@interface JASearchView : UIView <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame andText:(NSString *)text;
- (void)resetFrame:(CGRect)frame;

@end
