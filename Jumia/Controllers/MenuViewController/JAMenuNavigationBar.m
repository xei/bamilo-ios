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
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation JAMenuNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 0, 230, 44)];
        self.searchBar.barTintColor = [UIColor whiteColor];
        self.searchBar.placeholder = @"Search";
        
        UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
        textFieldSearch.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0f];
        
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        self.titleViewCustom = [[UIView alloc] initWithFrame:self.searchBar.frame];
        [self.titleViewCustom addSubview:self.searchBar];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(-10, 12, 12, 20);
        [self.backButton setImage:[UIImage imageNamed:@"btn_back"]
                         forState:UIControlStateNormal];
        
        [self.backButton setImage:[UIImage imageNamed:@"btn_back_pressed"]
                         forState:UIControlStateSelected];
        
        [self.backButton addTarget:self
                            action:@selector(backButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.backButton.alpha = 0.0f;
        
        [self.titleViewCustom addSubview:self.backButton];
        
        [self.viewForBaselineLayout addSubview:self.titleViewCustom];
    }
    
    return self;
}

#pragma mark - Add back button

- (void)addBackButtonToNavBar
{
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.searchBar.frame = CGRectMake(30, 0, 200, 44);
                     } completion:^(BOOL finished) {
                         self.backButton.alpha = 1.0f;
                     }];
}

- (void)removeBackButtonFromNavBar
{
    self.backButton.alpha = 0.0f;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.searchBar.frame = CGRectMake(0, 0, 220, 44);
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
