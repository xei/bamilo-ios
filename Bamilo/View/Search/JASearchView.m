//
//  JASearchView.m
//  Jumia
//
//  Created by Telmo Pinto on 15/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASearchView.h"
#import "RISearchSuggestion.h"
#import "JAClickableView.h"
#import "JACenterNavigationController.h"
#import "RITarget.h"
#import "Bamilo-Swift.h"

@interface JASearchView() {
    BOOL _newSearch;
    NSInteger _randomNumber;
}

@property (nonatomic, strong)UIView* backView;
@property (nonatomic, strong)UIView* separatorView;
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UITableView* resultsTableView;
@property (nonatomic, assign)CGRect resultsTableOriginalFrame;
@property (nonatomic, assign)CGFloat keyboardHeight;
@property (nonatomic, strong)NSMutableArray* resultsArray;
@property (nonatomic, strong) NSLock *refreshLock;

@end

@implementation JASearchView

- (NSLock *)refreshLock {
    if (!VALID(_refreshLock, NSLock)) {
        _refreshLock = [NSLock new];
    }
    return _refreshLock;
}

- (instancetype)initWithFrame:(CGRect)frame andText:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCountry:)
                                                     name:kUpdateCountryNotification
                                                   object:nil];
        
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                 self.bounds.origin.y + 20.0f,
                                                                 self.bounds.size.width,
                                                                 self.bounds.size.height - 20.0f)];
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self addSubview:self.backView];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f - 64.0f, frame.size.width, 44.0f)];
        CGRect finalFrame = CGRectMake(0.0f, 20.0f, frame.size.width, 44.0f);
        self.searchBar.delegate = self;
        self.searchBar.placeholder = STRING_SEARCH;
        [self.searchBar setValue:STRING_CANCEL forKey:@"_cancelButtonText"];
        self.searchBar.showsCancelButton = YES;
        [self.searchBar setSearchBarStyle:UISearchBarStyleDefault];
        self.searchBar.barTintColor = [Theme color:kColorExtraDarkBlue];
        
        UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
        textFieldSearch.font = [UIFont fontWithName:kFontRegularName size:textFieldSearch.font.pointSize];
        textFieldSearch.backgroundColor = JAWhiteColor;
        textFieldSearch.textAlignment = NSTextAlignmentRight;
        
        UIImage *searchIcon = [UIImage imageNamed:@"searchIcon"];
        UIImageView *searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
        [textFieldSearch setLeftView:searchIconImageView];
        

        [self addSubview:self.searchBar];
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                      [UIColor whiteColor],
                                                                                                      NSForegroundColorAttributeName,
                                                                                                      JABodyFont,
                                                                                                      NSFontAttributeName,
                                                                                                      nil]
                                                                                            forState: UIControlStateNormal];

        [self.backView addSubview:self.separatorView];
        
        
        [UIView animateWithDuration:0.3f animations:^{
            self.backView.backgroundColor = JABlack300Color;
            self.backView.alpha = 1.0f;
            [self.searchBar setFrame:finalFrame];
        }];
        
        self.resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              CGRectGetMaxY(self.searchBar.frame) + self.separatorView.frame.size.height,
                                                                              self.frame.size.width,
                                                                              self.frame.size.height - CGRectGetMaxY(self.searchBar.frame) - self.separatorView.frame.size.height)
                                                             style:UITableViewStyleGrouped];
        self.resultsTableOriginalFrame = self.resultsTableView.frame;
        
        self.resultsTableView.backgroundColor = JAWhiteColor;
        self.resultsTableView.delegate = self;
        self.resultsTableView.dataSource = self;
        self.resultsTableView.contentInset = UIEdgeInsetsMake(-35.0f, 0.f, 0.f, 0.f);
        [self.resultsTableView registerClass:[UITableViewCell class]
                      forCellReuseIdentifier:@"cell"];
        self.resultsTableView.separatorColor = [UIColor clearColor];
        
        [self addSubview:self.resultsTableView];
        
        self.resultsTableView.hidden = YES;
    }
    return self;
}

- (void)resetFrame:(CGRect)frame {
    
    self.frame = frame;
    self.backView.frame = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y + 20.0f,
                                     self.bounds.size.width,
                                     self.bounds.size.height - 20.0f);
    
    self.searchBar.frame = CGRectMake(0.0f,
                                      20.0f,
                                      frame.size.width,
                                      44.0f);
    
    self.resultsTableView.frame = CGRectMake(0.0f,
                                             CGRectGetMaxY(self.searchBar.frame) + self.separatorView.frame.size.height,
                                             self.frame.size.width,
                                             self.frame.size.height - CGRectGetMaxY(self.searchBar.frame) - self.separatorView.frame.size.height);
    [self refreshData];
    
    CGFloat duration = 0.3f;
    [UIView animateWithDuration:duration animations:^{
        self.backView.backgroundColor = JABlack300Color;
        self.backView.alpha = 1.0f;
    }];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [self resetFrame:self.frame];
        [self refreshData];
    } else {
        [self popAnimated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)popAnimated:(BOOL)animated {
    [self.searchBar resignFirstResponder];
    [self removeResultsTableViewFromView];

    CGFloat duration = animated?0.3f:0.0f;
    [UIView animateWithDuration:duration animations:^{
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self.searchBar setFrame:CGRectMake(0.0f,
                                            0.0f - 64.0f,
                                            self.searchBar.frame.size.width,
                                            self.searchBar.frame.size.height)];
    } completion:nil];
    [super setHidden:YES];
}

