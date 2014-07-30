//
//  JAMenuNavigationBar.m
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMenuNavigationBar.h"

@interface JAMenuNavigationBar ()

@property (strong, nonatomic) UIView *titleViewCustom;
@property (strong, nonatomic) UIButton *backButton;

@end

@implementation JAMenuNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 0, 235, 44)];
        self.searchBar.barTintColor = [UIColor whiteColor];
        self.searchBar.placeholder = @"Search";
        
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor orangeColor]];
        
        UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
        textFieldSearch.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0f];
        
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        self.titleViewCustom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 45)];
        self.titleViewCustom.backgroundColor = [UIColor whiteColor];
        [self.titleViewCustom addSubview:self.searchBar];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(4, 1, 24, 40);
        [self.backButton setImage:[UIImage imageNamed:@"btn_back"]
                         forState:UIControlStateNormal];
        
        [self.backButton setImage:[UIImage imageNamed:@"btn_back_pressed"]
                         forState:UIControlStateHighlighted];
        
        [self.backButton addTarget:self
                            action:@selector(backButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.backButton.alpha = 0.0f;
        
        [self.titleViewCustom addSubview:self.backButton];
        
        [self.viewForBaselineLayout addSubview:self.titleViewCustom];
    }
    
    return self;
}

#pragma mark - Back button methods

- (void)addBackButtonToNavBar
{
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchBar.frame = CGRectMake(35, 0, 200, 44);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.backButton.alpha = 1.0f;
                                          }];
                     }];
}

- (void)removeBackButtonFromNavBar
{
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.backButton.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2f
                                          animations:^{
                                              self.searchBar.frame = CGRectMake(6, 0, 235, 44);
                                          }];
                     }];
}

- (void)backButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelButtonPressedInMenuSearchBar
                                                        object:nil];
}

#pragma mark - Set search bar delegate

- (void)setSearchBarDelegate:(UIViewController<UISearchBarDelegate> *)destinationViewController
{
    self.searchBar.delegate = destinationViewController;
}

@end
