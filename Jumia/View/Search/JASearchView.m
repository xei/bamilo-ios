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

@interface JASearchView()

@property (nonatomic, strong)UIView* backView;
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UITableView* resultsTableView;
@property (nonatomic, assign)CGRect resultsTableOriginalFrame;
@property (nonatomic, assign)CGFloat keyboardHeight;
@property (nonatomic, strong)NSMutableArray* resultsArray;

@end

@implementation JASearchView

- (instancetype)initWithFrame:(CGRect)frame
{
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
        
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                 self.bounds.origin.y + 20.0f,
                                                                 self.bounds.size.width,
                                                                 self.bounds.size.height - 20.0f)];
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self addSubview:self.backView];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f - 64.0f,
                                                                       frame.size.width,
                                                                       44.0f)];
        CGRect finalFrame = CGRectMake(0.0f,
                                       20.0f,
                                       frame.size.width,
                                       44.0f);
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor whiteColor];
        self.searchBar.placeholder = STRING_SEARCH;
        self.searchBar.showsCancelButton = YES;
        
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor orangeColor]];
        
        UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
        textFieldSearch.font = [UIFont fontWithName:kFontRegularName size:textFieldSearch.font.pointSize];
        textFieldSearch.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0f];
        
        self.searchBar.layer.borderWidth = 1;
        self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        [self addSubview:self.searchBar];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            [self.searchBar setFrame:finalFrame];
        }];
        [self.searchBar becomeFirstResponder];
        
        
        self.resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              CGRectGetMaxY(self.searchBar.frame),
                                                                              self.frame.size.width,
                                                                              self.frame.size.height - CGRectGetMaxY(self.searchBar.frame))
                                                             style:UITableViewStyleGrouped];
        self.resultsTableOriginalFrame = self.resultsTableView.frame;
        
        self.resultsTableView.backgroundColor = UIColorFromRGB(0xffffff);
        self.resultsTableView.delegate = self;
        self.resultsTableView.dataSource = self;
        self.resultsTableView.contentInset = UIEdgeInsetsMake(-35.0f, 0.f, 0.f, 0.f);
        [self.resultsTableView registerClass:[UITableViewCell class]
                      forCellReuseIdentifier:@"cell"];
        self.resultsTableView.separatorColor = [UIColor clearColor];
        
        [self addSubview:self.resultsTableView];
        
        self.resultsTableView.hidden = YES;
        [self searchBar:self.searchBar textDidChange:@""];
    }
    return self;
}

- (void)resetFrame:(CGRect)frame
       orientation:(UIInterfaceOrientation)orientation
{
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0.0f, 0.0f, screenHeight, screenWidth);
        }
        else
        {
            frame  = CGRectMake(0.0f, 0.0f, screenWidth, screenHeight);
        }
    }
    else
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0.0f, 0.0f, screenWidth, screenHeight);
        }
        else
        {
            frame  = CGRectMake(0.0f, 0.0f, screenHeight, screenWidth);
        }
    }
    
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
                                             CGRectGetMaxY(self.searchBar.frame),
                                             self.frame.size.width,
                                             self.frame.size.height - CGRectGetMaxY(self.searchBar.frame));
    [self.resultsTableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)popAnimated:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
    
    [self removeResultsTableViewFromView];
    
    CGFloat duration = animated?0.3f:0.0f;
    [UIView animateWithDuration:duration animations:^{
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self.searchBar setFrame:CGRectMake(0.0f,
                                            0.0f - 64.0f,
                                            self.searchBar.frame.size.width,
                                            self.searchBar.frame.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - searchBar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchFor:searchBar.text];
}

- (void)searchFor:(NSString*)stringToSearch
{
    [RISearchSuggestion saveSearchSuggestionOnDB:stringToSearch
                                  isRecentSearch:YES
                                      andContext:YES];
    
    // I changed the index to 99 to know that it's to display a search result
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(99),
                                                                 @"name": STRING_SEARCH,
                                                                 @"text": stringToSearch }];
    [self popAnimated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self popAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 1)
    {
        [RISearchSuggestion getSuggestionsForQuery:searchText
                                      successBlock:^(NSArray *suggestions) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.resultsArray = [suggestions mutableCopy];
                                              [self addResultsTableViewToView];
                                          });
                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                      }];
    } else {
        self.resultsArray = [[RISearchSuggestion getRecentSearches] mutableCopy];
        if (VALID_NOTEMPTY(self.resultsArray, NSMutableArray)) {
            [self addResultsTableViewToView];
        } else {
            [self removeResultsTableViewFromView];
        }
    }
}

