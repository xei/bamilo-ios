//
//  JAMenuNavigationBar.h
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMenuNavigationBar : UINavigationBar

@property (strong, nonatomic) UISearchBar *searchBar;

- (void)addBackButtonToNavBar;
- (void)removeBackButtonFromNavBar;
- (void)setSearchBarDelegate:(UIViewController<UISearchBarDelegate> *)destinationViewController;

@end