#pragma mark - searchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    UIViewController *topViewController = [MainTabBarViewController topViewController];
    if ([topViewController conformsToProtocol:@protocol(SearchBarListener)]) {
        [(UIViewController<SearchBarListener> *)topViewController searchBarSearched:searchBar];
    }
    RISearchSuggestion *searchSuggestion = [RISearchSuggestion getSearchSuggestionWithQuery:searchBar.text isRecentSearch:YES andContext:YES];
    [searchSuggestion setTargetString:[RITarget getTargetString:CATALOG_SEARCH node:searchBar.text]];
    [self searchForSuggestion:searchSuggestion];
}

- (void)searchForSuggestion:(RISearchSuggestion *)suggestion {
    if (_newSearch) {
        [RISearchSuggestion saveSearchSuggestionOnDB:suggestion isRecentSearch:YES andContext:YES];
    }
    self.searchBar.text = @"";
    [[MainTabBarViewController topNavigationController] openTargetString:suggestion.targetString];
    [self setHidden:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setHidden:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self refreshData];
}

- (void)refreshData {
    NSInteger randomNumber = arc4random() % NSIntegerMax;
    _randomNumber = randomNumber;
    if (self.searchBar.text.length > 1) {
        [RISearchSuggestion getSuggestionsForQuery:self.searchBar.text
                                      successBlock:^(NSArray *suggestions) {
                                          if (randomNumber != _randomNumber) {
                                              return;
                                          }
                                          _newSearch = YES;
                                          self.resultsArray = [suggestions mutableCopy];
                                          [self addResultsTableViewToView];
                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                      }];
    } else {
        _newSearch = NO;
        self.resultsArray = [[RISearchSuggestion getRecentSearches] mutableCopy];
        if (VALID_NOTEMPTY(self.resultsArray, NSMutableArray)) {
            [self addResultsTableViewToView];
        } else {
            [self removeResultsTableViewFromView];
        }
    }
    [self.resultsTableView layoutIfNeeded];
    if (!self.hidden) {
        [self.searchBar becomeFirstResponder];
    }
}

#pragma mark - resultsTableView

- (void)addResultsTableViewToView {
    [self.resultsTableView reloadData];
    
    if (self.resultsTableView.hidden) {
        self.resultsTableView.hidden = NO;
        
        CGRect finalFrame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                       CGRectGetMaxY(self.searchBar.frame) + self.separatorView.frame.size.height,
                                       self.resultsTableOriginalFrame.size.width,
                                       self.resultsTableOriginalFrame.size.height - self.keyboardHeight);
        
        self.resultsTableView.frame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                                 self.resultsTableOriginalFrame.size.height,
                                                 self.resultsTableOriginalFrame.size.width,
                                                 self.resultsTableOriginalFrame.size.height - self.keyboardHeight);
        
        [UIView animateWithDuration:0.3f animations:^{
            self.resultsTableView.frame = finalFrame;
        }];
    }
}

- (void)removeResultsTableViewFromView {
    if (NO == self.resultsTableView.hidden) {
        CGRect startFrame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                       CGRectGetMaxY(self.searchBar.frame) + self.separatorView.frame.size.height,
                                       self.resultsTableOriginalFrame.size.width,
                                       self.resultsTableOriginalFrame.size.height - self.keyboardHeight);
        
        CGRect finalFrame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                       self.resultsTableOriginalFrame.size.height,
                                       self.resultsTableOriginalFrame.size.width,
                                       self.resultsTableOriginalFrame.size.height - self.keyboardHeight);
        
        [UIView animateWithDuration:0.3f animations:^{
            self.resultsTableView.frame = finalFrame;
        } completion:^(BOOL finished) {
            self.resultsTableView.hidden = YES;
            self.resultsTableView.frame = startFrame;
        }];
    }
}

