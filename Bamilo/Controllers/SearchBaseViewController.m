//
//  SearchBaseViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SearchBaseViewController.h"
#import "JACenterNavigationController.h"

#define kSearchViewBarHeight 44.0f

@implementation SearchBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView) name:kDidPressSearchButtonNotification object:nil];
    
    [self showSearchBar];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidPressSearchButtonNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)showSearchBar {
   _searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, kSearchViewBarHeight)];
    _searchBarBackground.backgroundColor = JABlack300Color;
    [self.view addSubview:_searchBarBackground];
    
    UIView* separatorView = [UIView new];
    [separatorView setBackgroundColor:JABlack400Color];
    [separatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [separatorView setFrame:CGRectMake(_searchBarBackground.bounds.origin.x, _searchBarBackground.bounds.size.height - 1.0f, _searchBarBackground.bounds.size.width, 1.0f)];
    
    [_searchBarBackground addSubview:separatorView];
    
    CGFloat horizontalMargin = 3.0f; //adjustment to native searchbar margin
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        horizontalMargin = 10.0f;
    }
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(_searchBarBackground.bounds.origin.x + horizontalMargin, _searchBarBackground.bounds.origin.y, _searchBarBackground.bounds.size.width - horizontalMargin * 2, _searchBarBackground.bounds.size.height - 1.0f)];
    _searchBar.delegate = self;
    _searchBar.barTintColor = JABlack300Color;
    _searchBar.placeholder = STRING_SEARCH_PLACEHOLDER;
    _searchBar.showsCancelButton = NO;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor orangeColor]];
    
    UITextField *textFieldSearch = [_searchBar valueForKey:@"_searchField"];
    textFieldSearch.font = [UIFont fontWithName:kFontRegularName size:textFieldSearch.font.pointSize];
    textFieldSearch.backgroundColor = JAWhiteColor;
    [textFieldSearch setLeftViewMode:UITextFieldViewModeNever];
    
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = [JABlack300Color CGColor];
    
    [_searchBarBackground addSubview:_searchBar];
    UIImage *searchIcon = [UIImage imageNamed:@"searchIcon"];
    
    _searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
    _searchIconImageView.frame = CGRectMake(_searchBar.frame.size.width - horizontalMargin - searchIcon.size.width, (_searchBar.frame.size.height - searchIcon.size.height) / 2, searchIcon.size.width, searchIcon.size.height);
    
    [_searchBar addSubview:_searchIconImageView];
    
    [self reloadSearchBar];
}

- (void)reloadSearchBar {
    _searchBarBackground.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, kSearchViewBarHeight);
    CGFloat horizontalMargin = 3.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        horizontalMargin = 10.0f;
    }
    _searchBar.frame = CGRectMake(_searchBarBackground.bounds.origin.x + horizontalMargin, _searchBarBackground.bounds.origin.y, _searchBarBackground.bounds.size.width - horizontalMargin * 2, _searchBarBackground.bounds.size.height - 1.0f);
    
    _searchIconImageView.frame = CGRectMake(_searchBar.frame.size.width - 12.0 - _searchIconImageView.frame.size.width, (_searchBar.frame.size.height - _searchIconImageView.frame.size.height) / 2, _searchIconImageView.frame.size.width, _searchIconImageView.frame.size.height);
    
    UITextField *textFieldSearch = [_searchBar valueForKey:@"_searchField"];
    textFieldSearch.textAlignment = NSTextAlignmentLeft;
    
    if(RI_IS_RTL) {
        [textFieldSearch flipViewAlignment];
        [_searchIconImageView flipViewPositionInsideSuperview];
        [_searchBar setPositionAdjustment:UIOffsetMake(-_searchBar.frame.size.width + 48.0f, 0) forSearchBarIcon:UISearchBarIconClear];
        [_searchBar setSearchTextPositionAdjustment:UIOffsetMake(24.0f, 0)];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [[JACenterNavigationController sharedInstance] showSearchView];
    return NO;
}

@end