#pragma mark - resultsTableView

- (void)addResultsTableViewToView
{
    [self.resultsTableView reloadData];
    
    if (self.resultsTableView.hidden) {
        self.resultsTableView.hidden = NO;
        
        CGRect finalFrame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                       CGRectGetMaxY(self.searchBar.frame),
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

- (void)removeResultsTableViewFromView
{
    if (NO == self.resultsTableView.hidden) {
        CGRect startFrame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                       CGRectGetMaxY(self.searchBar.frame),
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
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
    
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   0.0f,
                                                                                   self.resultsTableView.frame.size.width,
                                                                                   cellHeight)];
    clickView.tag = indexPath.row;
    [cell addSubview:clickView];
    
    UILabel *customTextLabel = [UILabel new];
    customTextLabel.textAlignment = NSTextAlignmentLeft;
    [clickView addSubview:customTextLabel];
    
    RISearchSuggestion *sugestion = [self.resultsArray objectAtIndex:indexPath.row];
    
    NSString *text = sugestion.item;
    NSString *searchedText = self.searchBar.text;
    
    if (text.length == 0)
    {
        text = STRING_ERROR;
    }
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text];
    NSInteger stringTextLenght = text.length;
    
    UIFont *stringTextFont = [UIFont fontWithName:kFontLightName size:17.0f];
    UIFont *subStringTextFont = [UIFont fontWithName:kFontRegularName size:17.0f];
    UIColor *stringTextColor = UIColorFromRGB(0x4e4e4e);
    
    
    [stringText addAttribute:NSFontAttributeName
                       value:stringTextFont
                       range:NSMakeRange(0, stringTextLenght)];
    
    [stringText addAttribute:NSStrokeColorAttributeName
                       value:stringTextColor
                       range:NSMakeRange(0, stringTextLenght)];
    
    NSRange range = [text rangeOfString:searchedText];
    
    [stringText addAttribute:NSFontAttributeName
                       value:subStringTextFont
                       range:range];
    
    customTextLabel.attributedText = stringText;
    
    UIImage *recentSearchImage;
    UIImageView *recentSearchImageView = [UIImageView new];
    
    
    if (1 == sugestion.isRecentSearch)
    {
        recentSearchImage = [UIImage imageNamed:@"ico_recentsearchsuggestion"];
    }
    else
    {
        recentSearchImage = [UIImage imageNamed:@"ico_searchsuggestion"];
    }
    
    [recentSearchImageView setImage:recentSearchImage];
    [clickView addSubview:recentSearchImageView];
    
    CGFloat customImageX = recentSearchImage.size.width;
    CGFloat customTextX = (recentSearchImage.size.width*2) + 18.0f;
    CGFloat separatorX = 45.0f;
    CGFloat separatorWidth = cell.frame.size.width-20;
    CGFloat customTextLabelWidth = clickView.frame.size.width - separatorX - 6.0f;
    
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
    UIImageView *line;
    if (0 == indexPath.row)
    {
        line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
        line.backgroundColor = UIColorFromRGB(0xcccccc);
        line.tag = 99;
        [clickView addSubview:line];
    }
    
    UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(separatorX, cell.frame.size.height-1, separatorWidth, 1)];
    line2.backgroundColor = UIColorFromRGB(0xcccccc);
    line2.tag = 98;
    [clickView addSubview:line2];
    
    if(RI_IS_RTL){
        
        [cell flipSubviewPositions];
        [line flipViewPositionInsideSuperview];
        [line2 flipViewPositionInsideSuperview];
        [recentSearchImageView flipViewPositionInsideSuperview];
        [customTextLabel flipViewPositionInsideSuperview];
        [customTextLabel setTextAlignment:NSTextAlignmentRight];
    }
    [clickView addTarget:self action:@selector(resultCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)resultCellWasPressed:(UIControl*)sender
{
    [self tableView:self.resultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RISearchSuggestion *suggestion = [self.resultsArray objectAtIndex:indexPath.row];
    
    [self searchFor:suggestion.item];
}

#pragma mark - Keyboard
- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    if(self.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    self.keyboardHeight = height;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.resultsTableView setFrame:CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                                   self.resultsTableOriginalFrame.origin.y,
                                                   self.resultsTableOriginalFrame.size.width,
                                                   self.resultsTableOriginalFrame.size.height - self.keyboardHeight)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.resultsTableView setFrame:self.resultsTableOriginalFrame];
    }];
}


@end