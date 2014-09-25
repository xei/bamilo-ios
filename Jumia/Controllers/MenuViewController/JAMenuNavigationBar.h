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
@property (strong, nonatomic) UIButton *backButton;
@property (assign, nonatomic) BOOL isBackVisible;

- (void)addBackButtonToNavBar;
- (void)removeBackButtonFromNavBar;
- (void)removeBackButtonFromNavBarNoResetVariable;
- (void)setSearchBarDelegate:(UIViewController<UISearchBarDelegate> *)destinationViewController;

@end