#pragma mark - Tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(VALID([self.resultsArray objectAtIndex:indexPath.row], RISearchSuggestion)) {
        CGFloat heightLabel = 44.0f;
        //remove the clickable view
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                [view removeFromSuperview];
            } else {
                for (UIView* subview in view.subviews) {
                    if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                        [subview removeFromSuperview];
                    }
                }
            }
        }
        
        //add the new clickable view
        CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell setFrame:CGRectMake(cell.frame.origin.x,
                                  cell.frame.origin.y,
                                  self.resultsTableView.frame.size.width,
                                  cell.frame.size.height)];
        
        JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.resultsTableView.frame.size.width, cellHeight)];
        clickView.tag = indexPath.row;
        [cell addSubview:clickView];
        
        UILabel *customTextLabel = [UILabel new];
        customTextLabel.textAlignment = NSTextAlignmentLeft;
        [clickView addSubview:customTextLabel];
        
        RISearchSuggestion *sugestion = [self.resultsArray objectAtIndex:indexPath.row];
        
        NSString *value = sugestion.item;
        NSString *label;
        UIColor *highlightColor = JABlue1Color;;
        UIColor *stringTextColor = JAButtonTextOrange;
        
        if ([RITarget parseTarget:sugestion.targetString].targetType == SHOP_IN_SHOP) {
            value = [value stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                   withString:[[value substringToIndex:1] capitalizedString]];
            label = [NSString stringWithFormat:@"Visit our %@ Store", value];
        } else if ([RITarget parseTarget:sugestion.targetString].targetType == CATALOG_CATEGORY || [RITarget parseTarget:sugestion.targetString].targetType == CATALOG_HASH) {
            label = [NSString stringWithFormat:@"%@ in %@", sugestion.queryString, value];
        } else{
            label = value;
            value = @"";
        }
        
        NSRange blueRange = [[label lowercaseString] rangeOfString:[value lowercaseString]];
        NSRange blackRange = [[label lowercaseString] rangeOfString:[self.searchBar.text lowercaseString]];
        NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:label attributes:@{NSFontAttributeName: JASearchViewHighlightFont, NSForegroundColorAttributeName: stringTextColor}];
        
        [stringText addAttribute:NSForegroundColorAttributeName
                           value:highlightColor
                           range:blueRange];
        [stringText addAttribute:NSFontAttributeName
                           value:JASearchViewQueryFont
                           range:blackRange];
        
        customTextLabel.attributedText = stringText;
    
        
        UIImage *recentSearchImage;
        UIImageView *recentSearchImageView = [UIImageView new];
        
        
        if (1 == sugestion.isRecentSearch) {
            recentSearchImage = [UIImage imageNamed:@"ico_recentsearchsuggestion"];
            [recentSearchImageView setHidden:NO];
            [recentSearchImageView setImage:recentSearchImage];
            [clickView addSubview:recentSearchImageView];
        }
        
        
        CGFloat customImageX = recentSearchImage.size.width;
        CGFloat customTextX = (recentSearchImage.size.width*2) + 18.0f;
        CGFloat separatorX = .0f;
        CGFloat separatorWidth = cell.frame.size.width;
        CGFloat customTextLabelWidth = clickView.frame.size.width - separatorX - 20.0f;
        
        [recentSearchImageView setFrame:CGRectMake(customImageX,
                                                   (heightLabel - recentSearchImage.size.height)/2,
                                                   recentSearchImage.size.width,
                                                   recentSearchImage.size.height)];
        
        
        [customTextLabel setFrame:CGRectMake(customTextX,
                                             0.0f,
                                             customTextLabelWidth,
                                             heightLabel)];
        
        //remove the clickable view
        for (UIView* view in cell.subviews) {
            if (99 == view.tag || 98 == view.tag) {
                [view removeFromSuperview];
            }
        }
        
        UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(separatorX, cell.frame.size.height-1, separatorWidth, 1)];
        line2.backgroundColor = JABlack400Color;
        line2.tag = 98;
        [clickView addSubview:line2];
        
        if(RI_IS_RTL){
            [cell flipSubviewPositions];
            [line2 flipViewPositionInsideSuperview];
            [recentSearchImageView flipViewPositionInsideSuperview];
            [customTextLabel flipViewPositionInsideSuperview];
            [customTextLabel setTextAlignment:NSTextAlignmentRight];
        }
        [clickView addTarget:self action:@selector(resultCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)resultCellWasPressed:(UIControl*)sender {
    [self tableView:self.resultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RISearchSuggestion *suggestion = [self.resultsArray objectAtIndex:indexPath.row];
    [suggestion setDate:[NSDate new]];
    [self searchForSuggestion:suggestion];
}

#pragma mark - Keyboard
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    if(self.frame.size.width == kbSize.height) {
        height = kbSize.width;
    }
    self.keyboardHeight = height;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.resultsTableView setFrame:CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                                   self.resultsTableOriginalFrame.origin.y,
                                                   self.frame.size.width,
                                                   self.frame.size.height - self.searchBar.height - self.keyboardHeight)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        [self.resultsTableView setFrame:CGRectMake(self.resultsTableOriginalFrame.origin.x, self.resultsTableOriginalFrame.origin.y, self.frame.size.width, self.frame.size.height)];
    }];
}

- (void)updateCountry:(NSNotification *)notification {
    [self refreshData];
    for (UIView *subView in self.searchBar.subviews[0].subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton setTitle:STRING_CANCEL forState:UIControlStateNormal];
        }
    }
    self.searchBar.placeholder = STRING_SEARCH;
    [self.searchBar setNeedsLayout];
}

@end
